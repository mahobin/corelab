# 0061_modules_multi_file
# NOTE: Normally one .py file per module; this builds one in memory.

import types

m = types.ModuleType("helper")
exec("def hi(): return 'hi from helper'", m.__dict__)
print(m.hi())
