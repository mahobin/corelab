# 0094_atomics
# NOTE: Python has no atomic types. A lock-based AtomicInt emulates one.

import threading


class AtomicInt:
    def __init__(self, v=0):
        self._v, self._l = v, threading.Lock()

    def add(self, n):
        with self._l:
            self._v += n
            return self._v

    def get(self):
        with self._l:
            return self._v


a = AtomicInt()
ts = [
    threading.Thread(target=lambda: [a.add(1) for _ in range(1000)]) for _ in range(4)
]
for t in ts:
    t.start()
for t in ts:
    t.join()
print(a.get())
