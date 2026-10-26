# 0077_sort_bubble_insertion


def bubble(a):
    a = a[:]
    for i in range(len(a)):
        for j in range(len(a) - 1 - i):
            if a[j] > a[j + 1]:
                a[j], a[j + 1] = a[j + 1], a[j]
    return a


def insertion(a):
    a = a[:]
    for i in range(1, len(a)):
        k, j = a[i], i - 1
        while j >= 0 and a[j] > k:
            a[j + 1] = a[j]
            j -= 1
        a[j + 1] = k
    return a


print(bubble([3, 1, 2]), insertion([3, 1, 2]))
