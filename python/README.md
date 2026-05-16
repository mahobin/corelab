# 🐍 Python Runtimes Lab

This directory explores the CPython interpreter, language internals, and high-level abstractions. Instead of simple scripting, we focus on bytecode analysis and the Python Data Model.

## 🔬 Toolchain & Standards
- **Interpreter:** CPython 3.11+
- **Static Analysis:** `mypy` (Strict mode)
- **Linting:** `ruff` and `black`
- **Internal Tools:** `dis` module for disassembly; `sys` for object inspection.

## 📚 Primary Resources
- *Fluent Python* (Luciano Ramalho)
- *Python Cookbook* (Beazley & Jones)
- *CPython Internals* (Anthony Shaw)

## 🗂️ Experiment Log

| ID | File | Topic | Technical Details | Status |
|:---|:---|:---|:---|:---|
| 0001 | [`0001_hello_world.py`](./0001_hello_world.py) | Runtime | Print Hello World. | ✅ |

---
**Execution:** `make run-py id=0001`
