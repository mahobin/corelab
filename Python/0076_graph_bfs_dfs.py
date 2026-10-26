# 0076_graph_bfs_dfs

from collections import deque

g = {1: [2, 3], 2: [4], 3: [4], 4: []}


def bfs(s):
    seen, q, out = {s}, deque([s]), []
    while q:
        n = q.popleft()
        out.append(n)
        for m in g[n]:
            if m not in seen:
                seen.add(m)
                q.append(m)
    return out


def dfs(n, seen=None):
    seen = seen if seen is not None else set()
    seen.add(n)
    out = [n]
    for m in g[n]:
        if m not in seen:
            out += dfs(m, seen)
    return out


print(bfs(1), dfs(1))
