# ADR-008: Agent-Enforced Merge Gate When Rulesets Are Unavailable [ACCEPTED]

> On repos where GitHub refuses rulesets (private repos on GitHub Free), integration
> merges the PR itself once three checks hold: local `verify full` is green, the branch
> contains the latest master, and CI's `verify` check passed on the PR's current head.
> Repos that could have a ruleset but don't still stop at the open PR.

---

## Status

`[ACCEPTED]`

Supersedes: —  
Superseded by: —  
Amends: ADR-007 (decision 3: no external gate → no merge), ADR-006 (risk: unverified
merge result without the up-to-date rule)

---

## Context

ADR-002 and ADR-007 make the GitHub branch ruleset the hard gate: it requires the CI
`verify` check on an up-to-date branch, and ADR-007's integrator merges only when master
has that rule. Without it, the integrator stops at the open PR.

Rulesets, classic branch protection and environments are not available on private
repos under GitHub Free. Probing a private repo on Free, every one of these returns
`403 Upgrade to GitHub Pro or make this repository public to enable this feature.`:

- `GET repos/{owner}/{repo}/rulesets`
- `GET repos/{owner}/{repo}/rules/branches/{branch}` (the integrator's gate check)
- `GET repos/{owner}/{repo}/branches/{branch}/protection`

The template's typical use is exactly that case: a new private repo created from this
GitHub template on a free account. There, the template's assumptions fail:

1. **Orchestrated mode never merges.** The integrator's rule check gets the 403, finds
   no `required_status_checks`, and stops at the PR every time (ADR-007 decision 3).
2. **`setup-ci` step 4 always fails.** Creating the ruleset returns the 403, and
   `--enable-auto-merge` is pointless without a required check: `gh pr merge --auto` on
   a mergeable PR merges at once.
3. **Master can break unseen.** ADR-006 skips CI on the push of a PR merge commit,
   relying on the ruleset's "up-to-date branch" rule so that the PR run verified the
   exact merge result. Without the rule, two PRs that pass separately can break master
   together, and no CI run sees it.

Forces:
- A solo developer is the only one who could bypass a gate; a hard gate mostly protects
  against the agent, and the deny rules already block `--admin`, `--no-verify` and
  force-push (ADR-004).
- The checks a ruleset performs can be done by the integrator before it merges, with
  plain `git` and `gh` commands.
- Where rulesets *are* available but not configured, merging anyway would hide a setup
  step the developer should take (`setup-ci`).

---

## Decision

1. **Three gate modes**, decided at ship time from the integrator's existing rule check
   (`gh api repos/{owner}/{repo}/rules/branches/master`):

   | Response | Mode | Merge |
   |----------|------|-------|
   | Lists `required_status_checks` | `ruleset` | Unchanged: arm auto-merge, GitHub enforces |
   | `403` with `Upgrade to GitHub Pro` | `agent` | The integrator enforces the checks below, then merges |
   | Anything else (no required check, other error) | `none` | Stop at the open PR and report (unchanged) |

2. **Agent gate**: the integrator merges only when all hold, in order:
   1. `./scripts/verify full` is green locally (already ship's step 2).
   2. **Up to date:** after `git fetch origin`, `git merge-base --is-ancestor
      origin/master origin/<branch>` succeeds. If not, GitHub's update-branch API merges
      master into the PR (a conflict → stop and report, never resolve), and the check
      repeats until the remote branch contains master.
   3. **CI green on the exact head:** the `verify` check run of that head commit is
      `completed success` (`gh api …/commits/<sha>/check-runs`). No checks reported
      (after the existing retries) → stop; never merge without CI.
   4. **Merge the tested commit only:** `gh pr merge --merge --delete-branch
      --match-head-commit <sha>`, with `<sha>` the head CI verified. A push after the
      check makes the merge fail instead of merging untested code.
3. **Classic `integrate` skill**: GitHub mode applies the same checks when auto-merge is
   unavailable, after the developer's confirmation (step 5) as today.
4. **`setup-ci` and project setup** detect the 403 before step 4: they skip the ruleset
   and auto-merge, and tell the developer CI is enforced by the agent gate, not GitHub.
5. **ADR-006 stays**: the post-merge push is still skipped. The up-to-date check makes the
   PR run verify the same tree the merge produces, as the ruleset did.

---

## Options Considered

### Option A: Agent-enforced gate when rulesets are unavailable (chosen)

**Pros:**
- Orchestrated mode works end to end on private Free repos, the template's main case.
- Closes ADR-006's gap: the merged tree is the CI-verified tree.
- Keeps ADR-007's intent where a ruleset is possible: an unconfigured repo still stops.

**Cons:**
- A soft gate: the checks are instructions to the integrator plus permission rules, not
  GitHub enforcement. A human can still merge red PRs from the web UI.
- The integrator prompt and its pinned tests grow.

### Option B: Keep stopping at the PR (status quo)

**Pros:**
- No change; nothing merges without GitHub enforcement.

**Cons:**
- On private Free repos the developer merges every PR by hand, which defeats ADR-007,
  and ADR-006's unverified-merge gap stays open. Rejected.

### Option C: Merge locally and push master (local mode with a remote)

**Pros:**
- Simple; CI runs on the push to master.

**Cons:**
- CI verifies master only after the fact: a red master is found, not prevented. No PR
  history for after-the-fact review. Rejected.

### Option D: Run CI on every push to master (undo ADR-006 on Free)

**Pros:**
- Every merge result gets verified.

**Cons:**
- Doubles Actions minutes on private repos, the cost ADR-006 removed, and still only
  detects a broken master after it happened. Rejected; option A prevents it instead.

### Option E: Make repos public or pay for GitHub Pro

**Pros:**
- The ruleset path works unchanged.

**Cons:**
- Not the template's call; most projects are private and on Free. Still supported:
  those repos get mode `ruleset`.

---

## Consequences

### Positive

- Private repos on GitHub Free get autonomous integration and a verified master.
- `setup-ci` stops attempting a step that can't succeed there, and says why.

### Negative / Trade-offs

- Mode `agent` trusts the integrator to follow its checks. Deny rules still block the
  bypass flags, and `--match-head-commit` protects the head, but nothing on GitHub
  refuses a manual merge.
- The integrator needs a few more commands allowed in `.claude/settings.local.json`
  (see `docs/architecture/orchestrated-mode.md`). They call the REST API through `gh api`,
  because `gh pr update-branch` and `gh pr checks --json` are missing from older `gh`
  releases such as Ubuntu's 2.45.

### Risks

- **Base race:** another merge to master between the up-to-date check and the merge
  would make the merged tree differ from the tested one. A solo developer rarely merges
  two PRs at once; the next PR's up-to-date check and CI run catch it.
- **Detection by message:** mode `agent` keys on GitHub's `Upgrade to GitHub Pro` text.
  If GitHub rewords it, the repo falls to mode `none` and stops at the PR: safe, and
  found by the smoke test.

---

## Related

- ADR: [ADR-002](ADR-002-layered-validation-and-github-gate.md),
  [ADR-006](ADR-006-skip-ci-on-pr-merge-push.md),
  [ADR-007](ADR-007-autonomous-integration-in-orchestrated-mode.md)
- Affected files: `.claude/agents/integrator.md`, `.claude/skills/integrate/SKILL.md`,
  `.claude/skills/setup-ci/SKILL.md`, `scripts/tests/agents.test.sh`,
  `docs/architecture/orchestrated-mode.md`, `README.md`, `SETUP.md`
