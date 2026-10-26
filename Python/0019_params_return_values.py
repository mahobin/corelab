# 0019_params_return_values


def stats(a, b=1, *rest, **opts):
    return a + b, len(rest), opts


total, n, opts = stats(1, 2, 3, 4, x=9)
print(total, n, opts)
