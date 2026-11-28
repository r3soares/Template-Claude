#!/usr/bin/env bash
# Scaffold for this eval case: a throwaway copy of the template (see
# scripts/tests/eval-scaffold.sh), plus the case's starting state.
set -eu
root="$(cd "$(dirname "$0")/../../../../.." && pwd)"
"$root/scripts/tests/eval-scaffold.sh" --app
python3 - <<'PY'
import pathlib
p = pathlib.Path("src/server.py")
s = p.read_text()
s = s.replace('    ("GET", "/orders"): list_orders,\n    ("POST", "/orders"): create_order,\n', '')
p.write_text(s)
PY
git commit -qam "feat: orders API"
git checkout HEAD~1 -- src/server.py
