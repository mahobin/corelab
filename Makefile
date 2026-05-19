# CoreLab Orchestration Makefile

CC = clang
CFLAGS = -std=c17 -pedantic -Wall -Wextra -Werror -Wconversion -Wsign-conversion -Wshadow -Wundef -Wstrict-prototypes -Wmissing-prototypes -Wmissing-declarations -O3 -flto -march=native -DNDEBUG
RUSTC = rustc
PYTHON = python3

.PHONY: run-c run-rust run-py clean help

# Default target
help:
	@echo "Usage:"
	@echo "  make run-c id=0001     # Runs C experiment starting with 0001"
	@echo "  make run-rust id=0001  # Runs Rust experiment starting with 0001"
	@echo "  make run-py id=0001    # Runs Python experiment starting with 0001"

# --- C Execution ---
run-c:
	@if [ -z "$(id)" ]; then echo "Error: Provide an id (e.g., make run-c id=0001)"; exit 1; fi
	$(CC) $(CFLAGS) c/$(id)_*.c -o occ
	./occ
	@rm occ

# --- Rust Execution ---
run-rust:
	@if [ -z "$(id)" ]; then echo "Error: Provide an id (e.g., make run-rust id=0001)"; exit 1; fi
	$(RUSTC) --edition=2024 rust/$(id)_*.rs -o ors
	./ors
	@rm ors

# --- Python Execution ---
run-py:
	@if [ -z "$(id)" ]; then echo "Error: Provide an id (e.g., make run-py id=0001)"; exit 1; fi
	$(PYTHON) python/$(id)_*.py

clean:
	rm -f out_c out_rust
	find . -type d -name "__pycache__" -exec rm -rf {} +
