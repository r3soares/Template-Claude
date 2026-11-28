#!/usr/bin/env bash
# Self-tests for scripts/default-branch: origin/HEAD first, then the remote's HEAD,
# then local branches; ambiguity is an error, never a guess.

# shellcheck source=scripts/tests/lib.sh
. "$(dirname "$0")/lib.sh"

# The developer's own init.defaultBranch must not decide the local cases.
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1

db() { run ./scripts/default-branch; }
prints() { status_is 0 && [ "$out" = "$1" ]; }

# Local only, a single master.
new_repo scripts/default-branch
db
check "local: only master → master" prints master

# Local only, a single main.
git branch -m master main
db
check "local: only main → main" prints main

# Local only, both: ambiguous unless init.defaultBranch names one.
git branch master
db
check "local: main and master → fails" status_is 1
check "local: main and master → says why" has "cannot tell the default branch"
git config init.defaultBranch master
db
check "local: init.defaultBranch breaks the tie" prints master
git config --unset init.defaultBranch

# A remote whose HEAD is main, cloned: origin/HEAD is set.
origin="$repo"
clone="$(mktemp -d)"
tmp_dirs+=("$clone")
git -C "$origin" symbolic-ref HEAD refs/heads/main
git clone -q "$origin" "$clone/work"
cd "$clone/work" || exit 1
db
check "clone: origin/HEAD → main" prints main

# origin/HEAD unset (repo pushed to a new remote): asks the remote.
git remote set-head origin --delete
db
check "no origin/HEAD: asks the remote → main" prints main

# The remote is unreachable and origin/HEAD unset: falls back to local branches.
git remote set-url origin "$clone/missing"
db
check "unreachable remote: falls back to the local main" prints main

finish
