---
name: test-plan
description: Design testable code and write tests — happy path, spec edge cases, failures, and a regression test per bug. Use when writing tests or designing code for testability.
---

# Test Plan

Make sure test coverage maps back to the spec, then write real tests. The deliverable is
**executable tests in `tests/`**, run through `./scripts/verify` — the test runner is
the source of truth for pass/fail, not a document.

## Design for testability (while implementing)

- **Separate logic from I/O.** Keep decisions/calculations in pure functions; push
  network, disk, DB, clock and randomness to thin edges.
- **Inject dependencies at the boundaries** (pass the client/repo/clock in) instead of
  constructing or importing them deep inside — then a test can substitute them.
- **Small public surface.** Test through the public interface, not private internals;
  tests that mirror implementation details break on every refactor.
- If something is hard to test, that's design feedback — simplify the code rather than
  writing an elaborate test.

## Layers — pick the cheapest that proves the behavior

| Layer | What | Where it runs |
|-------|------|---------------|
| **Unit** | Logic in isolation, fakes at the boundaries. The bulk of the tests. | `TEST_CMD` (`verify fast`) |
| **Integration** | Real DB/cache/broker/HTTP between services, via Docker Compose. A few, on the critical paths. | `INTEGRATION_CMD` with `with_compose` (`verify full`, CI) |
| **End-to-end** | Whole system from the user's side. Optional; only for flows that justify the cost. | `INTEGRATION_CMD` or a separate stage |

Don't mock what you own when an integration test against the real thing (in a
container) is cheap — mocks of a DB prove little about the queries.

## Steps

1. **Read the spec** (`specs/features/{name}/spec.md`). Every Acceptance Criterion and
   every Edge Case row maps to at least one test.
2. **Cover three categories**:
   - **Happy path** — the criteria pass under normal input.
   - **Edge cases** — every Edge Case listed in the spec.
   - **Failure scenarios** — invalid input, errors, timeouts, boundary failures.
3. **Write the tests** in `tests/` (unit and integration separated, e.g.
   `tests/unit/`, `tests/integration/`), file names mirroring the source
   (`user-auth.test.{ext}`). Keep them simple and readable.
4. **Run** `./scripts/verify full`; on failure follow the `verify` skill.
5. **Point the spec's *Related* section** at the new test files.

## Bug fixes (small tier too)

Write a **regression test that fails before the fix** and passes after. Run it red
first — a test that never failed proves nothing. If a regression test is genuinely
impractical, say why in the commit body.

## Reliable tests

- **Deterministic:** inject or freeze time; seed randomness; don't depend on test order
  or on the host's timezone/locale.
- **No sleeps** to wait for things — poll with a timeout, or use the healthcheck wait
  (`docker compose up --wait`) that `with_compose` already does.
- **Isolated:** each test sets up and cleans its own data; integration runs start from a
  fresh compose stack (`down -v`).
- **Fast and quiet:** a passing suite prints little; a failing test says what was
  expected vs. what happened.

## Optional: a written test plan

For a genuinely complex feature where reasoning through cases on paper helps, draft a
plan from `templates/test-template.md`. It is **optional** — never let it become a
second, stale source of pass/fail status.

## Rules

- Never merge a feature without tests covering the three categories above.
- Never weaken or skip a test to get green (see the `verify` skill).
- If a spec criterion can't be tested, flag it as an open question on the spec rather
  than silently skipping it.
- Tests cover code, not docs: never write tests for, or point runners, coverage or
  fixtures at, documentation and markdown (`NON_ESSENTIAL` in `scripts/verify`). A
  docs-only change needs no new tests — `verify` skips test/integration for it.
