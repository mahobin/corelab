# 0042_optional_values
# NOTE: Optional[T] is just T | None.


def find(xs, t):
    return xs.index(t) if t in xs else None


r = find([1, 2, 3], 5)
print(r if r is not None else "not found")
