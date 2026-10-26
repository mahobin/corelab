# 0059_arena_allocator


class Arena:
    def __init__(self, size):
        self.buf = bytearray(size)
        self.off = 0

    def alloc(self, n):
        view = memoryview(self.buf)[self.off : self.off + n]
        self.off += n
        return view

    def reset(self):
        self.off = 0


arena = Arena(64)
x = arena.alloc(16)
x[0] = 7
print(arena.off)
arena.reset()
print(arena.off)
