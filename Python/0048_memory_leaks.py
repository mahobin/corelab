# 0048_memory_leaks
# NOTE: Refcounting frees most objects; reference cycles need the cyclic GC.

import gc


class Node:
    pass


a, b = Node(), Node()
a.other, b.other = b, a
del a, b
print("collected:", gc.collect())
