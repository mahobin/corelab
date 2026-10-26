# 0021_scope_shadowing

x = 1


def shadow():
    x = 2  # new local, shadows global
    return x


def modify():
    global x
    x = 3


print(shadow(), x)
modify()
print(x)
