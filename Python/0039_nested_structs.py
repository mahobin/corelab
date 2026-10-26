# 0039_nested_structs

from dataclasses import dataclass


@dataclass
class Point:
    x: int
    y: int


@dataclass
class Rect:
    top_left: Point
    size: Point


r = Rect(Point(0, 0), Point(4, 3))
print(r, r.size.x * r.size.y)
