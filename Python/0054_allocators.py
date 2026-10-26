# 0054_allocators
# NOTE: No custom allocators. tracemalloc shows allocations instead.

import tracemalloc

tracemalloc.start()
data = [bytes(1000) for _ in range(100)]
cur, peak = tracemalloc.get_traced_memory()
print(f"current={cur} peak={peak}")
