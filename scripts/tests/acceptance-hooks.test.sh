#!/usr/bin/env bash
# Self-tests for the acceptance agent's hooks (ADR-009):
# - acceptance-guard.sh denies Read under src/ and tests/ for `acceptance` only;
# - acceptance-start.sh creates the evidence dir named by the shared fingerprint.

# shellcheck source=scripts/tests/lib.sh
. "$(dirname "$0")/lib.sh"

new_repo .claude/hooks/acceptance-guard.sh .claude/hooks/acceptance-start.sh .claude/hooks/fingerprint.sh
printf '%s\n' .claude/.state/ >.gitignore
git add -A
git commit -qm "gitignore state"
export CLAUDE_PROJECT_DIR="$repo"

# guard <agent_type> <file_path> — run the guard on a PreToolUse(Read) payload.
guard() {
  local agent=""
  [ -n "$1" ] && agent="\"agent_type\":\"$1\","
  run sh -c "printf '%s' '{\"hook_event_name\":\"PreToolUse\",$agent\"tool_name\":\"Read\",\"tool_input\":{\"file_path\":\"$2\"}}' | .claude/hooks/acceptance-guard.sh"
}
denied() { has '"permissionDecision":"deny"'; }
allowed() { status_is 0 && [ -z "$out" ]; }

for p in src/app.sh "$repo/src/app.sh" ./src/app.sh tests/unit/test_x.py "$repo/tests" src docs/../src/app.sh; do
  guard acceptance "$p"
  check "guard: acceptance reading $p is denied" denied
  check "guard: deny exits 0 ($p)" status_is 0
done
guard acceptance src/app.sh
check "guard: deny gives a reason" has "black box"

for p in README.md "$repo/README.md" specs/features/x/spec.md .claude/.state/acceptance/x/log srcfile.txt docs/src-notes.md; do
  guard acceptance "$p"
  check "guard: acceptance reading $p is allowed" allowed
done
for a in implementer reviewer orchestrator ""; do
  guard "$a" src/app.sh
  check "guard: '${a:-main session}' reading src/app.sh is allowed" allowed
done
run sh -c 'printf "not json" | .claude/hooks/acceptance-guard.sh'
check "guard: unparseable payload fails open" allowed

start() { run sh -c 'printf "{\"hook_event_name\":\"SubagentStart\",\"agent_type\":\"acceptance\"}" | .claude/hooks/acceptance-start.sh'; }
evidence_dirs() { find .claude/.state/acceptance -mindepth 1 -maxdepth 1 -type d 2>/dev/null; }

echo "edit" >>src/app.sh
before="$(git status --porcelain=v1 --untracked-files=all)"
start
# shellcheck source=.claude/hooks/fingerprint.sh
. .claude/hooks/fingerprint.sh
fp="$(fingerprint)"
check "start: exits 0" status_is 0
check "start: emits SubagentStart additionalContext" has '"hookEventName":"SubagentStart","additionalContext":"acceptance-start: workspace state'
check "start: quotes the shared fingerprint" has "workspace state $fp"
check "start: evidence dir named by the fingerprint" test -d ".claude/.state/acceptance/$fp"
check "start: context gives the absolute evidence path" has "$repo/.claude/.state/acceptance/$fp/"
check "start: git status unchanged" test "$before" = "$(git status --porcelain=v1 --untracked-files=all)"

echo "another edit" >>src/app.sh
start
check "start: new state replaces the old evidence dir" test "$(evidence_dirs | wc -l | tr -d ' ')" -eq 1
check "start: old evidence dir removed" test ! -d ".claude/.state/acceptance/$fp"

finish
