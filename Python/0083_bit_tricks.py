# 0083_bit_tricks

n = 0b101100
print(n & (n - 1), n & -n, bin(n).count("1"), n.bit_length(), (n & (n - 1)) == 0)
