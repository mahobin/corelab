# 0086_traits_interfaces
# NOTE: Closest equivalents: Protocol (structural) and ABC (nominal).

from typing import Protocol


class Speaker(Protocol):
    def speak(self) -> str: ...
class Dog:
    def speak(self):
        return "woof"


class Cat:
    def speak(self):
        return "meow"


def talk(s: Speaker):
    print(s.speak())


talk(Dog())
talk(Cat())
