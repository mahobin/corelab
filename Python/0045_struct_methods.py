# 0045_struct_methods


class Counter:
    def __init__(self):
        self.n = 0

    def inc(self):
        self.n += 1
        return self


c = Counter().inc().inc()
print(c.n)
