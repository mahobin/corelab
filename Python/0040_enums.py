# 0040_enums

from enum import Enum, auto


class Color(Enum):
    RED = auto()
    GREEN = auto()
    BLUE = auto()


print(Color.RED, Color.RED.value, list(Color))
