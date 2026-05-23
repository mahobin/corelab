# ==============================================================================
# CoreLab — Orchestration Makefile
#
# File naming convention:  c/0001_topic.c   rust/0001_topic.rs   python/0001_topic.py
#
# Quick reference
#   make run-c      id=0001          compile (dev) + run a C experiment
#   make run-rust   id=0001          compile (dev) + run a Rust experiment
#   make run-py     id=0001          run a Python experiment
#   make build-c    id=0001          compile only, keep binary in .build/
#   make all                         compile every *.c in c/ (used by CI)
#   make asan       id=0001          C with AddressSanitizer + UBSan
#   make tsan       id=0001          C with ThreadSanitizer
#   make valgrind   id=0001          C under Valgrind memcheck
#   make bench-c    id=0001          C release build timed with hyperfine
#   make bench-rust id=0001          Rust release build timed with hyperfine
#   make bench-py   id=0001          Python timed with hyperfine
#   make fmt                         clang-format + rustfmt + ruff format
#   make lint                        cppcheck + clippy + ruff check
#   make check-c    id=0001          Clang static analyser on one file
#   make disasm     id=0001          disassemble optimised binary
#   make ast-py     id=0001          dump Python AST
#   make bc-py      id=0001          dump Python bytecode (dis)
#   make new-c      id=0001 name=x   scaffold a new C experiment
#   make new-rust   id=0001 name=x   scaffold a new Rust experiment
#   make new-py     id=0001 name=x   scaffold a new Python experiment
#   make list                        list all experiments
#   make clean                       remove build artefacts
#   make help                        this message
# ==============================================================================

# ------------------------------------------------------------------------------
# Toolchain
# ------------------------------------------------------------------------------
CC      := clang
RUSTC   := rustc
PYTHON  := python3
CARGO   := cargo
FMT_C   := clang-format
FMT_RS  := rustfmt

# ------------------------------------------------------------------------------
# C warning flags (shared by all C targets, matches c.yml WARN env exactly)
# ------------------------------------------------------------------------------
WARN := \
	-Wall \
	-Wextra \
	-Wpedantic \
	-Werror \
	-Wconversion \
	-Wsign-conversion \
	-Wshadow \
	-Wundef \
	-Wstrict-prototypes \
	-Wmissing-prototypes \
	-Wmissing-declarations \
	-Wcast-align \
	-Wnull-dereference \
	-Wdouble-promotion \
	-Wformat=2

# Dev build: -O1 keeps code recognisable in a debugger while still exercising
# the optimiser's basic transforms. -g + frame pointer for clean stack traces.
DEV_FLAGS := -std=c17 $(WARN) -O1 -g -fno-omit-frame-pointer

# Release build: used only by bench-c and `make all` release variant.
# Never used for correctness tests — sanitizers and -O3 interact badly.
REL_FLAGS := -std=c17 $(WARN) -O3 -flto -march=native -DNDEBUG

# Sanitizer flag sets
SAN_ASAN := -fsanitize=address,undefined -fno-omit-frame-pointer -g -O1
SAN_TSAN := -fsanitize=thread            -fno-omit-frame-pointer -g -O1 -fPIE -pie

# ------------------------------------------------------------------------------
# Rust flags
# ------------------------------------------------------------------------------
RUST_EDITION := 2024
RUSTC_DEV    := --edition=$(RUST_EDITION) -g
RUSTC_REL    := --edition=$(RUST_EDITION) \
	-C opt-level=3 \
	-C lto=fat \
	-C codegen-units=1 \
	-C target-cpu=native

# ------------------------------------------------------------------------------
# Directories
# ------------------------------------------------------------------------------
BUILD_DIR := .build
C_DIR     := c
RUST_DIR  := rust
PY_DIR    := python

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

# ------------------------------------------------------------------------------
# File resolution — ls glob, first match wins
# id=0001 and id=0001_stack_allocator both work
# ------------------------------------------------------------------------------
_find_c  = $(shell ls $(C_DIR)/$(id)*.c    2>/dev/null | head -1)
_find_rs = $(shell ls $(RUST_DIR)/$(id)*.rs 2>/dev/null | head -1)
_find_py = $(shell ls $(PY_DIR)/$(id)*.py   2>/dev/null | head -1)

