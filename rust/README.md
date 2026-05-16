# 🦀 Rust Architecture Lab

This directory focuses on modern systems programming with a emphasis on memory safety, concurrency, and zero-cost abstractions. We explore how the Borrow Checker replaces the manual management seen in the C lab.

## 🔬 Toolchain & Standards
- **Compiler:** `rustc` (Stable/Nightly)
- **Edition:** 2021/2024
- **Linter:** `clippy` (Pedantic profile)
- **Safety:** `Miri` for checking `unsafe` blocks; `cargo-audit` for dependencies.

## 📚 Primary Resources
- *The Rust Programming Language* (The Book)
- *Rust by Example*
- *The Rustonomicon* (for Unsafe studies)

## 🗂️ Experiment Log

| ID | File | Topic | Technical Details | Status |
|:---|:---|:---|:---|:---|
| 0001 | [`0001_hello_world.rs`](./0001_hello_world.rs) | Syntax | Macro expansion of `println!` and basic crate structure. | ✅ |

---
**Execution:** `make run-rust id=0001`
