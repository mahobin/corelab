# 0037_pass_by_value_reference
# NOTE: Python passes object references by value ("pass by assignment").


def mutate(lst):
    lst.append(1)


def rebind(n):
    n = n + 1


l, n = [], 5
mutate(l)
rebind(n)
print(l, n)
