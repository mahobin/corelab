# 0074_binary_tree


class Node:
    def __init__(self, v):
        self.v, self.l, self.r = v, None, None


def insert(n, v):
    if n is None:
        return Node(v)
    if v < n.v:
        n.l = insert(n.l, v)
    else:
        n.r = insert(n.r, v)
    return n


def inorder(n):
    if n:
        yield from inorder(n.l)
        yield n.v
        yield from inorder(n.r)


root = None
for v in [5, 2, 8, 1, 9]:
    root = insert(root, v)
print(list(inorder(root)))
