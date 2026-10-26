# 0034_pointers_basics
# NOTE: No raw pointers. Variables are references to objects; id() shows identity.

a = [1, 2]
b = a
print(id(a) == id(b), a is b)
b.append(3)
print(a)