# Require id= to be set for targets that need it
define _require_id
	@if [ -z "$(id)" ]; then \
	    echo "Error: id is required.  Example: make $(1) id=0001"; \
	    exit 1; \
	fi
endef

# ------------------------------------------------------------------------------
# .PHONY
# ------------------------------------------------------------------------------
.PHONY: \
	all ci-build \
	help \
	run-c run-rust run-py \
	build-c \
	asan tsan valgrind \
	bench-c bench-rust bench-py \
	fmt fmt-c fmt-rust fmt-py \
	lint lint-c lint-rust lint-py \
	check-c \
	disasm \
	ast-py bc-py \
	new-c new-rust new-py \
	list \
	clean

.DEFAULT_GOAL := help

# ==============================================================================
# SECTION: CI build target
#
# `make all` is called by CI (c.yml) to build every experiment in c/.
# It compiles each *.c file independently — failures are isolated and reported
# per-file but do not abort the entire build.
# CI passes its own CC and CFLAGS overrides on the command line:
#   make all CC=clang CFLAGS="<warn> <opt> -std=c17"
# ==============================================================================

## all — compile every *.c in c/ independently (used by CI; also useful locally)
all: $(BUILD_DIR)
	@if [ ! -d $(C_DIR) ] || [ -z "$$(find $(C_DIR) -maxdepth 1 -name '*.c' 2>/dev/null | head -1)" ]; then \
	    echo "No C source files found in $(C_DIR)/ — nothing to build."; \
	    exit 0; \
	fi
	@PASS=0; FAIL=0; \
	for src in $$(find $(C_DIR) -maxdepth 1 -name '*.c' | sort); do \
	    name=$$(basename "$${src%.c}"); \
	    out="$(BUILD_DIR)/$${name}"; \
	    printf "  CC  %-40s" "$$src"; \
	    if $(CC) $(CFLAGS) $(DEV_FLAGS) "$$src" -o "$$out" -lm 2>/tmp/_cc_err; then \
	        echo "OK"; \
	        PASS=$$((PASS + 1)); \
	    else \
	        echo "FAILED"; \
	        cat /tmp/_cc_err; \
	        FAIL=$$((FAIL + 1)); \
	    fi; \
	done; \
	echo ""; \
	echo "  Results: $$PASS built, $$FAIL failed"; \
	if [ "$$FAIL" -gt 0 ] && [ "$$PASS" -eq 0 ]; then exit 1; fi

# ==============================================================================
# SECTION: Run (single experiment by id)
# ==============================================================================

## run-c id=NNNN — compile (dev) and run one C experiment
run-c: $(BUILD_DIR)
	$(call _require_id,run-c)
	@src="$(_find_c)"; \
	if [ -z "$$src" ]; then echo "Error: no file matching $(C_DIR)/$(id)*.c"; exit 1; fi; \
	out="$(BUILD_DIR)/$(id)"; \
	echo "  CC  $$src"; \
	$(CC) $(DEV_FLAGS) "$$src" -o "$$out" -lm; \
	echo "  RUN $$out"; \
	"$$out"

## run-rust id=NNNN — compile (dev) and run one Rust experiment
run-rust: $(BUILD_DIR)
	$(call _require_id,run-rust)
	@src="$(_find_rs)"; \
	if [ -z "$$src" ]; then echo "Error: no file matching $(RUST_DIR)/$(id)*.rs"; exit 1; fi; \
	out="$(BUILD_DIR)/$(id)"; \
	echo "  RUSTC $$src"; \
	$(RUSTC) $(RUSTC_DEV) "$$src" -o "$$out"; \
	echo "  RUN   $$out"; \
	"$$out"

## run-py id=NNNN — run one Python experiment
run-py:
	$(call _require_id,run-py)
	@src="$(_find_py)"; \
	if [ -z "$$src" ]; then echo "Error: no file matching $(PY_DIR)/$(id)*.py"; exit 1; fi; \
	echo "  PY  $$src"; \
	$(PYTHON) "$$src"

