#!/usr/bin/env bash
# eval-scaffold — set up the working directory for a skill eval case
# (.claude/skills/*/evals/*/place-files.sh calls it; `claude plugin eval --scaffold`
# runs those). Copies this template's files (committed and untracked, not ignored)
# into the current directory, optionally adds the orders demo app, and commits.
#
# Usage: eval-scaffold.sh [--app]
set -eu

root="$(cd "$(dirname "$0")/../.." && pwd)"
dest="$(pwd)"
[ "$dest" != "$root" ] || { echo "eval-scaffold: refusing to run in the template itself" >&2; exit 1; }

git -C "$root" ls-files -co --exclude-standard -z | (cd "$root" && tar --null -T - -cf -) | tar -xf -
rm -rf .claude/skills/*/evals
if [ "${1:-}" = --app ]; then
  cp -R "$root/scripts/tests/fixtures/orders-app/." .
fi
git init -q -b master
git config user.email eval@example.com
git config user.name eval
git config commit.gpgsign false
git add -A
git commit -qm "Initial commit"
