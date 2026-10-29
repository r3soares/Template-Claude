#!/usr/bin/env bash
# review-diff — give the reviewer agent the real diff, independently of what the
# implementer reports (orchestrated mode, ADR-005).
#
# Fires as a SubagentStart hook for the `reviewer` agent. It writes the working
# tree's changes against HEAD — staged, unstaged, deletions, renames and untracked
# files — to .claude/.state/review-<fingerprint>.diff and tells the reviewer where
# it is through `additionalContext`. The fingerprint is the one verify-on-stop.sh
# caches in .claude/.state/verify-pass after a green run, so the orchestrator can
# check that the reviewed state is the verified one. Read-only: the index and the
# tree are untouched. It never blocks; on error the context says the diff is
# unavailable and the reviewer must not review.

set -uo pipefail

cat >/dev/null  # drain the payload; this hook needs nothing from it
hook_dir="$(cd "$(dirname "$0")" && pwd)"
root="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

# context <message> — hand <message> to the reviewer and exit (always 0).
context() {
  local msg
  msg="$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  printf '{"hookSpecificOutput":{"hookEventName":"SubagentStart","additionalContext":"%s"}}\n' "$msg"
  exit 0
}
unavailable() { context "review-diff: diff UNAVAILABLE ($1). Do not review; answer: BLOCKED: no diff."; }

cd "$root" 2>/dev/null || unavailable "project dir not found"
git rev-parse -q --verify HEAD >/dev/null 2>&1 || unavailable "not a git repository with a commit"
# shellcheck source=.claude/hooks/fingerprint.sh
. "$hook_dir/fingerprint.sh"

# No opportunistic index refresh from `git status`; no external diff drivers or
# textconv programs from the user's git config.
export GIT_OPTIONAL_LOCKS=0
diff_opts=(--no-color --no-ext-diff --no-textconv)

state_dir=".claude/.state"
fp="$(fingerprint)"
[ -n "$fp" ] || unavailable "could not compute the workspace state"
mkdir -p "$state_dir" || unavailable "cannot create $state_dir"
rm -f "$state_dir"/review-*.diff
file="$state_dir/review-$fp.diff"

status="$(git status --porcelain=v1 --untracked-files=all)"
if [ -z "$status" ]; then
  context "review-diff: no uncommitted changes (workspace state $fp); there is nothing to review."
fi

{
  echo "# review-diff: uncommitted changes against HEAD"
  echo "# workspace state: $fp"
  echo "# HEAD: $(git rev-parse HEAD) ($(git branch --show-current 2>/dev/null || echo detached))"
  echo "# status (porcelain v1):"
  printf '%s\n' "$status" | sed 's/^/#   /'
  echo
  git diff HEAD -M "${diff_opts[@]}"
  git ls-files -o --exclude-standard -z |
    while IFS= read -r -d '' f; do
      git diff --no-index "${diff_opts[@]}" -- /dev/null "$f"
      [ $? -le 1 ] || echo "# review-diff: could not diff untracked file: $f"
    done
} >"$file" 2>&1 || unavailable "could not write $file"

count="$(printf '%s\n' "$status" | wc -l | tr -d ' ')"
context "review-diff: the real diff under review is $root/$file (workspace state $fp, $count changed paths). Read all of it (in parts if it is long) before reviewing, and quote the workspace state in your report."