# ==============================================================================
# SECTION: Build only
# ==============================================================================

## build-c id=NNNN — compile a C experiment without running it
build-c: $(BUILD_DIR)
	$(call _require_id,build-c)
	@src="$(_find_c)"; \
	if [ -z "$$src" ]; then echo "Error: no file matching $(C_DIR)/$(id)*.c"; exit 1; fi; \
	out="$(BUILD_DIR)/$(id)"; \
	echo "  CC  $$src -> $$out"; \
	$(CC) $(DEV_FLAGS) "$$src" -o "$$out" -lm

# ==============================================================================
# SECTION: Sanitizers
# ==============================================================================

## asan id=NNNN — AddressSanitizer + UndefinedBehaviorSanitizer
asan: $(BUILD_DIR)
	$(call _require_id,asan)
	@src="$(_find_c)"; \
	if [ -z "$$src" ]; then echo "Error: no file matching $(C_DIR)/$(id)*.c"; exit 1; fi; \
	out="$(BUILD_DIR)/$(id)_asan"; \
	echo "  CC [asan+ubsan]  $$src"; \
	$(CC) -std=c17 $(WARN) $(SAN_ASAN) "$$src" -o "$$out" -lm; \
	echo "  RUN $$out"; \
	ASAN_OPTIONS="halt_on_error=1:detect_leaks=1:detect_stack_use_after_return=1" \
	UBSAN_OPTIONS="halt_on_error=1:print_stacktrace=1" \
	"$$out"

## tsan id=NNNN — ThreadSanitizer (incompatible with ASan)
tsan: $(BUILD_DIR)
	$(call _require_id,tsan)
	@src="$(_find_c)"; \
	if [ -z "$$src" ]; then echo "Error: no file matching $(C_DIR)/$(id)*.c"; exit 1; fi; \
	out="$(BUILD_DIR)/$(id)_tsan"; \
	echo "  CC [tsan]  $$src"; \
	$(CC) -std=c17 $(WARN) $(SAN_TSAN) "$$src" -o "$$out" -lm; \
	echo "  RUN $$out"; \
	TSAN_OPTIONS="halt_on_error=1:history_size=3" \
	"$$out"

## valgrind id=NNNN — run under Valgrind memcheck
valgrind: $(BUILD_DIR)
	$(call _require_id,valgrind)
	@src="$(_find_c)"; \
	if [ -z "$$src" ]; then echo "Error: no file matching $(C_DIR)/$(id)*.c"; exit 1; fi; \
	out="$(BUILD_DIR)/$(id)_vg"; \
	echo "  CC [debug]  $$src"; \
	$(CC) -std=c17 $(WARN) -O0 -g "$$src" -o "$$out" -lm; \
	echo "  VALGRIND $$out"; \
	valgrind \
	    --error-exitcode=1 \
	    --leak-check=full \
	    --show-leak-kinds=all \
	    --track-origins=yes \
	    --verbose \
	    "$$out"

# ==============================================================================
# SECTION: Benchmarks
# ==============================================================================

## bench-c id=NNNN — release build + hyperfine timing
bench-c: $(BUILD_DIR)
	$(call _require_id,bench-c)
	@src="$(_find_c)"; \
	if [ -z "$$src" ]; then echo "Error: no file matching $(C_DIR)/$(id)*.c"; exit 1; fi; \
	out="$(BUILD_DIR)/$(id)_rel"; \
	echo "  CC [release] $$src"; \
	$(CC) $(REL_FLAGS) "$$src" -o "$$out" -lm; \
	echo "  BENCH $$out"; \
	hyperfine --warmup 3 "$$out"

## bench-rust id=NNNN — release build + hyperfine timing
bench-rust: $(BUILD_DIR)
	$(call _require_id,bench-rust)
	@src="$(_find_rs)"; \
	if [ -z "$$src" ]; then echo "Error: no file matching $(RUST_DIR)/$(id)*.rs"; exit 1; fi; \
	out="$(BUILD_DIR)/$(id)_rel"; \
	echo "  RUSTC [release] $$src"; \
	$(RUSTC) $(RUSTC_REL) "$$src" -o "$$out"; \
	echo "  BENCH $$out"; \
	hyperfine --warmup 3 "$$out"

