# 0035_pointer_arithmetic_slices
# NOTE: No pointer arithmetic. Slices copy; memoryview slices without copying.

data = bytearray(b"abcdef")
view = memoryview(data)[2:5]
view[0] = ord("X")
print(data, bytes(view))
