# 0043_error_codes_results
# NOTE: Python prefers exceptions; this shows the C/Rust-style result tuple.


def safe_div(a, b):
    return (False, "div by zero") if b == 0 else (True, a / b)


ok, val = safe_div(1, 0)
print(ok, val)
