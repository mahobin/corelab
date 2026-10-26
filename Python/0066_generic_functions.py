# 0066_generic_functions

from typing import TypeVar

T = TypeVar("T")


def first(xs: list[T]) -> T:
    return xs[0]


print(first([1, 2]), first(["a"]))
