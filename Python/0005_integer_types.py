# 0005_integer_types
# NOTE: Python int is arbitrary precision. Use ctypes for C-style fixed widths.

import ctypes

print(2**100)
print(ctypes.c_uint8(300).value)  # wraps like C: 44
print((255).bit_length())
