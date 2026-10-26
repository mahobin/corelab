# 0072_doubly_linked_list


class Node:
    def __init__(self, v):
        self.v, self.prev, self.next = v, None, None


class DList:
    def __init__(self):
        self.head = self.tail = None

    def append(self, v):
        n = Node(v)
        if self.tail:
            self.tail.next, n.prev = n, self.tail
        else:
            self.head = n
        self.tail = n

    def backward(self):
        n = self.tail
        while n:
            yield n.v
            n = n.prev


d = DList()
for i in range(3):
    d.append(i)
print(list(d.backward()))
