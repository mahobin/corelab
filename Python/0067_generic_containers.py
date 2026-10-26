# 0067_generic_containers

from typing import Generic, TypeVar

T = TypeVar("T")


class Stack(Generic[T]):
    def __init__(self):
        self.items: list[T] = []

    def push(self, x: T):
        self.items.append(x)

    def pop(self) -> T:
        return self.items.pop()


s = Stack[int]()
s.push(1)
s.push(2)
print(s.pop())
