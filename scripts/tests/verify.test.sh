#!/usr/bin/env bash
# Self-tests for scripts/verify: which stages run, strict mode, failure handling and
# the docs-only skip (ADR-003). Stage commands are stubbed with echo.

# shellcheck source=scripts/tests/lib.sh
. "$(dirname "$0")/lib.sh"

export VERIFY_LINT_CMD="echo RAN_LINT" VERIFY_TEST_CMD="echo RAN_TEST" \
  VERIFY_INTEGRATION_CMD="echo RAN_INT"

new_repo scripts/verify

echo "more" >>README.md
run ./scripts/verify full
check "docs-only: passes" status_is 0
check "docs-only: lint still runs" has RAN_LINT
check "docs-only: test reported N/A" has "N/A      test (only non-essential"
check "docs-only: integration skipped" lacks RAN_INT

mkdir -p docs/adr
echo "x" >docs/adr/ADR-009.md
run ./scripts/verify full
check "docs-only (untracked file under docs/): test skipped" lacks RAN_TEST

run env VERIFY_ALL=1 ./scripts/verify full
check "VERIFY_ALL=1 forces test on a docs-only change" has RAN_TEST

run env VERIFY_BASE=does-not-exist ./scripts/verify full
check "unknown base runs every stage" has RAN_INT
reset_tree

echo "echo changed" >>src/app.sh
run ./scripts/verify full
check "code change: runs test" has RAN_TEST
check "code change: runs integration" has RAN_INT

run ./scripts/verify fast
check "fast mode: no integration" lacks RAN_INT

run env VERIFY_TEST_CMD= ./scripts/verify full
check "unconfigured stage is SKIPPED without strict" has "SKIPPED  test (not configured)"
check "unconfigured stage passes without strict" status_is 0

run env VERIFY_TEST_CMD= VERIFY_STRICT=1 ./scripts/verify full
check "unconfigured stage fails under VERIFY_STRICT=1" status_is 1
check "strict failure names the stage" has "FAIL     test (not configured; VERIFY_STRICT=1)"

run env VERIFY_TEST_CMD=template_test VERIFY_STRICT=1 ./scripts/verify full
check "only template self-tests fail under VERIFY_STRICT=1" status_is 1
check "template-only failure says how to fix it" has "chain yours: template_test && <cmd>"

run env VERIFY_TEST_CMD=n/a VERIFY_STRICT=1 ./scripts/verify full
check "n/a stage passes under VERIFY_STRICT=1" status_is 0
check "n/a stage is reported" has "N/A      test (not applicable)"

run env VERIFY_TEST_CMD=false ./scripts/verify full
check "failing stage exits 1" status_is 1
check "failing stage stops later stages" lacks RAN_INT
check "failing stage is named" has "FAILED at stage 'test'"
reset_tree

run ./scripts/verify full
check "no change at all runs every stage (fail safe)" has RAN_TEST

run ./scripts/verify bogus
check "unknown mode exits 64" status_is 64

finish
