# 0071_linked_list


class Node:
    def __init__(self, v, nxt=None):
        self.v, self.next = v, nxt


class LinkedList:
    def __init__(self):
        self.head = None

    def push_front(self, v):
        self.head = Node(v, self.head)

    def __iter__(self):
        n = self.head
        while n:
            yield n.v
            n = n.next


l = LinkedList()
for i in range(3):
    l.push_front(i)
print(list(l))
