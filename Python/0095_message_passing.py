# 0095_message_passing
# NOTE: queue.Queue is the channel equivalent.

import queue
import threading

q = queue.Queue()


def producer():
    for i in range(3):
        q.put(i)
    q.put(None)


threading.Thread(target=producer).start()
while (item := q.get()) is not None:
    print("got", item)
