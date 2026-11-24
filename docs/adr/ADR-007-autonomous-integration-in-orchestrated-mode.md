# ADR-007: Autonomous Integration in Orchestrated Mode [ACCEPTED]

> In orchestrated mode, a dedicated `integrator` agent branches, commits, pushes, opens
> the PR and merges it. The developer does not confirm each step: starting
> `claude --agent orchestrator` authorizes integration, and the deterministic gates
> (local `verify full`, required CI check, branch ruleset) replace the confirmation.
> The implementer still never commits.

---

## Status

`[ACCEPTED]`

Supersedes: —  
Superseded by: —  
Amends: ADR-005 (decision 5: integration is the developer's)

---

## Context

ADR-005 left integration to the developer: the orchestrator ended by asking them to run
`ship` in a classic session. In practice that defeats the point of an autonomous mode,
and it wastes tokens. The orchestrator worked around it by delegating "checkpoint
commit" tasks to the implementer. That broke the implementer's no-commit rule, and every
commit became a full implementer task that loaded project docs and skills.

Forces:
- The developer wants commits, pushes and merges done without them, but in an orderly
  way: one commit per task, a PR, gates before master.
- The reviewer reviews the *uncommitted* diff (`review-diff.sh`). Whoever commits must
  do it after the review, not inside the implementer's task.
- Git work is mechanical. It needs Bash, but not the implementer's skills, rules or
  context.
- The harness already blocks the dangerous variants: deny rules forbid `--no-verify`,
  force-push and `gh pr merge --admin`.

---

## Decision

1. **New agent `integrator`** (`.claude/agents/integrator.md`, `tools: Bash, Read`,
   `model: haiku`). The orchestrator delegates one operation at a time:
   - `start <branch>`: create the task branch from an up-to-date master.
   - `commit <paths> <message>`: stage exactly those paths and make one Conventional
     Commit. Minimal prompt; the integrator reads no project docs.
   - `ship <title> <body>`: `verify full`, push, open a PR (or reuse the branch's open
     PR in a fix round), arm auto-merge, wait for CI and for the merge, return to an
     up-to-date master. Without a GitHub remote: local `merge --no-ff` after a green
     `verify full`.
2. **Authorization**: starting orchestrated mode is the developer's standing
   authorization to integrate. The gates are the confirmation: `verify full` locally,
   then CI's required check and the branch ruleset on GitHub.
3. **No external gate → no merge.** Before arming auto-merge, the integrator checks
   master's rules (`gh api repos/{owner}/{repo}/rules/branches/master`). Without a
   `required_status_checks` rule it stops after opening the PR and reports. A refused
   `--auto` is not a reliable signal: on a PR that is already mergeable, `gh pr merge
   --auto` merges at once.
4. **Failures go back through the orchestrator.** The integrator never edits project
   files and never resolves conflicts. On a red `verify full`, a failed CI run or a
   conflict, it reports the log and stops. The orchestrator delegates the fix to an
   implementer (bounded: 3 rounds), then asks the integrator to commit and ship again.
5. **Flow**: `integrator start` → per task: implementer → reviewer → `integrator
   commit` → at the end, `integrator ship`.
6. **Review replaces the developer's look.** The reviewer runs for every feature-tier
   change (standing in for `ship`'s `security-review` step) and for risky small
   changes. Must-fix findings get one fix round and a focused re-review; a task with an
   unresolved must-fix or an unconfirmed review is not committed.

---

## Options Considered

### Dedicated `integrator` agent (chosen)

**Pros:**
- A commit costs a tiny prompt on a cheap model, not a full implementer context.
- Separation of duties holds: the implementer writes, the integrator integrates, and
  review still sees the uncommitted diff, so `review-diff.sh` is unchanged.

**Cons:**
- A fourth agent prompt to maintain, pinned by `scripts/tests/agents.test.sh`.

### Implementer commits at the end of its task

**Cons:**
- The reviewer would see an empty uncommitted diff. Fixing that means diffing against
  the branch base and redefining the workspace state. More change, for a worse
  boundary. Rejected.

### Keep integration with the developer (ADR-005)

**Cons:**
- Not autonomous, and it caused the checkpoint-commit workaround. Rejected.

---

## Consequences

### Positive

- End-to-end orchestrated runs: plan → implement → review → commit → PR → merge.
- No implementer task spent on a commit.

### Negative / Trade-offs

- Merges happen without a human look at the diff. Quality rests on `verify`, CI, the
  reviewer (features and risky changes), and the PR history for after-the-fact review.
- The rule check reads rulesets only; a repo protected by classic branch protection
  instead is treated as ungated and stops at the PR.

### Risks

- Repos without CI and a ruleset have no external gate. Mitigated by decision 3: the
  integrator stops at the PR.
- The integrator's limits (no edits, only the named paths) are instructions, like the
  implementer's no-commit rule. Deny rules and the ruleset bound the damage.
