# 0058_memory_pool


class Pool:
    def __init__(self, factory, n):
        self.free = [factory() for _ in range(n)]

    def acquire(self):
        return self.free.pop()

    def release(self, o):
        self.free.append(o)


p = Pool(bytearray, 2)
a = p.acquire()
p.release(a)
print(len(p.free))
