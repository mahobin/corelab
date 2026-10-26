# 0046_stack_vs_heap
# NOTE: Every object lives on the heap; locals are only names on the call stack.

import sys

x = 5
lst = [1, 2, 3]
print(id(x), sys.getsizeof(x), sys.getsizeof(lst))
