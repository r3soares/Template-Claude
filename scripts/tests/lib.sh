#!/usr/bin/env bash
# Helpers for the template's self-tests (sourced by *.test.sh, not run directly).
# Each scenario runs in a throwaway git repo, so the real working tree is untouched.
# shellcheck disable=SC2034  # out/code/repo are read by the sourcing test

set -uo pipefail

# Keep the caller's environment (CI, the Stop hook, a developer's shell) out of the
# scenarios — each test sets exactly what it needs.
unset VERIFY_STRICT VERIFY_BASE VERIFY_ALL VERIFY_COMPOSE_FILE VERIFY_LINT_CMD \
  VERIFY_TEST_CMD VERIFY_INTEGRATION_CMD VERIFY_AUDIT_CMD \
  CLAUDE_VERIFY_ON_STOP CLAUDE_PROJECT_DIR

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
passed=0
failed=0
out=""
code=0
repo=""
tmp_dirs=()
trap 'rm -rf "${tmp_dirs[@]}"' EXIT

# new_repo <file...> — fresh repo in a temp dir with the given template files copied
# in, plus a README and a source file, all committed on master. cds into it.
new_repo() {
  local f
  repo="$(mktemp -d)"
  tmp_dirs+=("$repo")
  cd "$repo" || exit 1
  git init -q -b master
  git config user.email test@example.com
  git config user.name test
  git config commit.gpgsign false
  for f in "$@"; do
    mkdir -p "$(dirname "$f")"
    cp "$ROOT/$f" "$f"
  done
  mkdir -p src
  echo "# readme" >README.md
  echo "echo hi" >src/app.sh
  git add -A
  git commit -qm init
}

# reset_tree — drop every uncommitted change in the current repo.
reset_tree() { git checkout -q -- . && git clean -qfd; }

# run <cmd...> — run a command; combined output in $out, exit status in $code.
run() {
  out="$("$@" 2>&1)"
  code=$?
}

# check <description> <predicate...> — record a pass, or print the failure with $out.
check() {
  local desc="$1"
  shift
  if "$@"; then
    passed=$((passed + 1))
  else
    failed=$((failed + 1))
    echo "    FAIL: $desc" >&2
    printf '%s\n' "$out" | sed 's/^/      | /' >&2
  fi
}

has() { printf '%s' "$out" | grep -qF -- "$1"; }
lacks() { ! has "$1"; }
status_is() { [ "$code" -eq "$1" ]; }

# finish — print the tally; non-zero exit if anything failed.
finish() {
  echo "    $passed passed, $failed failed"
  [ "$failed" -eq 0 ]
}
