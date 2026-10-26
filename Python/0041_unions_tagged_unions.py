# 0041_unions_tagged_unions
# NOTE: No raw unions. Use union type hints; a tagged union is a tag plus a value.

from dataclasses import dataclass


@dataclass
class Num:
    value: float


@dataclass
class Text:
    value: str


Shape = Num | Text
for item in (Num(1.5), Text("hi")):
    match item:
        case Num(v):
            print("number", v)
        case Text(v):
            print("text", v)