## bench-py id=NNNN — hyperfine timing
bench-py:
	$(call _require_id,bench-py)
	@src="$(_find_py)"; \
	if [ -z "$$src" ]; then echo "Error: no file matching $(PY_DIR)/$(id)*.py"; exit 1; fi; \
	echo "  BENCH $$src"; \
	hyperfine --warmup 3 "$(PYTHON) $$src"

# ==============================================================================
# SECTION: Formatting
# ==============================================================================

## fmt — format all source files in-place
fmt: fmt-c fmt-rust fmt-py

## fmt-c — clang-format all C files
fmt-c:
	@echo "  FMT  $(C_DIR)/"
	@if [ -d $(C_DIR) ]; then \
	    find $(C_DIR) -maxdepth 1 \( -name "*.c" -o -name "*.h" \) 2>/dev/null \
	        | sort | xargs -r $(FMT_C) -i; \
	fi

## fmt-rust — rustfmt all Rust files
fmt-rust:
	@echo "  FMT  $(RUST_DIR)/"
	@if [ -d $(RUST_DIR) ]; then \
	    find $(RUST_DIR) -maxdepth 1 -name "*.rs" 2>/dev/null \
	        | sort | xargs -r $(FMT_RS); \
	fi

## fmt-py — ruff format all Python files
fmt-py:
	@echo "  FMT  $(PY_DIR)/"
	@if [ -d $(PY_DIR) ]; then \
	    command -v ruff >/dev/null 2>&1 \
	        && ruff format $(PY_DIR)/ 2>/dev/null \
	        || echo "  (ruff not found — pip install ruff)"; \
	fi

# ==============================================================================
# SECTION: Linting
# ==============================================================================

## lint — all linters
lint: lint-c lint-rust lint-py

## lint-c — cppcheck
lint-c:
	@echo "  LINT $(C_DIR)/"
	@if [ ! -d $(C_DIR) ]; then echo "  ($(C_DIR)/ not found — skipping)"; exit 0; fi
	@if [ -z "$$(find $(C_DIR) -maxdepth 1 -name '*.c' | head -1)" ]; then \
	    echo "  (no .c files — skipping)"; exit 0; fi
	cppcheck \
	    --error-exitcode=1 \
	    --enable=warning,style,performance,portability \
	    --suppress=missingIncludeSystem \
	    --force \
	    --inline-suppr \
	    -I $(C_DIR) \
	    $(C_DIR)/

## lint-rust — cargo clippy
lint-rust:
	@echo "  LINT $(RUST_DIR)/"
	@if [ ! -f $(RUST_DIR)/Cargo.toml ]; then \
	    echo "  ($(RUST_DIR)/Cargo.toml not found — skipping)"; exit 0; fi
	cd $(RUST_DIR) && $(CARGO) clippy --all-targets --all-features -- -D warnings

## lint-py — ruff check
lint-py:
	@echo "  LINT $(PY_DIR)/"
	@if [ ! -d $(PY_DIR) ]; then echo "  ($(PY_DIR)/ not found — skipping)"; exit 0; fi
	@command -v ruff >/dev/null 2>&1 \
	    && ruff check $(PY_DIR)/ \
	    || echo "  (ruff not found — pip install ruff)"

# ==============================================================================
# SECTION: Static analysis
# ==============================================================================

## check-c id=NNNN — Clang static analyser (deeper than cppcheck)
check-c:
	$(call _require_id,check-c)
	@src="$(_find_c)"; \
	if [ -z "$$src" ]; then echo "Error: no file matching $(C_DIR)/$(id)*.c"; exit 1; fi; \
	echo "  ANALYZE $$src"; \
	$(CC) --analyze \
	    -Xanalyzer -analyzer-output=text \
	    $(DEV_FLAGS) \
	    "$$src" \
	    -o /dev/null

# ==============================================================================
# SECTION: Disassembly
# ==============================================================================

