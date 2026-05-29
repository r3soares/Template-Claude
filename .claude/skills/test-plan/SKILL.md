---
name: test-plan
description: Plan and document tests for a feature — happy path, edge cases from the spec, and failure scenarios. Use when writing tests for a feature, documenting a test strategy, or before opening a PR for a significant change.
---

# Test Plan

Document the test strategy for a feature and make sure coverage maps back to the spec.

## Steps

1. **Read the feature spec** (`specs/features/{name}/spec.md`). Every Acceptance
   Criterion and every Edge Case row must map to at least one test case.
2. **Create/update** the test plan from `templates/test-template.md`. Keep it next to
   the feature or in `tests/` per the project layout.
3. **Cover three categories** (the spec is non-negotiable on these):
   - **Happy path** — the criteria pass under normal input.
   - **Edge cases** — every Edge Case listed in the spec.
   - **Failure scenarios** — invalid input, errors, boundary failures.
4. **Write the actual tests** in `tests/`, naming files to mirror the source file
   (`user-auth.test.{ext}`). Keep tests simple and readable — match the surrounding code.
5. **Run them** and record pass/fail status in the plan's tables.

## Rules

- Never merge a feature without tests covering the three categories above.
- If a spec criterion can't be tested, flag it as an open question on the spec rather
  than silently skipping it.
- Link the test files in the `traceability` matrix.
