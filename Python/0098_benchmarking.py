# 0098_benchmarking

import time
import timeit

print(timeit.timeit("sum(range(1000))", number=10000))
t = time.perf_counter()
sum(range(10**6))
print(f"{time.perf_counter() - t:.4f}s")
