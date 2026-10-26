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
| 0001 | [`0001_hello_world.py`](./0001_hello_world.py) | Hello World | Print text and learn the compile-and-run cycle. print(); no compile step. | ✅ |
| 0002 | [`0002_comments.py`](./0002_comments.py) | Comments | Annotate code in ways the compiler ignores. # for lines; docstrings document functions and modules. | ✅ |
| 0003 | [`0003_variables.py`](./0003_variables.py) | Variables | Name a piece of storage and put a value in it. No declaration or type; names are rebound freely. | ✅ |
| 0004 | [`0004_constants.py`](./0004_constants.py) | Constants | Values that must never change. Uppercase convention only; Final is a type-checker hint. | ✅ |
| 0005 | [`0005_integer_types.py`](./0005_integer_types.py) | Integer Types | Whole-number types, their sizes and overflow behavior. Arbitrary precision; use ctypes for fixed widths. | ✅ |
| 0006 | [`0006_float_types.py`](./0006_float_types.py) | Float Types | Floating-point numbers and their precision limits. float is a 64-bit double. | ✅ |
| 0007 | [`0007_char_bool.py`](./0007_char_bool.py) | Char Bool | Single characters and true/false values. No char type; a char is a length-1 str. | ✅ |
| 0008 | [`0008_type_casting.py`](./0008_type_casting.py) | Type Casting | Converting a value from one type to another. int(), float(), str(). | ✅ |
| 0009 | [`0009_arithmetic_operators.py`](./0009_arithmetic_operators.py) | Arithmetic Operators | Math operators: + - * / %. / is true division, // floors, ** is power. | ✅ |
| 0010 | [`0010_comparison_logical.py`](./0010_comparison_logical.py) | Comparison Logical | Comparing values and combining conditions. Chained comparisons; and, or, not. | ✅ |
| 0011 | [`0011_bitwise_operators.py`](./0011_bitwise_operators.py) | Bitwise Operators | Working with individual bits. & \| ^ ~ << >> on unbounded ints. | ✅ |
| 0012 | [`0012_if_else.py`](./0012_if_else.py) | If Else | Choose between code paths. elif; indentation defines blocks. | ✅ |
| 0013 | [`0013_switch_match.py`](./0013_switch_match.py) | Switch Match | Pick among many cases. match (3.10+) with structural patterns. | ✅ |
| 0014 | [`0014_while_loop.py`](./0014_while_loop.py) | While Loop | Repeat while a condition holds. while only; no do-while. | ✅ |
| 0015 | [`0015_for_loop.py`](./0015_for_loop.py) | For Loop | Repeat a fixed number of times or over a collection. for x in iterable; range(). | ✅ |
| 0016 | [`0016_break_continue.py`](./0016_break_continue.py) | Break Continue | Exit or skip loop iterations. else clause on loops runs if no break. | ✅ |
| 0017 | [`0017_nested_loops.py`](./0017_nested_loops.py) | Nested Loops | Loops inside loops, and escaping both. No labels; use a function and return. | ✅ |
| 0018 | [`0018_functions_basic.py`](./0018_functions_basic.py) | Functions Basic | Reusable named blocks of code. def. | ✅ |
| 0019 | [`0019_params_return_values.py`](./0019_params_return_values.py) | Params Return Values | Passing data in and getting results out. Tuples, defaults, *args, **kwargs. | ✅ |
| 0020 | [`0020_recursion.py`](./0020_recursion.py) | Recursion | A function that calls itself. Recursion limit around 1000 frames. | ✅ |
| 0021 | [`0021_scope_shadowing.py`](./0021_scope_shadowing.py) | Scope Shadowing | Where a name is visible and when it hides another. LEGB lookup; global and nonlocal keywords. | ✅ |
| 0022 | [`0022_print_formatting.py`](./0022_print_formatting.py) | Print Formatting | Formatted output. f-strings. | ✅ |
| 0023 | [`0023_read_stdin.py`](./0023_read_stdin.py) | Read Stdin | Reading user input. input() or sys.stdin. | ✅ |
| 0024 | [`0024_command_line_args.py`](./0024_command_line_args.py) | Command Line Args | Receiving arguments from the command line. sys.argv. | ✅ |
| 0025 | [`0025_number_guessing_game.py`](./0025_number_guessing_game.py) | Number Guessing Game | Combine loops, input, and randomness in a small game. random module. | ✅ |
| 0026 | [`0026_arrays_basic.py`](./0026_arrays_basic.py) | Arrays Basic | Fixed or growable sequences of one type. list. | ✅ |
| 0027 | [`0027_array_iteration.py`](./0027_array_iteration.py) | Array Iteration | Walk through all elements. for x in list. | ✅ |
| 0028 | [`0028_multidimensional_arrays.py`](./0028_multidimensional_arrays.py) | Multidimensional Arrays | Grids and matrices. List of lists. | ✅ |
| 0029 | [`0029_array_sorting.py`](./0029_array_sorting.py) | Array Sorting | Putting items in order. sorted() and list.sort(). | ✅ |
| 0030 | [`0030_binary_search.py`](./0030_binary_search.py) | Binary Search | Find an item in sorted data in O(log n). bisect module. | ✅ |
| 0031 | [`0031_strings_basic.py`](./0031_strings_basic.py) | Strings Basic | Text basics. Immutable Unicode str. | ✅ |
| 0032 | [`0032_string_manipulation.py`](./0032_string_manipulation.py) | String Manipulation | Case, replace, split, join. Rich built-in methods. | ✅ |
| 0033 | [`0033_string_parsing.py`](./0033_string_parsing.py) | String Parsing | Extract values from text. split(), int(). | ✅ |
| 0034 | [`0034_pointers_basics.py`](./0034_pointers_basics.py) | Pointers Basics | Variables that hold memory addresses. No pointers; names reference objects. | ✅ |
| 0035 | [`0035_pointer_arithmetic_slices.py`](./0035_pointer_arithmetic_slices.py) | Pointer Arithmetic Slices | Moving through memory and views of data. Slicing copies; memoryview does not. | ✅ |
| 0036 | [`0036_references_borrowing.py`](./0036_references_borrowing.py) | References Borrowing | Accessing data without owning it. Aliasing; no borrowing rules. | ✅ |
| 0037 | [`0037_pass_by_value_reference.py`](./0037_pass_by_value_reference.py) | Pass By Value Reference | How arguments reach functions. By assignment of references. | ✅ |
| 0038 | [`0038_structs.py`](./0038_structs.py) | Structs | Grouping related fields. dataclass. | ✅ |
| 0039 | [`0039_nested_structs.py`](./0039_nested_structs.py) | Nested Structs | Structs containing structs. Nested dataclasses. | ✅ |
| 0040 | [`0040_enums.py`](./0040_enums.py) | Enums | Named constants or variants. enum.Enum. | ✅ |
| 0041 | [`0041_unions_tagged_unions.py`](./0041_unions_tagged_unions.py) | Unions Tagged Unions | A value that is one of several types. Union type hints. | ✅ |
| 0042 | [`0042_optional_values.py`](./0042_optional_values.py) | Optional Values | A value that might not exist. None. | ✅ |
| 0043 | [`0043_error_codes_results.py`](./0043_error_codes_results.py) | Error Codes Results | Failure as a return value. Exceptions are normal; tuples are optional. | ✅ |
| 0044 | [`0044_error_propagation.py`](./0044_error_propagation.py) | Error Propagation | Passing failures up the call stack. Exceptions propagate on their own. | ✅ |
| 0045 | [`0045_struct_methods.py`](./0045_struct_methods.py) | Struct Methods | Functions attached to a type. Methods in a class. | ✅ |
| 0046 | [`0046_stack_vs_heap.py`](./0046_stack_vs_heap.py) | Stack Vs Heap | Where memory lives and how long. Objects always on heap. | ✅ |
| 0047 | [`0047_heap_allocation.py`](./0047_heap_allocation.py) | Heap Allocation | Memory requested at runtime. Implicit. | ✅ |
| 0048 | [`0048_memory_leaks.py`](./0048_memory_leaks.py) | Memory Leaks | Memory never released. Cycles are collected by the GC. | ✅ |
| 0049 | [`0049_dangling_pointers.py`](./0049_dangling_pointers.py) | Dangling Pointers | Pointer to memory that is gone. A dead weakref returns None. | ✅ |
| 0050 | [`0050_use_after_free.py`](./0050_use_after_free.py) | Use After Free | Using memory after freeing it. Closed file raises ValueError. | ✅ |
| 0051 | [`0051_ownership.py`](./0051_ownership.py) | Ownership | Who is responsible for freeing. Reference counting. | ✅ |
| 0052 | [`0052_move_semantics.py`](./0052_move_semantics.py) | Move Semantics | Handing ownership to someone else. Rebinding names. | ✅ |
| 0053 | [`0053_lifetimes.py`](./0053_lifetimes.py) | Lifetimes | How long a reference stays valid. Handled by the GC. | ✅ |
| 0054 | [`0054_allocators.py`](./0054_allocators.py) | Allocators | Choosing where memory comes from. Not exposed. | ✅ |
| 0055 | [`0055_raii_defer_drop.py`](./0055_raii_defer_drop.py) | Raii Defer Drop | Cleanup that runs automatically. with statements and try/finally. | ✅ |
| 0056 | [`0056_smart_pointers.py`](./0056_smart_pointers.py) | Smart Pointers | Pointers that manage ownership. Built-in refcount; weakref. | ✅ |
| 0057 | [`0057_string_builder.py`](./0057_string_builder.py) | String Builder | Efficient string building. Collect parts and join. | ✅ |
| 0058 | [`0058_memory_pool.py`](./0058_memory_pool.py) | Memory Pool | Reusing fixed-size objects. List-based object pool. | ✅ |
| 0059 | [`0059_arena_allocator.py`](./0059_arena_allocator.py) | Arena Allocator | Allocating many things and freeing at once. bytearray with a bump offset. | ✅ |
| 0060 | [`0060_sanitizers_valgrind.py`](./0060_sanitizers_valgrind.py) | Sanitizers Valgrind | Tools that catch memory bugs. tracemalloc and faulthandler. | ✅ |
| 0061 | [`0061_modules_multi_file.py`](./0061_modules_multi_file.py) | Modules Multi File | Splitting a program across files. import. | ✅ |
| 0062 | [`0062_headers_imports.py`](./0062_headers_imports.py) | Headers Imports | Sharing declarations between files. import and from-import. | ✅ |
| 0063 | [`0063_namespaces_packages.py`](./0063_namespaces_packages.py) | Namespaces Packages | Organizing names to avoid collisions. Modules and packages. | ✅ |
| 0064 | [`0064_build_systems.py`](./0064_build_systems.py) | Build Systems | Compiling and linking a project. pyproject.toml; no build step. | ✅ |
| 0065 | [`0065_generics_basic.py`](./0065_generics_basic.py) | Generics Basic | Code that works for many types. Type hints only. | ✅ |
| 0066 | [`0066_generic_functions.py`](./0066_generic_functions.py) | Generic Functions | A function that works for many types. Duck typing. | ✅ |
| 0067 | [`0067_generic_containers.py`](./0067_generic_containers.py) | Generic Containers | A container that works for many types. Generic[T]. | ✅ |
| 0068 | [`0068_dynamic_array.py`](./0068_dynamic_array.py) | Dynamic Array | A growable array built by hand. List-backed class. | ✅ |
| 0069 | [`0069_stack.py`](./0069_stack.py) | Stack | Last in, first out. List append and pop. | ✅ |
| 0070 | [`0070_queue.py`](./0070_queue.py) | Queue | First in, first out. collections.deque. | ✅ |
| 0071 | [`0071_linked_list.py`](./0071_linked_list.py) | Linked List | Nodes linked by pointers. Node class. | ✅ |
| 0072 | [`0072_doubly_linked_list.py`](./0072_doubly_linked_list.py) | Doubly Linked List | Nodes with prev and next links. prev and next attributes. | ✅ |
| 0073 | [`0073_hash_map.py`](./0073_hash_map.py) | Hash Map | Key-value lookup by hashing. dict. | ✅ |
| 0074 | [`0074_binary_tree.py`](./0074_binary_tree.py) | Binary Tree | Hierarchical nodes ordered for search. Node class. | ✅ |
| 0075 | [`0075_priority_queue_heap.py`](./0075_priority_queue_heap.py) | Priority Queue Heap | Always get the smallest or largest. heapq (min-heap). | ✅ |
| 0076 | [`0076_graph_bfs_dfs.py`](./0076_graph_bfs_dfs.py) | Graph Bfs Dfs | Walking a graph breadth-first and depth-first. dict plus deque. | ✅ |
| 0077 | [`0077_sort_bubble_insertion.py`](./0077_sort_bubble_insertion.py) | Sort Bubble Insertion | Simple O(n^2) sorts. Tuple swap. | ✅ |
| 0078 | [`0078_sort_merge_quick.py`](./0078_sort_merge_quick.py) | Sort Merge Quick | Faster divide-and-conquer sorts. Slicing copies. | ✅ |
| 0079 | [`0079_string_search.py`](./0079_string_search.py) | String Search | Finding a pattern in text. str.find. | ✅ |
| 0080 | [`0080_matrix_operations.py`](./0080_matrix_operations.py) | Matrix Operations | Matrix math. Nested lists. | ✅ |
| 0081 | [`0081_prime_sieve.py`](./0081_prime_sieve.py) | Prime Sieve | Find primes with a sieve. List of bools. | ✅ |
| 0082 | [`0082_fibonacci_memoization.py`](./0082_fibonacci_memoization.py) | Fibonacci Memoization | Cache results of expensive calls. functools.lru_cache. | ✅ |
| 0083 | [`0083_bit_tricks.py`](./0083_bit_tricks.py) | Bit Tricks | Clever bit operations. bin(n).count("1"). | ✅ |
| 0084 | [`0084_iterators.py`](./0084_iterators.py) | Iterators | Uniform way to step through a collection. Iterator protocol and generators. | ✅ |
| 0085 | [`0085_closures_lambdas.py`](./0085_closures_lambdas.py) | Closures Lambdas | Functions that carry data with them. lambda and nested functions. | ✅ |
| 0086 | [`0086_traits_interfaces.py`](./0086_traits_interfaces.py) | Traits Interfaces | Shared behavior across different types. Protocol or ABC. | ✅ |
| 0087 | [`0087_operator_overloading.py`](./0087_operator_overloading.py) | Operator Overloading | Making operators work on your types. Dunder methods like __add__. | ✅ |
| 0088 | [`0088_file_read_write.py`](./0088_file_read_write.py) | File Read Write | Reading and writing text files. open() with context manager. | ✅ |
| 0089 | [`0089_binary_file_io.py`](./0089_binary_file_io.py) | Binary File Io | Reading and writing raw bytes. struct.pack and unpack. | ✅ |
| 0090 | [`0090_csv_parser.py`](./0090_csv_parser.py) | Csv Parser | Parse comma-separated values. csv module. | ✅ |
| 0091 | [`0091_json_parser.py`](./0091_json_parser.py) | Json Parser | Parse JSON text. json module. | ✅ |
| 0092 | [`0092_threads_basic.py`](./0092_threads_basic.py) | Threads Basic | Run code concurrently. threading; the GIL limits CPU parallelism. | ✅ |
| 0093 | [`0093_mutexes.py`](./0093_mutexes.py) | Mutexes | Protect shared data. threading.Lock. | ✅ |
| 0094 | [`0094_atomics.py`](./0094_atomics.py) | Atomics | Lock-free shared counters. No atomics; emulate with a lock. | ✅ |
| 0095 | [`0095_message_passing.py`](./0095_message_passing.py) | Message Passing | Threads communicating without shared state. queue.Queue. | ✅ |
| 0096 | [`0096_ffi_c_interop.py`](./0096_ffi_c_interop.py) | Ffi C Interop | Calling code written in C. ctypes. | ✅ |
| 0097 | [`0097_unit_testing.py`](./0097_unit_testing.py) | Unit Testing | Automated checks for correctness. unittest or pytest. | ✅ |
| 0098 | [`0098_benchmarking.py`](./0098_benchmarking.py) | Benchmarking | Measuring performance. timeit and perf_counter. | ✅ |
| 0099 | [`0099_cli_tool.py`](./0099_cli_tool.py) | Cli Tool | A real command-line program with flags. argparse. | ✅ |
| 0100 | [`0100_tcp_echo_server.py`](./0100_tcp_echo_server.py) | Tcp Echo Server | Accept a connection and echo bytes back. socket module. | ✅ |

---
**Execution:** `make run-py id=0001`
