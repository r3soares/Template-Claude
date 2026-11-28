#!/usr/bin/env bash
# Scaffold for this eval case: a throwaway copy of the template (see
# scripts/tests/eval-scaffold.sh), plus the case's starting state.
set -eu
root="$(cd "$(dirname "$0")/../../../../.." && pwd)"
"$root/scripts/tests/eval-scaffold.sh" --app
sed -i 's/body.get("item")/body.get("name")/' src/server.py
git commit -qam "feat: orders API"
