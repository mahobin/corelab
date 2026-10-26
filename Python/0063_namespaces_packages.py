# 0063_namespaces_packages
# NOTE: Modules and packages are namespaces; SimpleNamespace is an ad hoc one.

from types import SimpleNamespace

cfg = SimpleNamespace(host="localhost", port=80)
print(cfg.host, cfg)
