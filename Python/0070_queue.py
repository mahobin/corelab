# 0070_queue

from collections import deque

q = deque()
q.append(1)
q.append(2)
print(q.popleft(), q.popleft())
