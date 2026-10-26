# 0089_binary_file_io

import os
import struct
import tempfile

path = os.path.join(tempfile.gettempdir(), "demo.bin")
with open(path, "wb") as f:
    f.write(struct.pack("<Ihf", 7, -2, 1.5))
with open(path, "rb") as f:
    print(struct.unpack("<Ihf", f.read()))
os.remove(path)
