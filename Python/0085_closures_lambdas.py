# 0085_closures_lambdas


def make_adder(n):
    return lambda x: x + n


add5 = make_adder(5)
print(add5(10), list(map(lambda x: x * 2, [1, 2, 3])))
