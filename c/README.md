# ⚙️ C Systems Lab

This directory is dedicated to the study of low-level systems programming, manual memory management, and the C runtime environment. The objective is to understand the hardware-software interface.

## 🔬 Toolchain & Standards
- **Compiler:** `clang` 17 / `gcc` 13
- **Standard:** C17 (`-std=c17`)
- **Safety:** AddressSanitizer (ASan) and UndefinedBehaviorSanitizer (UBSan)
- **Analysis:** `valgrind` for leak detection; `cppcheck` for static analysis

## 📚 Primary Resources
- *The C Programming Language* (K&R)
- *Modern C* (Jens Gustedt)
- *Expert C Programming* (Peter van der Linden)

## 🗂️ Experiment Log

| ID | File | Topic | Technical Details | Status |
|:---|:---|:---|:---|:---|
| 0001 | [`0001_hello_world.c`](./0001_hello_world.c) | Entry Point | Analysis of `main` signature and `stdio` buffering. | ✅ |

---
**Execution:** `make run-c id=0001`
