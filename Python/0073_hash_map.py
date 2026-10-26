# 0073_hash_map


class HashMap:
    def __init__(self, n=8):
        self.buckets = [[] for _ in range(n)]

    def _b(self, k):
        return self.buckets[hash(k) % len(self.buckets)]

    def put(self, k, v):
        b = self._b(k)
        for pair in b:
            if pair[0] == k:
                pair[1] = v
                return
        b.append([k, v])

    def get(self, k, default=None):
        for kk, v in self._b(k):
            if kk == k:
                return v
        return default


m = HashMap()
m.put("a", 1)
m.put("a", 2)
print(m.get("a"), m.get("z"))