## disasm id=NNNN — release build then disassemble (objdump on Linux, otool on macOS)
disasm: $(BUILD_DIR)
	$(call _require_id,disasm)
	@src="$(_find_c)"; \
	if [ -z "$$src" ]; then echo "Error: no file matching $(C_DIR)/$(id)*.c"; exit 1; fi; \
	out="$(BUILD_DIR)/$(id)_disasm"; \
	echo "  CC [release] $$src"; \
	$(CC) $(REL_FLAGS) "$$src" -o "$$out" -lm; \
	echo ""; \
	if command -v objdump >/dev/null 2>&1; then \
	    objdump -d -M intel --no-show-raw-insn "$$out" | less; \
	elif command -v otool >/dev/null 2>&1; then \
	    otool -tv "$$out" | less; \
	else \
	    echo "Error: neither objdump nor otool found"; exit 1; \
	fi

# ==============================================================================
# SECTION: Python introspection
# ==============================================================================

## ast-py id=NNNN — dump the Python AST
ast-py:
	$(call _require_id,ast-py)
	@src="$(_find_py)"; \
	if [ -z "$$src" ]; then echo "Error: no file matching $(PY_DIR)/$(id)*.py"; exit 1; fi; \
	echo "  AST $$src"; \
	$(PYTHON) -c "import ast; tree=ast.parse(open('$$src').read(), filename='$$src'); print(ast.dump(tree, indent=2))"

## bc-py id=NNNN — dump Python bytecode via dis
bc-py:
	$(call _require_id,bc-py)
	@src="$(_find_py)"; \
	if [ -z "$$src" ]; then echo "Error: no file matching $(PY_DIR)/$(id)*.py"; exit 1; fi; \
	echo "  BYTECODE $$src"; \
	$(PYTHON) -c "import dis; code=compile(open('$$src').read(),'$$src','exec'); dis.dis(code)"

# ==============================================================================
# SECTION: Scaffolding
#
# Writes a template file and prints the path. Uses printf instead of heredoc
# to avoid Make variable expansion issues inside recipe bodies.
# ==============================================================================

## new-c id=NNNN name=topic — create a new C experiment from template
new-c:
	$(call _require_id,new-c)
	@if [ -z "$(name)" ]; then \
	    echo "Error: name is required.  Example: make new-c id=0007 name=arena_alloc"; \
	    exit 1; \
	fi
	@target="$(C_DIR)/$(id)_$(name).c"; \
	if [ -f "$$target" ]; then echo "Error: $$target already exists"; exit 1; fi; \
	mkdir -p $(C_DIR); \
	printf '/*\n * %s\n *\n * Experiment : %s\n * Standard   : C17\n */\n#include <stdio.h>\n#include <stdlib.h>\n#include <stdint.h>\n#include <string.h>\n\nint\nmain(void)\n{\n    puts("hello from %s");\n    return 0;\n}\n' \
	    "$(id)_$(name).c" "$(name)" "$(id)_$(name)" > "$$target"; \
	echo "  NEW  $$target"

## new-rust id=NNNN name=topic — create a new Rust experiment from template
new-rust:
	$(call _require_id,new-rust)
	@if [ -z "$(name)" ]; then \
	    echo "Error: name is required.  Example: make new-rust id=0007 name=ownership"; \
	    exit 1; \
	fi
	@target="$(RUST_DIR)/$(id)_$(name).rs"; \
	if [ -f "$$target" ]; then echo "Error: $$target already exists"; exit 1; fi; \
	mkdir -p $(RUST_DIR); \
	printf '//! %s\n//!\n//! Experiment : %s\n//! Edition    : 2024\n\nfn main() {\n    println!("hello from %s");\n}\n' \
	    "$(id)_$(name)" "$(name)" "$(id)_$(name)" > "$$target"; \
	echo "  NEW  $$target"

