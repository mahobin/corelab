# 0049_dangling_pointers
# NOTE: Closest equivalent: a weak reference to a dead object.

import weakref


class Obj:
    pass


o = Obj()
ref = weakref.ref(o)
print(ref() is o)
del o
print(ref())  # None: dead
