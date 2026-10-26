# 0092_threads_basic

import threading


def work(n):
    print("worker", n)


ts = [threading.Thread(target=work, args=(i,)) for i in range(3)]
for t in ts:
    t.start()
for t in ts:
    t.join()
