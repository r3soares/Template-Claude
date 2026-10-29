# ADR-006: Skip the CI Run on the Push of a PR Merge Commit [ACCEPTED]

> CI's `verify` job no longer runs for the push that a PR merge creates on master: the
> PR's run already verified that merge. Direct pushes to master still run. This saves
> one full run per change on private repos, where Actions minutes are billed.

---

## Status

`[ACCEPTED]`

Supersedes: —  
Superseded by: —  
Amends: ADR-002 (Layer 3: when CI runs)

---

## Context

ADR-002 runs `verify full` on every PR and on every push to master. In GitHub mode,
`ship` merges a PR with `--merge`, and that push runs `verify full` again on a tree the
PR run already verified. GitHub's `pull_request` event checks out the PR merged into the
base (`refs/pull/N/merge`).

On private repos that duplicate costs minutes from the account quota (GitHub Free:
2,000/month). Each job is billed rounded up to the minute, so even a short run costs a
full minute, and a project with Docker or E2E integration tests pays several minutes per
change. In one month on a project created from this template, these post-merge runs were
about 12% of CI time. The other big costs were per-dependency Dependabot PRs and
triggers on working branches, handled outside this ADR (Dependabot config, `setup-ci`).

---

## Decision

The `verify` job in `ci.yml` has
`if: github.event_name != 'push' || !startsWith(github.event.head_commit.message, 'Merge pull request #')`.

- PR runs, manual runs and direct pushes to master (local mode, no PR) still run.
- The push of a merge commit created by GitHub's "Create a merge commit" (`ship` uses
  `gh pr merge --merge`) is skipped. The job shows as skipped, not failed.

---

## Options Considered

### Option A: Skip merge-commit pushes in the job condition (chosen)

**Pros:**
- One line, removes exactly the redundant run.
- Local mode keeps its only CI check (the push).

**Cons:**
- Keyed on GitHub's default merge message. A squash or rebase merge, or an edited
  message, still runs: that costs a run but never skips a check.

### Option B: Drop the `push` trigger

**Pros:**
- Simplest.

**Cons:**
- Local mode (no PRs) would lose CI entirely.

### Option C: Keep running everything

**Pros:**
- Also catches a master that moved between the PR run and the merge.

**Cons:**
- Pays a full run per change for a case that is rare for a solo dev.

---

## Consequences

### Positive

- One `verify full` run less per change in GitHub mode.

### Negative / Trade-offs

- If master changes after a PR's last run and the PR is merged without re-running, the
  merged result isn't verified on master. With the ruleset's "up-to-date branch" rule
  (ADR-002) this can't happen. Without it (private repos on GitHub Free), the next PR or
  direct push verifies it.

### Risks

- Someone could type a direct-push commit message starting with `Merge pull request #`
  and skip CI. That would be deliberate; the deny rules and `ship` don't produce it.

---

## Related

- ADR: [ADR-002](ADR-002-layered-validation-and-github-gate.md), [ADR-003](ADR-003-skip-tests-for-non-essential-changes.md)
- Config: `.github/workflows/ci.yml`, `.github/dependabot.yml`; skill `setup-ci` (*Keep CI cheap*)
