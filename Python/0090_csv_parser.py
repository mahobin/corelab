# 0090_csv_parser

import csv
import io

text = "name,age\nAda,36\nLinus,55\n"
for row in csv.DictReader(io.StringIO(text)):
    print(row["name"], int(row["age"]))
