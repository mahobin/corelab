# 0053_lifetimes
# NOTE: No lifetime annotations. Objects live while referenced.

import weakref


class T:
    pass


def make():
    t = T()
    return weakref.ref(t)


print(make())  # None: t died when make() returned
