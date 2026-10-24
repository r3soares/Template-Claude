#!/usr/bin/env bash
# Self-tests for .claude/hooks/verify-on-stop.sh: when it runs verify, the bounded
# retry counter and the opt-out. scripts/verify is replaced by a fake whose exit
# status comes from .verify-result and whose calls are logged to .verify-calls.

# shellcheck source=scripts/tests/lib.sh
. "$(dirname "$0")/lib.sh"

new_repo .claude/hooks/verify-on-stop.sh
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

echo 1 >.verify-result
before="$(calls)"
out="$(printf '{"session_id":"t1"}' | CLAUDE_VERIFY_ON_STOP=0 .claude/hooks/verify-on-stop.sh 2>&1)"
code=$?
check "CLAUDE_VERIFY_ON_STOP=0: lets Claude stop" status_is 0
check "CLAUDE_VERIFY_ON_STOP=0: does not run verify" calls_are "$before"

finish
