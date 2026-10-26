# 0065_generics_basic
# NOTE: Generics are type hints only; runtime is duck typed.

from typing import Generic, TypeVar

T = TypeVar("T")


class Box(Generic[T]):
    def __init__(self, v: T):
        self.v = v


print(Box(1).v, Box("a").v)
