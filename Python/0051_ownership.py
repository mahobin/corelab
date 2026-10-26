# 0051_ownership
# NOTE: Shared ownership by refcount; the last reference frees the object.

import sys

a = []
b = a
print(sys.getrefcount(a) - 1)
del b
print(sys.getrefcount(a) - 1)
