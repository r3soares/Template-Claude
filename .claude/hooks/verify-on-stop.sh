#!/usr/bin/env bash
# verify-on-stop — deterministic self-correction loop for the agent.
#
# Fires as a Stop hook. When Claude finishes a turn with uncommitted changes, it
# runs `scripts/verify fast`. On failure it exits 2: the harness feeds the output
# back to Claude, which must diagnose and fix it (see the `verify` skill) before
# stopping. After MAX_ATTEMPTS consecutive failures it lets Claude stop so it can
# report to the developer instead of looping. A turn that only touched
# non-essential files (docs, *.md — NON_ESSENTIAL in scripts/verify) runs lint only,
# and a tree identical to the last green run is not re-verified.
#
# Disable for a session with CLAUDE_VERIFY_ON_STOP=0.

set -uo pipefail

MAX_ATTEMPTS=3

payload="$(cat)"
[ "${CLAUDE_VERIFY_ON_STOP:-1}" = "0" ] && exit 0

root="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$root" || exit 0
[ -x scripts/verify ] || exit 0

# Attempt counter, per session (state dir is gitignored).
session="$(printf '%s' "$payload" | sed -n 's/.*"session_id" *: *"\([^"]*\)".*/\1/p' | tr -cd 'A-Za-z0-9_-')"
state_dir=".claude/.state"
counter="$state_dir/verify-attempts-${session:-default}"

# Nothing changed in the working tree → nothing to verify (and any earlier
# failure was resolved, e.g. fixed and committed — reset the counter).
if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
  rm -f "$counter"
  exit 0
fi
mkdir -p "$state_dir"

# Same tree as the last green run (e.g. a turn that only answered a question) →
# nothing new to verify. Only passes are cached; `ship` and CI never use this.
fingerprint() {
  {
    git rev-parse HEAD
    git diff HEAD --binary
    git ls-files -o --exclude-standard -z |
      while IFS= read -r -d '' f; do printf '%s ' "$f"; git hash-object -- "$f"; done
  } 2>/dev/null | git hash-object --stdin
}
pass_file="$state_dir/verify-pass"
fp="$(fingerprint)"
[ -n "$fp" ] && [ "$fp" = "$(cat "$pass_file" 2>/dev/null)" ] && exit 0

log="$(mktemp)"
trap 'rm -f "$log"' EXIT

if ./scripts/verify fast >"$log" 2>&1; then
  rm -f "$counter"
  echo "$fp" >"$pass_file"
  exit 0
fi

attempts=$(( $(cat "$counter" 2>/dev/null || echo 0) + 1 ))

if [ "$attempts" -gt "$MAX_ATTEMPTS" ]; then
  # Give up the automatic loop; the developer takes over from Claude's report.
  rm -f "$counter"
  exit 0
fi
echo "$attempts" >"$counter"

{
  echo "verify-on-stop: \`./scripts/verify fast\` FAILED (attempt $attempts/$MAX_ATTEMPTS)."
  echo "Follow the \`verify\` skill: find the root cause and fix the code — do not skip,"
  echo "delete or weaken tests. Output (last 60 lines):"
  echo "----"
  tail -n 60 "$log"
  echo "----"
  if [ "$attempts" -eq "$MAX_ATTEMPTS" ]; then
    echo "This is the LAST automatic attempt. If you cannot fix it now, stop and give the"
    echo "developer the escalation report described in the \`verify\` skill."
  fi
} >&2
exit 2
