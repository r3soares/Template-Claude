#!/usr/bin/env bash
# acceptance-guard — keep the `acceptance` agent a black box (ADR-009).
#
# Fires as a PreToolUse hook on Read. When the call comes from the `acceptance`
# agent (`agent_type` in the payload) and the path is under src/ or tests/, it denies
# the call with a reason. Every other agent, and every other path, passes through
# with no output. It fails open on a payload it can't parse: it guards against
# mistakes, it is not a security boundary. Bash reads are covered by the agent's
# prompt only (ADR-009, Risks).

set -uo pipefail

payload="$(cat)"
# json_str <key> — the first string value of <key> in the payload (no jq dependency).
json_str() {
  printf '%s' "$payload" | sed -nE "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"(([^\"\\\\]|\\\\.)*)\".*/\1/p" | head -n 1
}

[ "$(json_str agent_type)" = acceptance ] || exit 0
path="$(json_str file_path)"
[ -n "$path" ] || exit 0

root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
rel="${path#"$root"/}"
while [ "${rel#./}" != "$rel" ]; do rel="${rel#./}"; done

case "$rel" in
  src | src/* | tests | tests/* | */../src | */../src/* | */../tests | */../tests/*) ;;
  *) exit 0 ;;
esac

printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"acceptance-guard: the acceptance agent is a black box and must not read src/ or tests/ (ADR-009). Judge the running product against the spec instead."}}'
exit 0
