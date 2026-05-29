---
name: test-plan
description: Plan and document tests for a feature — happy path, edge cases from the spec, and failure scenarios. Use when writing tests for a feature, documenting a test strategy, or before opening a PR for a significant change.
---

# Test Plan

Make sure test coverage maps back to the spec, then write real tests. The deliverable is
**executable tests in `tests/`**, not a document — the test runner is the source of truth
for pass/fail.

## Steps

1. **Read the feature spec** (`specs/features/{name}/spec.md`). Every Acceptance
   Criterion and every Edge Case row must map to at least one test.
2. **Cover three categories** (the spec is non-negotiable on these):
   - **Happy path** — the criteria pass under normal input.
   - **Edge cases** — every Edge Case listed in the spec.
   - **Failure scenarios** — invalid input, errors, boundary failures.
3. **Write the tests** in `tests/`, naming files to mirror the source file
   (`user-auth.test.{ext}`). Keep tests simple and readable — match the surrounding code.
4. **Run them** and make them pass before opening the PR.
5. **Point the spec's *Related* section** at the new test files.

## Optional: a written test plan

For a genuinely complex feature where reasoning through cases on paper helps, you can
draft a plan from `templates/test-template.md`. It is **optional** — don't create it as
routine bookkeeping, and never let it become a second, stale source of pass/fail status.

## Rules

- Never merge a feature without tests covering the three categories above.
- If a spec criterion can't be tested, flag it as an open question on the spec rather
  than silently skipping it.
