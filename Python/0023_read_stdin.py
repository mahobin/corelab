# 0023_read_stdin

import sys

line = sys.stdin.readline().strip() or "world"
print(f"hello, {line}")
