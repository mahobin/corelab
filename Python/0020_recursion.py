# 0020_recursion


def fact(n):
    return 1 if n <= 1 else n * fact(n - 1)


print(fact(10))
