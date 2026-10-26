# 0033_string_parsing

data = "name=Ada;age=36;lang=py"
parsed = dict(pair.split("=") for pair in data.split(";"))
print(parsed, int(parsed["age"]))
