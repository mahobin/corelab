# 0052_move_semantics
# NOTE: No moves. Rebinding and del emulate a transfer.

a = [1, 2, 3]
b, a = a, None
print(a, b)
