# 0084_iterators
# NOTE: Python has the iterator protocol and generators built in.


class Countdown:
    def __init__(self, n):
        self.n = n

    def __iter__(self):
        return self

    def __next__(self):
        if self.n <= 0:
            raise StopIteration
        self.n -= 1
        return self.n + 1


print(list(Countdown(3)))
print(list(x * x for x in range(4)))
