#!/usr/bin/env bash
# git-guard — light, non-blocking guardrail.
#
# Fires as a PreToolUse hook on Bash. If Claude is about to `git commit` or
# `git push` while on the default branch (master/main), it prints a warning but
# DOES NOT block the action (exit 0 = allow). Branch your work instead.
#
# To make it blocking, change the final `exit 0` under the warning to `exit 2`.

set -euo pipefail

# The hook payload (JSON) arrives on stdin. We don't need a JSON parser for a
# warning — just inspect the raw payload for the relevant git subcommands.
payload="$(cat)"

case "$payload" in
  *"git commit"*|*"git push"*) ;;
  *) exit 0 ;;  # not a commit/push — nothing to do
esac

# Resolve the current branch; if we're not in a git repo, stay silent.
branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
[ -z "$branch" ] && exit 0

case "$branch" in
  master|main)
    echo "git-guard: you are on '$branch'. Prefer a feature branch (feat/…, fix/…) — see the open-pr skill." >&2
    exit 0  # warning only; the action is still allowed
    ;;
esac

exit 0
