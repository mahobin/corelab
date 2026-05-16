# CoreLab

> A personal engineering laboratory for systems programming, language runtimes, and low-level software experiments.
> Written in **C**, **Rust**, and **Python** — built for depth, not polish.

<br>

[![C Pipeline](https://github.com/mahobin/corelab/actions/workflows/c.yml/badge.svg)](https://github.com/mahobin/corelab/actions/workflows/c.yml)
[![Rust Pipeline](https://github.com/mahobin/corelab/actions/workflows/rust.yml/badge.svg)](https://github.com/mahobin/corelab/actions/workflows/rust.yml)
[![Python Pipeline](https://github.com/mahobin/corelab/actions/workflows/python.yml/badge.svg)](https://github.com/mahobin/corelab/actions/workflows/python.yml)
[![Security](https://github.com/mahobin/corelab/actions/workflows/security.yml/badge.svg)](https://github.com/mahobin/corelab/actions/workflows/security.yml)
[![Docs](https://github.com/mahobin/corelab/actions/workflows/docs.yml/badge.svg)](https://github.com/mahobin/corelab/actions/workflows/docs.yml)

---

## Overview

CoreLab is a structured, numbered experiment log for deep systems engineering. Every file follows the `0001_topic.ext` flat-file convention — isolated, reproducible, self-contained. The repository is organized by language and subject area, covering:

- **Memory & runtime internals** — layout, allocation strategies, GC mechanisms
- **Language implementation** — bytecode analysis, AST transformations, parsers, interpreters, compiler pipelines
- **Concurrency & synchronization** — threading models, atomics, lock-free structures
- **Networking primitives** — sockets, protocols, zero-copy I/O
- **Security & correctness** — fuzzing, sanitizers, static analysis, advisory scanning
- **Cross-language interoperability** — FFI, ABI boundaries, shared memory

The goal is reproducible understanding at the hardware and runtime level.

---

## CI/CD

All workflows live in [`.github/workflows/`](.github/workflows/). Path filters ensure each pipeline triggers only on relevant file changes — a Python-only commit never activates the C or Rust pipeline.

| Workflow | Trigger paths | What it does |
|---|---|---|
| [`c.yml`](.github/workflows/c.yml) | `c/**`, `*.c`, `*.h` | GCC + Clang matrix · ASan/UBSan · Valgrind · cppcheck |
| [`rust.yml`](.github/workflows/rust.yml) | `rust/**`, `*.rs` | fmt · clippy · stable + nightly · Miri · docs · cargo-audit |
| [`python.yml`](.github/workflows/python.yml) | `python/**`, `*.py` | ruff · black · mypy · pytest 3.11–3.13 · coverage |
| [`docs.yml`](.github/workflows/docs.yml) | `docs/**`, `*.md` | MkDocs strict build · link validation · Pages deploy on `main` |
| [`container.yml`](.github/workflows/container.yml) | `docker/**` | Buildx multi-arch (amd64 + arm64) · GHCR publish |
| [`fuzz.yml`](.github/workflows/fuzz.yml) | Scheduled (weekly) + manual | AFL++ · libFuzzer · cargo-fuzz · Atheris · crash artifacts |
| [`sanitizer.yml`](.github/workflows/sanitizer.yml) | C/Rust paths | ASan · UBSan · LSan · TSan matrix across both languages |
| [`cross-platform.yml`](.github/workflows/cross-platform.yml) | All source paths | Linux · macOS · Windows native · Docker + QEMU arm64 |
| [`benchmark.yml`](.github/workflows/benchmark.yml) | Scheduled (weekly) + manual | hyperfine · cargo bench · pyperf · JSON artifacts retained 90d |
| [`security.yml`](.github/workflows/security.yml) | Push to `main`, scheduled | CodeQL · cargo-audit · pip-audit · dependency review · SBOM |

**Manual dispatch:** Every workflow supports `workflow_dispatch`. Navigate to **Actions → select workflow → Run workflow**. The `benchmark` workflow accepts `warmup_count` and `run_count` inputs; the `fuzz` workflow accepts a `duration_seconds` input.

---

## Languages & Toolchains

### C

| Tool | Minimum version | Role |
|---|---|---|
| GCC | 13 | Primary compiler |
| Clang | 17 | Secondary compiler; sanitizers; fuzzing |
| GNU Make | any | Build orchestration |
| cppcheck | 2.13 | Static analysis |
| Valgrind | 3.21 | Memory error detection |
| AFL++ | 4.x | Coverage-guided fuzzing |

**Recommended local build flags:**

```sh
clang -Wall -Wextra -Wpedantic -Werror \
      -std=c17 -O0 -g \
      -fsanitize=address,undefined \
      -fno-omit-frame-pointer \
      c/0001_memory_layout.c -o out
```

---

### Rust

| Tool | Version | Role |
|---|---|---|
| rustup | latest | Toolchain management |
| stable | latest stable | Primary builds |
| nightly | latest nightly | Miri · sanitizers · cargo-fuzz |
| clippy | bundled | Linting |
| cargo-audit | latest | Advisory DB scanning |
| cargo-fuzz | latest | Fuzzing harness |

**Local setup:**

```sh
rustup toolchain install stable nightly
rustup component add clippy rustfmt
rustup component add --toolchain nightly miri rust-src
```

**Local checks:**

```sh
cargo fmt --all -- --check
cargo clippy --all-targets --all-features -- -D warnings
cargo test --all-targets
```

---

### Python

| Tool | Version | Role |
|---|---|---|
| Python | 3.11 / 3.12 / 3.13 | Interpreter matrix |
| ruff | ≥ 0.4 | Linting |
| black | ≥ 24 | Formatting |
| mypy | ≥ 1.10 | Static type checking |
| pytest | ≥ 8 | Testing |
| pyperf | latest | Stable, low-noise benchmarking |
| Atheris | latest | Coverage-guided Python fuzzing |

**Local checks:**

```sh
pip install ruff black mypy pytest pyperf
ruff check python/
black --check python/
mypy python/ --ignore-missing-imports
pytest python/ -v
```

---

## Container Images

Pre-built images are published to GHCR on every push to `main`, built for `linux/amd64` and `linux/arm64`:

```
ghcr.io/mahobin/corelab/c-env:latest
ghcr.io/mahobin/corelab/rust-env:latest
ghcr.io/mahobin/corelab/python-env:latest
```

**Pull and run:**

```sh
# Drop into a C development shell with the workspace mounted
docker pull ghcr.io/mahobin/corelab/c-env:latest
docker run --rm -it \
  -v "$PWD:/workspace" \
  ghcr.io/mahobin/corelab/c-env:latest \
  bash

# Run the full Python test suite inside the container
docker run --rm \
  -v "$PWD:/workspace:ro" \
  ghcr.io/mahobin/corelab/python-env:latest \
  sh -c "cd /workspace && pytest python/ -v"
```

---

## Local Development

### Prerequisites

| Dependency | Minimum version | Notes |
|---|---|---|
| Git | 2.40 | — |
| GCC and/or Clang | 13 / 17 | Either suffices for most experiments |
| Rust (via rustup) | latest stable | [rustup.rs](https://rustup.rs) |
| Python | 3.11 | 3.12 or 3.13 recommended |
| Docker | any | Optional; needed for containerized workflows |

### Quick Start

```sh
git clone https://github.com/mahobin/corelab.git
cd corelab

# C — compile and run an isolated experiment
clang -Wall -std=c17 c/0001_memory_layout.c -o /tmp/mem_test && /tmp/mem_test

# Rust — lint a specific experiment file
rustc -W clippy::all rust/0001_ownership_move.rs

# Python — type-check and lint an experiment
pip install ruff mypy
mypy --strict python/0001_bytecode_dis.py
ruff check python/0001_bytecode_dis.py
```

### Editor Setup

**VS Code** — install `clangd`, `rust-analyzer`, and `Pylance`. A `compile_commands.json` is generated by the C CI job (Clang/debug/C17 cell) and downloadable from the Actions artifacts tab.

**Neovim** — `clangd` and `rust-analyzer` via `mason.nvim`; `pyright` or `basedpyright` for Python.

---

## Fuzzing

Fuzz targets live under `{lang}/fuzz/`. CI runs them on a weekly schedule; manual dispatch is also available with a configurable duration. Crash inputs are retained as `fuzz-crashes-*` artifacts.

**Running locally:**

```sh
# C — libFuzzer
clang -fsanitize=address,undefined,fuzzer -g \
      c/fuzz/fuzz_parser.c -o /tmp/fuzz_parser
mkdir -p /tmp/corpus
/tmp/fuzz_parser /tmp/corpus -max_total_time=60

# Rust — cargo-fuzz (requires nightly)
cd rust
cargo +nightly fuzz run fuzz_target_1 -- -max_total_time=60

# Python — Atheris
pip install atheris
python python/fuzz/fuzz_json.py -max_total_time=60
```

---

## Benchmarking

Benchmark results are uploaded as JSON artifacts and retained for 90 days, enabling trend comparison across commits.

**Running locally:**

```sh
# C — release build timed with hyperfine
gcc -O2 -DNDEBUG c/benchmarks/fib.c -o /tmp/bench_fib
hyperfine --warmup 3 /tmp/bench_fib

# Rust — Criterion
cd rust && cargo bench

# Python — pyperf
python python/benchmarks/bench_fib.py
```

---

## Security

The `security.yml` workflow runs on every push to `main` and on a scheduled basis:

- **CodeQL** — semantic analysis for C and Python
- **cargo-audit** — Rust dependency advisory scanning (RustSec DB)
- **pip-audit** — Python dependency vulnerability scanning (PyPA DB)
- **Dependency review** — blocks newly introduced vulnerable packages on every PR
- **SBOM generation** — software bill of materials exported per release

SARIF results are uploaded to the **Security → Code scanning** tab.

**Running locally:**

```sh
# Rust
cargo install cargo-audit
cargo audit --deny warnings

# Python
pip install pip-audit
pip-audit
```

---

## Documentation

Docs are built with [MkDocs Material](https://squidfunk.github.io/mkdocs-material/) and deployed to GitHub Pages on every push to `main`.

```sh
pip install mkdocs mkdocs-material
mkdocs serve           # local preview — http://localhost:8000
mkdocs build --strict  # full validation before pushing
```

---

## Contributing

This is a personal learning repository. Issues and discussion are welcome. Pull requests that fix bugs, improve documentation, or add well-scoped experiments are appreciated — please open an issue first for anything substantial.

**Code style is enforced by CI:**

- C — must pass `clang-format`
- Rust — must pass `cargo fmt` and `cargo clippy -- -D warnings`
- Python — must pass `ruff` and `black --check`

---

## License

MIT — see [`LICENSE`](LICENSE).
