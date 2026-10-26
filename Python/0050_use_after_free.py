# 0050_use_after_free
# NOTE: Closest equivalent: using a closed resource. Raises instead of corrupting memory.

import io

f = io.StringIO("data")
f.close()
try:
    f.read()
except ValueError as e:
    print("error:", e)
