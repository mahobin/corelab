# 0013_switch_match
# NOTE: Python 3.10+ has match.

cmd = "go"
match cmd:
    case "stop":
        print("stopping")
    case "go" | "run":
        print("going")
    case _:
        print("unknown")
