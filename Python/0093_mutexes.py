# 0093_mutexes

import threading

count, lock = 0, threading.Lock()


def inc():
    global count
    for _ in range(10000):
        with lock:
            count += 1


ts = [threading.Thread(target=inc) for _ in range(4)]
for t in ts:
    t.start()
for t in ts:
    t.join()
print(count)
