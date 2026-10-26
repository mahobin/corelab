# 0091_json_parser
# NOTE: Python ships json; C/C++/Zig/Rust versions should hand-write a parser or use a library.

import json

doc = json.loads('{"name": "Ada", "langs": ["py", "c"], "age": 36}')
print(doc["name"], doc["langs"])
print(json.dumps(doc, indent=2))
