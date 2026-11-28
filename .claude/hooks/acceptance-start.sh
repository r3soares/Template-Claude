#!/usr/bin/env bash
# acceptance-start — give the `acceptance` agent its evidence directory and the
# workspace state it checks (ADR-009).
#
# Fires as a SubagentStart hook for the `acceptance` agent. It creates
# .acceptance/<fingerprint>/ (removing older evidence directories) and
# passes the path and the state id through `additionalContext`. The fingerprint is the
# one verify-on-stop.sh caches in verify-pass and review-diff.sh names its diff with,
# so the orchestrator can tell which tree was accepted. It never blocks.

set -uo pipefail

cat >/dev/null  # drain the payload; this hook needs nothing from it
hook_dir="$(cd "$(dirname "$0")" && pwd)"
root="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

# context <message> — hand <message> to the agent and exit (always 0).
context() {
  local msg
  msg="$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  printf '{"hookSpecificOutput":{"hookEventName":"SubagentStart","additionalContext":"%s"}}\n' "$msg"
  exit 0
}
unavailable() { context "acceptance-start: workspace state UNAVAILABLE ($1). Report the state as unknown; keep evidence in a temp dir and list its path."; }

cd "$root" 2>/dev/null || unavailable "project dir not found"
git rev-parse -q --verify HEAD >/dev/null 2>&1 || unavailable "not a git repository with a commit"
# shellcheck source=.claude/hooks/fingerprint.sh
. "$hook_dir/fingerprint.sh"
export GIT_OPTIONAL_LOCKS=0

fp="$(fingerprint)"
[ -n "$fp" ] || unavailable "could not compute the workspace state"
base=".acceptance"   # outside .claude/: Bash writes there need approval (ADR-010)
mkdir -p "$base" || unavailable "cannot create $base"
find "$base" -mindepth 1 -maxdepth 1 -type d ! -name "$fp" -exec rm -rf {} + 2>/dev/null
mkdir -p "$base/$fp" || unavailable "cannot create $base/$fp"

context "acceptance-start: workspace state $fp. Save every piece of evidence (screenshots, HTTP transcripts, start-up logs) under $root/$base/$fp/ and quote the workspace state in your report."
