#!/usr/bin/env bash
# Scaffold for this eval case: a throwaway copy of the template (see
# scripts/tests/eval-scaffold.sh), plus the case's starting state.
set -eu
root="$(cd "$(dirname "$0")/../../../../.." && pwd)"
"$root/scripts/tests/eval-scaffold.sh"
rm SETUP.md
sed -i 's/^> Replace this line with the project identity.*/> **orders-api** — a tiny HTTP API to create and list orders./' CLAUDE.md
sed -i 's/Reply to the developer in: <language>/Reply to the developer in: English/' CLAUDE.md
git commit -qam "chore: bootstrap project from template"
git tag -a v0.1.0 -m "v0.1.0"
