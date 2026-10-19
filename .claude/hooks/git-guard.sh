#!/usr/bin/env bash
# git-guard — light git guardrail.
#
# Fires as a PreToolUse hook on Bash.
#  - BLOCKS (exit 2) commands that bypass the quality gates:
#      `--no-verify` on commit/push, force-push to master/main, `gh pr merge --admin`.
#  - WARNS (exit 0) on `git commit`/`git push` while on master/main — branch first.

set -euo pipefail

# The hook payload (JSON) arrives on stdin. No JSON parser needed — extract the
# Bash `command` field (fall back to the raw payload if extraction fails) and turn
# escaped newlines back into lines, so each command line is matched on its own.
payload="$(cat)"
cmd="$(printf '%s' "$payload" | sed -nE 's/.*"command"[[:space:]]*:[[:space:]]*"(([^"\\]|\\.)*)".*/\1/p')"
[ -z "$cmd" ] && cmd="$payload"
cmd="${cmd//\\n/$'\n'}"

case "$cmd" in
  *"git commit"*|*"git push"*|*"gh pr merge"*) ;;
  *) exit 0 ;;  # nothing git-related — nothing to do
esac

block() {
  echo "git-guard: blocked — $1. Fix the underlying problem instead (see the \`verify\` skill)." >&2
  exit 2
}

# has <regex> — does one command segment (same line, no ; & | in between) match?
has() { printf '%s\n' "$cmd" | grep -Eq -- "$1"; }

# Resolve the current branch; if we're not in a git repo, stay empty.
branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"

has 'git[[:space:]]+(commit|push)[^;&|]*--no-verify' && block "--no-verify bypasses the checks"
has 'gh[[:space:]]+pr[[:space:]]+merge[^;&|]*--admin' && block "--admin bypasses branch protection"
if has 'git[[:space:]]+push[^;&|]*[[:space:]](--force|-f)([[:space:]=]|-with-lease|$)'; then
  if has 'git[[:space:]]+push[^;&|]*[[:space:]:+](master|main)([[:space:]]|$)' \
     || [ "$branch" = master ] || [ "$branch" = main ]; then
    block "force-push to the default branch"
  fi
fi

case "$branch" in
  master|main)
    case "$cmd" in
      *"git commit"*|*"git push"*)
        echo "git-guard: you are on '$branch'. Prefer a feature branch (feat/…, fix/…) — see the ship skill." >&2
        ;;
    esac
    ;;
esac

exit 0  # warnings only; the action is still allowed
