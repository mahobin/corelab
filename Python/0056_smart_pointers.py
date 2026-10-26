# 0056_smart_pointers
# NOTE: Closest equivalent: weakref plus built-in refcounting.

import weakref


class Data:
    pass


d = Data()
w = weakref.ref(d)
print(w() is d)
