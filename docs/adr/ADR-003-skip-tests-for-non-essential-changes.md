# ADR-003: Skip Test Stages for Changes to Non-Essential Files [ACCEPTED]

> When a change touches only files no test reads (docs, markdown, templates),
> `scripts/verify` skips the `test` and `integration` stages. Lint always runs.

---

## Status

`[ACCEPTED]`

Supersedes: —  
Superseded by: —

---

## Context

Every change ran the full pipeline: the Stop hook ran `verify fast` after a README
typo, and `ship`/CI ran `verify full` — including Docker integration tests — for a
docs-only PR. That costs minutes and proves nothing: no test reads those files.
Projects created from the template should get this behavior by default, without the
developer having to remember it.

Constraints: one entry point (ADR-001); CI's `verify` is a required status check
(ADR-002); secrets can live in docs, so gitleaks must still scan them.

---

## Decision

1. `scripts/verify` holds a `NON_ESSENTIAL` list of git glob pathspecs (`*.md`,
   `docs/**`, `specs/**`, `templates/**`, `LICENSE*`, …), extended per project.
2. It computes the change against a base — `VERIFY_BASE` (CI passes the PR base / the
   pushed-over commit) or the merge-base with the default branch — plus uncommitted and
   untracked files. If every changed file matches `NON_ESSENTIAL`, `test` and
   `integration` report `N/A` (passes under `VERIFY_STRICT=1`).
3. Lint (`template_lint` + stack linters) always runs.
4. Fail safe: an unknown base or an empty change runs everything; `VERIFY_ALL=1` forces it.
5. Skills (`setup-ci`, `test-plan`, `verify`) tell Claude to keep test discovery,
   coverage, linters and Docker build contexts scoped to code.

---

## Options Considered

### Option A: Skip inside `scripts/verify` (chosen)

**Pros:**
- Same behavior in the Stop hook, `ship` and CI; one place to configure.
- The required `verify` check still runs and reports success on docs-only PRs.

**Cons:**
- A small amount of git plumbing in the script.

### Option B: `paths-ignore` in `ci.yml`

**Pros:**
- Native GitHub feature, no script logic.

**Cons:**
- A required check that never runs leaves docs-only PRs stuck at "Expected — waiting".
- Does nothing for the Stop hook or `ship`; duplicates the list outside the script.

### Option C: Keep running everything

**Pros:**
- Simplest; no chance of skipping a needed test.

**Cons:**
- Wasted minutes on every docs change, locally and in CI.

---

## Consequences

### Positive

- Docs-only turns and PRs finish in seconds (lint only).
- New projects inherit the policy from the template and the skills.

### Negative / Trade-offs

- The list must stay accurate: a file a test does read must never be in it.

### Risks

- A misconfigured `NON_ESSENTIAL` (e.g. a glob matching source or config) would skip
  tests silently. Mitigated by a conservative default list and the `setup-ci` guidance.

---

## Related

- ADR: [ADR-001](ADR-001-single-verification-entry-point.md), [ADR-002](ADR-002-layered-validation-and-github-gate.md)
- Skills: `verify`, `setup-ci`, `test-plan`
