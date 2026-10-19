# ADR-002: Layered Validation with an Agent Self-Correction Loop and a GitHub Gate [ACCEPTED]

> Validation happens in three layers that all run `scripts/verify`: a Stop hook that
> makes Claude fix failures before handing back, the `ship` skill before integrating,
> and — when the repo is on GitHub — a required CI check on a pull request.

---

## Status

`[ACCEPTED]`

Supersedes: —  
Superseded by: —

---

## Context

Goal: Claude should write testable code, validate it, investigate failures and try to
fix them before involving the developer; GitHub should independently validate before
anything reaches the default branch. Constraints: solo dev, minimal ceremony, no
duplicated rules, adaptable to any stack, reliable and reproducible.

Before this decision the template only *instructed* testing: no hook enforced it, CI
was a stub, and integration was a local `merge --no-ff` with an optional push — CI, if
configured, ran only *after* master changed. A previous `open-pr` skill had been removed
to keep the flow simple; this decision reintroduces PRs only where they buy an
independent gate (repos with a GitHub remote), as part of `ship` rather than a separate
skill.

---

## Decision

1. **Layer 1 — Agent (fast feedback).** A `Stop` hook (`verify-on-stop.sh`) runs
   `scripts/verify fast` when a turn ends with uncommitted changes. On failure it exits
   2, feeding the output back to Claude, which follows the `verify` skill (root cause →
   fix → re-run). Bounded to 3 consecutive attempts per session, then it releases so
   Claude escalates with a report instead of looping. Opt out with
   `CLAUDE_VERIFY_ON_STOP=0`. A `PreToolUse` guard (`git-guard.sh`) blocks gate bypasses
   (`--no-verify`, `gh pr merge --admin`, force-push to master/main).
2. **Layer 2 — Ship (local gate).** The `ship` skill runs `scripts/verify full`
   (including Docker integration tests) before review and integration.
3. **Layer 3 — GitHub (independent gate), dual mode.**
   - *Local mode* (no GitHub remote): integrate with `merge --no-ff`, as before.
   - *GitHub mode*: push the branch, open a PR, arm `gh pr merge --auto --merge`. CI
     job `verify` runs `scripts/verify full` on a clean runner; a branch ruleset
     (`templates/github/branch-ruleset.json`) requires a PR and the `verify` check on
     an up-to-date branch, with zero required approvals, and blocks force-push/deletion.

Each layer adds something the previous lacks (speed → completeness → independence from
the developer's machine), and they share one command set (ADR-001).

---

## Options Considered

### Option A: Dual mode with PR + required check + auto-merge (chosen)

**Pros:**
- A real gate *before* master on GitHub; still works fully offline.
- Auto-merge keeps it hands-off: the PR merges itself when CI passes.

**Cons:**
- Brings back a PR step in GitHub mode; requires `gh`.

### Option B: Fast-forward without PR (push branch, wait for CI, `merge --ff-only`)

**Pros:**
- No PR; required checks still apply to the pushed SHA.

**Cons:**
- Loses the `--no-ff` merge commit; more manual waiting; subtler to explain.

### Option C: CI only after merge

**Pros:**
- No workflow change.

**Cons:**
- Not a gate — broken code reaches master first.

### Agent loop: Stop hook vs. instructions only vs. git pre-commit hooks

Instructions alone are model judgment, not guaranteed. Git pre-commit hooks run only at
commit time and would duplicate CI. A Stop hook is deterministic, runs at the moment
Claude claims to be done, and stays cheap by running only `fast` and only on a dirty tree.

---

## Consequences

### Positive

- Most failures are found and fixed by Claude before the developer sees them.
- Master on GitHub only receives commits that passed CI on a clean runner.
- No duplicated commands: hook, skill and CI all call `scripts/verify`.

### Negative / Trade-offs

- Turns that change files take longer (the `fast` stages run at the end).
- GitHub mode adds a PR per change (automated by `ship`).

### Risks

- Rulesets on private repos need a paid GitHub plan; on Free, CI is a signal, not a
  hard gate.
- A slow `fast` stage makes the hook annoying — keep slow suites in `integration`.
- The guard is string-based; it catches mistakes, not a determined bypass.

---

## Related

- ADR: [ADR-001](ADR-001-single-verification-entry-point.md)
- Skills: `verify`, `ship`, `setup-ci`, `test-plan`
