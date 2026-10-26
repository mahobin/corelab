# 0088_file_read_write

import os
import tempfile

path = os.path.join(tempfile.gettempdir(), "demo.txt")
with open(path, "w") as f:
    f.write("line1\nline2\n")
with open(path) as f:
    for line in f:
        print(line.strip())
os.remove(path)
