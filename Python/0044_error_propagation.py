# 0044_error_propagation
# NOTE: Exceptions propagate automatically; no ? or try needed.


def parse(s):
    return int(s)


def double(s):
    return parse(s) * 2


try:
    print(double("21"))
    print(double("x"))
except ValueError as e:
    print("error:", e)
