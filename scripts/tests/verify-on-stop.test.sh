#!/usr/bin/env bash
# Self-tests for .claude/hooks/verify-on-stop.sh: when it runs verify, the bounded
# retry counter (per agent), the background-subagent deferral and the opt-out. scripts/verify is replaced by a fake whose exit
# status comes from .verify-result and whose calls are logged to .verify-calls.

# shellcheck source=scripts/tests/lib.sh
. "$(dirname "$0")/lib.sh"

new_repo .claude/hooks/verify-on-stop.sh .claude/hooks/fingerprint.sh
mkdir -p scripts
cat >scripts/verify <<'EOF'
#!/usr/bin/env bash
echo call >>.verify-calls
echo "fake verify output"
exit "$(cat .verify-result 2>/dev/null || echo 0)"
EOF
chmod +x scripts/verify
printf '%s\n' .claude/.state/ .verify-calls .verify-result >.gitignore
git add -A
git commit -qm "fake verify"

export CLAUDE_PROJECT_DIR="$repo"
counter=.claude/.state/verify-attempts-t1

hook() {
  out="$(printf '{"session_id":"t1","hook_event_name":"Stop"}' |
    .claude/hooks/verify-on-stop.sh 2>&1)"
  code=$?
}
calls() { if [ -f .verify-calls ]; then wc -l <.verify-calls | tr -d ' '; else echo 0; fi; }
calls_are() { [ "$(calls)" -eq "$1" ]; }
counter_is() { [ "$(cat "$counter" 2>/dev/null)" = "$1" ]; }
no_counter() { [ ! -e "$counter" ]; }

mkdir -p .claude/.state
echo 2 >"$counter"
hook
check "clean tree: lets Claude stop" status_is 0
check "clean tree: does not run verify" calls_are 0
check "clean tree: resets a stale counter" no_counter

echo "echo changed" >>src/app.sh
echo 1 >.verify-result
hook
check "failure: blocks the stop (exit 2)" status_is 2
check "failure: reports attempt 1/3" has "attempt 1/3"
check "failure: passes verify output back" has "fake verify output"
check "failure: counter is 1" counter_is 1
check "failure without overrides: lists none" lacks "Active VERIFY_* overrides"
rm -f "$counter"

out="$(printf '{"session_id":"t1","hook_event_name":"Stop"}' |
  VERIFY_TEST_CMD=false VERIFY_STRICT=1 .claude/hooks/verify-on-stop.sh 2>&1)"
code=$?
check "failure with overrides: lists them" has "Active VERIFY_* overrides"
check "failure with overrides: shows each one" has "  VERIFY_TEST_CMD=false"
check "failure with overrides: sorted" has "$(printf '  VERIFY_STRICT=1\n  VERIFY_TEST_CMD=false')"
check "failure: points at environmental causes" has "If the cause is environmental"
echo 1 >"$counter"

hook
hook
check "third failure: last attempt warning" has "LAST automatic attempt"
check "third failure: still blocks" status_is 2

hook
check "fourth failure: releases Claude to report" status_is 0
check "fourth failure: counter reset" no_counter

echo 0 >.verify-result
hook
check "pass: lets Claude stop" status_is 0
check "pass: no counter left" no_counter

before="$(calls)"
hook
check "unchanged tree after a pass: cached, verify not re-run" calls_are "$before"
check "unchanged tree after a pass: lets Claude stop" status_is 0

echo "echo again" >>src/app.sh
hook
check "tree changed after a pass: verify runs again" calls_are $((before + 1))

echo "new" >src/new.sh
hook
check "new untracked file: verify runs again" calls_are $((before + 2))

echo "edited" >src/new.sh
hook
check "edited untracked file: verify runs again" calls_are $((before + 3))

echo 1 >.verify-result
echo "broken" >>src/app.sh
hook
hook
check "failures are never cached: verify re-runs on an unchanged tree" calls_are $((before + 5))
rm -f "$counter"

# payload_hook <json> — run the hook with an arbitrary payload.
payload_hook() {
  out="$(printf '%s' "$1" | .claude/hooks/verify-on-stop.sh 2>&1)"
  code=$?
}
bg='"background_tasks":[{"id":"a1","type":"subagent","status":"running","agent_type":"implementer"}]'

before="$(calls)"
payload_hook '{"session_id":"t1","hook_event_name":"Stop",'"$bg"'}'
check "Stop with a background subagent running: deferred, verify not run" calls_are "$before"
check "Stop with a background subagent running: lets Claude stop" status_is 0
check "Stop with a background subagent running: no attempt counted" no_counter

payload_hook '{"session_id":"t1","hook_event_name":"Stop","background_tasks":[{"id":"s1","type":"shell","status":"running"}]}'
check "Stop with only a background shell task: verify runs" calls_are $((before + 1))
check "Stop with only a background shell task: still blocks on failure" status_is 2
rm -f "$counter"

before="$(calls)"
payload_hook '{"session_id":"t1","hook_event_name":"SubagentStop","agent_id":"impl1","agent_type":"implementer",'"$bg"'}'
check "SubagentStop: verify runs even though background_tasks lists a subagent" calls_are $((before + 1))
check "SubagentStop failure: blocks the subagent (exit 2)" status_is 2
check "SubagentStop failure: counted for the agent" test "$(cat .claude/.state/verify-attempts-impl1 2>/dev/null)" = 1
check "SubagentStop failure: main session counter untouched" no_counter

hook
check "main session after a subagent failure: its own attempt 1/3" has "attempt 1/3"
rm -f "$counter" .claude/.state/verify-attempts-impl1

before="$(calls)"
out="$(printf '{"session_id":"t1"}' | CLAUDE_VERIFY_ON_STOP=0 .claude/hooks/verify-on-stop.sh 2>&1)"
code=$?
check "CLAUDE_VERIFY_ON_STOP=0: lets Claude stop" status_is 0
check "CLAUDE_VERIFY_ON_STOP=0: does not run verify" calls_are "$before"

finish
