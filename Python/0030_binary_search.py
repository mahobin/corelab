# 0030_binary_search

import bisect


def bsearch(a, t):
    lo, hi = 0, len(a) - 1
    while lo <= hi:
        mid = (lo + hi) // 2
        if a[mid] == t:
            return mid
        if a[mid] < t:
            lo = mid + 1
        else:
            hi = mid - 1
    return -1


a = [1, 3, 5, 7, 9]
print(bsearch(a, 7), bisect.bisect_left(a, 7))