## new-py id=NNNN name=topic — create a new Python experiment from template
new-py:
	$(call _require_id,new-py)
	@if [ -z "$(name)" ]; then \
	    echo "Error: name is required.  Example: make new-py id=0007 name=bytecode_walker"; \
	    exit 1; \
	fi
	@target="$(PY_DIR)/$(id)_$(name).py"; \
	if [ -f "$$target" ]; then echo "Error: $$target already exists"; exit 1; fi; \
	mkdir -p $(PY_DIR); \
	printf '"""\n%s\n\nExperiment : %s\n"""\n\n\ndef main() -> None:\n    print("hello from %s")\n\n\nif __name__ == "__main__":\n    main()\n' \
	    "$(id)_$(name).py" "$(name)" "$(id)_$(name)" > "$$target"; \
	echo "  NEW  $$target"

# ==============================================================================
# SECTION: Listing
# ==============================================================================

## list — list all experiments across all three languages
list:
	@echo ""
	@echo "  C  ($(C_DIR)/)"
	@echo "  $(shell printf '%0.s─' {1..50})"
	@find $(C_DIR) -maxdepth 1 -name "[0-9][0-9][0-9][0-9]_*.c" 2>/dev/null \
	    | sort | sed 's|$(C_DIR)/||' | sed 's/^/    /' \
	    || echo "    (none)"
	@echo ""
	@echo "  Rust  ($(RUST_DIR)/)"
	@echo "  $(shell printf '%0.s─' {1..50})"
	@find $(RUST_DIR) -maxdepth 1 -name "[0-9][0-9][0-9][0-9]_*.rs" 2>/dev/null \
	    | sort | sed 's|$(RUST_DIR)/||' | sed 's/^/    /' \
	    || echo "    (none)"
	@echo ""
	@echo "  Python  ($(PY_DIR)/)"
	@echo "  $(shell printf '%0.s─' {1..50})"
	@find $(PY_DIR) -maxdepth 1 -name "[0-9][0-9][0-9][0-9]_*.py" 2>/dev/null \
	    | sort | sed 's|$(PY_DIR)/||' | sed 's/^/    /' \
	    || echo "    (none)"
	@echo ""

# ==============================================================================
# SECTION: Clean
# ==============================================================================

## clean — remove all build artefacts
clean:
	@echo "  CLEAN"
	@rm -rf $(BUILD_DIR)
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.pyc" -delete 2>/dev/null || true
	@echo "  done"

# ==============================================================================
# SECTION: Help
# ==============================================================================

## help — print this message
help:
	@echo ""
	@echo "  CoreLab"
	@echo ""
	@echo "  Run"
	@echo "    make run-c      id=0001          compile (dev) + run"
	@echo "    make run-rust   id=0001          compile (dev) + run"
	@echo "    make run-py     id=0001          run"
	@echo "    make build-c    id=0001          compile, keep binary in .build/"
	@echo "    make all                         compile every c/*.c (used by CI)"
	@echo ""
	@echo "  Sanitizers  (requires clang + compiler-rt)"
	@echo "    make asan       id=0001          AddressSanitizer + UBSan"
	@echo "    make tsan       id=0001          ThreadSanitizer"
	@echo "    make valgrind   id=0001          Valgrind memcheck"
	@echo ""
	@echo "  Benchmarks  (requires hyperfine)"
	@echo "    make bench-c    id=0001          release build + hyperfine"
	@echo "    make bench-rust id=0001          release build + hyperfine"
	@echo "    make bench-py   id=0001          hyperfine"
	@echo ""
	@echo "  Code quality"
	@echo "    make fmt                         clang-format + rustfmt + ruff format"
	@echo "    make lint                        cppcheck + clippy + ruff check"
	@echo "    make check-c    id=0001          Clang static analyser"
	@echo ""
	@echo "  Introspection"
	@echo "    make disasm     id=0001          disassemble release binary"
	@echo "    make ast-py     id=0001          dump Python AST"
	@echo "    make bc-py      id=0001          dump Python bytecode"
	@echo ""
	@echo "  Scaffolding"
	@echo "    make new-c      id=0007 name=arena_alloc"
	@echo "    make new-rust   id=0007 name=ownership"
	@echo "    make new-py     id=0007 name=bytecode_walker"
	@echo ""
	@echo "  Utility"
	@echo "    make list                        list all experiments"
	@echo "    make clean                       remove .build/"
	@echo ""
