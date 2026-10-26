# 0087_operator_overloading
# NOTE: Dunder methods (Rust uses std::ops traits; C and Zig use named functions).


class Vec:
    def __init__(self, x, y):
        self.x, self.y = x, y

    def __add__(self, o):
        return Vec(self.x + o.x, self.y + o.y)

    def __eq__(self, o):
        return (self.x, self.y) == (o.x, o.y)

    def __repr__(self):
        return f"Vec({self.x}, {self.y})"


print(Vec(1, 2) + Vec(3, 4), Vec(1, 1) == Vec(1, 1))
