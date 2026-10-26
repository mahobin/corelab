# 0038_structs
# NOTE: dataclass is the closest equivalent.

from dataclasses import dataclass


@dataclass
class Point:
    x: float
    y: float


p = Point(1.0, 2.0)
print(p, p.x)
