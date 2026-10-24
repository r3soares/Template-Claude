---
name: verify
description: Run scripts/verify, fix failures at the root cause, re-run, escalate after bounded attempts. Use after changing code, before saying done or shipping, and when a check, hook or CI fails.
---

# Verify and self-correct

A change is **done** only when `./scripts/verify` passes. "It should work" is not
evidence — the command output is. This skill is how Claude gets there without asking
the developer to debug for it.

`scripts/verify` is the single entry point (ADR-001): `fast` = lint + test, `full` =
lint + test + integration. The `verify-on-stop` hook runs `fast` automatically when a
turn ends with changes; `ship` and CI run `full`.

If the change touches only non-essential files (docs, `*.md` — `NON_ESSENTIAL` in
`scripts/verify`), `test` and `integration` report `N/A` by design; lint still runs.
`VERIFY_ALL=1` forces every stage.

## Loop

1. **Run** `./scripts/verify fast` (or `full` before shipping). Read the summary: it
   names the failing stage.
2. **Reproduce narrowly.** Re-run only the failing test/file/linter with the stack's
   own runner (e.g. `pytest tests/x_test.py::test_y`, `npm test -- x.test.ts`) — faster
   loop, clearer output.
3. **Find the root cause** before editing. Read the full error and the code under test;
   state a hypothesis in one sentence. If two fixes failed on the same hypothesis, the
   hypothesis is wrong — gather more evidence (logs, a print, a smaller repro).
4. **Fix the code, not the check.** If you conclude the *test* is wrong (it encodes
   behavior the spec doesn't require), say so explicitly and why, then fix the test.
5. **Re-run** the narrow command, then `./scripts/verify fast` (a fix can break
   something else).
6. **Bound it: 3 attempts per distinct failure.** Then stop and escalate.

## Never (these hide bugs instead of fixing them)

- Skip, delete, `xfail`/`.skip`, or comment out a failing test.
- Loosen an assertion, widen a tolerance, or update a snapshot just to get green.
- Bypass hooks or gates: `--no-verify`, `gh pr merge --admin`, force-push (permission
  deny rules in `.claude/settings.json` block these).
- Swallow errors with a catch-all, or disable a lint rule, to silence a failure — unless
  you explain why the rule is wrong *here* in a comment.
- Empty a stage in `scripts/verify` to make it pass.

## Special cases

- **Flaky test** (passes on re-run with no change): re-run once to confirm, then report
  it as flaky — don't call it fixed. Fix the nondeterminism if it's in scope (see
  `test-plan`: time, randomness, ordering, sleeps).
- **Secret found (gitleaks)**: never commit it. Move it to an env var / gitignored
  `.env`, and tell the developer — if it was already committed or pushed, it must be
  **rotated**, not just deleted. Only a reviewed false positive goes to
  `.gitleaksignore`, and you say so.
- **Environment failure** (missing tool, Docker down, network): not a code bug. Report
  what's missing; don't change code to work around it.
- **CI fails but local passes**: `gh run view <run-id> --log-failed` (find the id with
  `gh pr checks` or `gh run list`). Usual causes: missing dependency/env var in CI,
  OS/version difference, an unconfigured stage under `VERIFY_STRICT=1`. Fix so that
  local and CI agree — in `scripts/verify`, not by special-casing CI.

## Escalation report (after the bound, or when blocked)

Give the developer, concisely:

- **What fails** — stage, test name, the key error lines.
- **What I tried** — each attempt and its result.
- **Hypotheses** — what I believe is wrong, and what I ruled out.
- **Suggested next step** — the decision or information I need.
