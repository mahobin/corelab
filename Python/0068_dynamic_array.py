# 0068_dynamic_array


class DynArray:
    def __init__(self):
        self.cap, self.n, self.data = 2, 0, [None] * 2

    def push(self, x):
        if self.n == self.cap:
            self.cap *= 2
            new = [None] * self.cap
            new[: self.n] = self.data[: self.n]
            self.data = new
        self.data[self.n] = x
        self.n += 1

    def __getitem__(self, i):
        return self.data[i]


a = DynArray()
for i in range(5):
    a.push(i)
print(a.n, a.cap, a[4])
