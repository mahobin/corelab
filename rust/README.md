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
| 0001 | [`0001_hello_world.rs`](./0001_hello_world.rs) | Syntax | Demonstrates Rust entry point via `fn main()`, use of the standard output macro `println!`, macro expansion behavior, and basic crate-level execution model in a single binary target. | ✅ |
| 0002 | [`0002_simple_sum.rs`](./0002_simple_sum.rs) | Simple Sum | Implements integer arithmetic using immutable bindings (`let a`, `let b`), expression-based evaluation, ownership-safe value copying for primitive integers, and formatted output using `println!` macro with placeholder substitution (`{}`). | ✅ |

---
**Execution:** `make run-rust id=0001`
