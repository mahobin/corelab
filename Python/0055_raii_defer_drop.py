# 0055_raii_defer_drop
# NOTE: with and try/finally are Python's RAII/defer.

from contextlib import contextmanager


@contextmanager
def resource(name):
    print("acquire", name)
    try:
        yield name
    finally:
        print("release", name)


with resource("db") as r:
    print("using", r)
