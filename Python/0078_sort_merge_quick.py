# 0078_sort_merge_quick


def merge_sort(a):
    if len(a) <= 1:
        return a
    m = len(a) // 2
    l, r, out = merge_sort(a[:m]), merge_sort(a[m:]), []
    while l and r:
        out.append(l.pop(0) if l[0] <= r[0] else r.pop(0))
    return out + l + r


def quick(a):
    if len(a) <= 1:
        return a
    p = a[0]
    return (
        quick([x for x in a[1:] if x < p]) + [p] + quick([x for x in a[1:] if x >= p])
    )


print(merge_sort([5, 2, 9, 1]), quick([5, 2, 9, 1]))
