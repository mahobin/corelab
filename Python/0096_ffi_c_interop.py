# 0096_ffi_c_interop
# NOTE: ctypes calls C libraries directly (Linux/macOS).

import ctypes

libc = ctypes.CDLL(None)
libc.strlen.argtypes = [ctypes.c_char_p]
libc.strlen.restype = ctypes.c_size_t
print(libc.strlen(b"hello"))
