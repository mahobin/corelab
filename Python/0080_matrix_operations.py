# 0080_matrix_operations


def matmul(a, b):
    return [[sum(x * y for x, y in zip(row, col)) for col in zip(*b)] for row in a]


a, b = [[1, 2], [3, 4]], [[5, 6], [7, 8]]
print(matmul(a, b), [list(r) for r in zip(*a)])
