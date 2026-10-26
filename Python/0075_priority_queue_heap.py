# 0075_priority_queue_heap

import heapq

h = []
for x in [5, 1, 3]:
    heapq.heappush(h, x)
print([heapq.heappop(h) for _ in range(3)])
