# 0079_string_search


def naive(text, pat):
    return [i for i in range(len(text) - len(pat) + 1) if text[i : i + len(pat)] == pat]


print(naive("abracadabra", "abra"), "abracadabra".find("cad"))
