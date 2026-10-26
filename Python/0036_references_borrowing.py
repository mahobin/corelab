# 0036_references_borrowing
# NOTE: No borrow checker. Aliases are free and mutation is visible through all of them.

a = [1, 2, 3]
alias = a
alias[0] = 99
print(a)
copy = a.copy()
copy[0] = 0
print(a, copy)
