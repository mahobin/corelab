# 0099_cli_tool

import argparse

p = argparse.ArgumentParser(description="Greeter")
p.add_argument("name")
p.add_argument("-n", "--times", type=int, default=1)
p.add_argument("-v", "--verbose", action="store_true")
args = p.parse_args(["Ada", "-n", "2", "-v"])
for _ in range(args.times):
    print("hello", args.name)
print(args)
