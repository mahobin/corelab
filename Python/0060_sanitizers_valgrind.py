# 0060_sanitizers_valgrind
# NOTE: Closest equivalents: tracemalloc, faulthandler, python -X dev.

import faulthandler
import tracemalloc

faulthandler.enable()
tracemalloc.start()
x = [bytes(100) for _ in range(50)]
for stat in tracemalloc.take_snapshot().statistics("lineno")[:1]:
    print(stat)
