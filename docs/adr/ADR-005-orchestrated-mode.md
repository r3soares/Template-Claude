# ADR-005: Optional Orchestrated Mode with Native Subagents [ACCEPTED]

> An opt-in, per-session mode (`claude --agent orchestrator`) where a main agent that
> cannot write plans and delegates to an `implementer` and a read-only `reviewer`.
> Restrictions are enforced by tool allowlists, the reviewer gets the real diff from a
> hook, and quality still comes from the existing `scripts/verify` gates. Classic mode
> stays the default.

---

## Status

`[ACCEPTED]`

Supersedes: —  
Superseded by: —

---

## Context

For larger tasks, separating planning, implementation and review into distinct
contexts helps: the planner keeps the whole task in view, the implementer works from a
focused brief, and the reviewer judges the change without the implementer's reasoning.
Claude Code supports this natively: custom subagents in `.claude/agents/`, a session
run as one of them with `--agent`, per-agent tool allowlists, and `SubagentStart` /
`SubagentStop` hooks.

Constraints: solo dev, so process must scale with the task (`CLAUDE.md`). Restrictions
must be mechanical, not instructions. The deterministic gates (ADR-001/002) stay the
quality guarantee, with no second infrastructure. Classic mode must keep working
unchanged.

---

## Decision

1. **Activation per session**: `claude --agent orchestrator`. No `agent` key in the
   versioned `settings.json`, since that would make orchestration the project default. A
   developer who wants it by default can set it in `.claude/settings.local.json`.
2. **Three agents** (`.claude/agents/`), each with a `tools` allowlist (an allowlist,
   not `disallowedTools`, so tools added to Claude Code later are not inherited):

   | Agent | `tools` | Role |
   |-------|---------|------|
   | `orchestrator` | `Agent(implementer, reviewer), Read, Glob, Grep, AskUserQuestion, TaskCreate, TaskGet, TaskList, TaskUpdate` | Plan, delegate (one implementer at a time), route review findings, report. No Bash/Edit/Write, no `Skill` (a `context: fork` skill could spawn other agent types), no MCP. |
   | `implementer` | `Read, Edit, Write, Bash, Skill` | One task: code, tests, spec/ADR, CHANGELOG, via the existing skills. No `Agent`, no web, no MCP. Does not commit or ship (instruction only, see Risks). |
   | `reviewer` | `Read, Glob, Grep` | Read-only review of the hook-provided diff. |

   `Agent(type, …)` restricts spawnable types only for an agent running as the main
   thread, which is exactly how the orchestrator runs. The other two don't list `Agent`,
   so they can't delegate.
3. **Real diff for the reviewer**: a `SubagentStart` hook (matcher `^reviewer$`,
   `review-diff.sh`) writes the uncommitted changes against HEAD (staged, unstaged,
   deletions, renames, untracked files) to `.claude/.state/review-<state>.diff`, without
   touching the index, and passes its path through `additionalContext`. `<state>` is the
   working-tree fingerprint shared with `verify-on-stop.sh` (`fingerprint.sh`). The
   orchestrator compares the reviewed state with `.claude/.state/verify-pass` (the last
   green state). If they match, the reviewed tree is the verified tree.
4. **Gates reused**: a `SubagentStop` hook (matcher `^implementer$`) runs the same
   `verify-on-stop.sh`, so the implementer fixes failures in its own context. The
   attempt counter is keyed per agent. The main-agent `Stop` hook still runs as before,
   and it skips verification while a background subagent is in flight (verifying a
   half-edited tree proves nothing). The check runs at the next Stop instead.
5. **Integration is the developer's**: the orchestrator ends by telling the developer to
   run the `ship` skill in a classic session.
6. **Sequential implementation in the current working tree.** No worktrees, Docker per
   agent, external orchestrator or agent teams.

---

## Options Considered

### Reviewer diff: `SubagentStart` hook (chosen)

**Pros:**
- The diff comes from the harness at the moment the review starts. It doesn't depend on
  the implementer's report or the orchestrator.
- Regenerated for every review, named by a state id the existing hook already records.

**Cons:**
- The reviewer can't recompute the id. Staleness is detected by the orchestrator
  comparing ids (both are files it can read).

### Reviewer diff: read-only `git` through Bash

**Cons:**
- Permission rules match command text. `git diff --output=…`, `--ext-diff`, textconv
  drivers and `git -c …` can write files or run programs, so a "read-only git" rule is
  not a boundary. Rejected.

### Reviewer diff: passed in the delegation prompt, or reviewer uses only Read/Glob

**Cons:**
- The orchestrator has no reliable way to produce a diff, and Read/Glob can't compute
  a delta against HEAD. Rejected.

### Integration: implementer runs `ship`

**Cons:**
- `ship` needs the developer's confirmation anyway. A background subagent pushing and
  merging mixes implementation with integration and adds authority for no gain.
  Rejected.

### Agent teams

**Cons:**
- Experimental, and enabling them changes ordinary delegation (a named subagent
  launches as a teammate), in classic mode too. Not enabled; a self-test checks it.

### Separate test / security / docs agents

**Cons:**
- `scripts/verify` already covers tests, the built-in `security-review` skill and the
  reviewer cover security, and docs are part of each task. No concrete need. Rejected.

---

## Consequences

### Positive

- Write restrictions are enforced by the harness. Smoke tests on Claude Code 2.1.312
  showed the orchestrator holding only `Agent, Read, Glob, Grep`, and spawning
  `Explore`, `general-purpose` or an untyped agent was refused.
- A failing check can't be silently reported as done: it blocks the implementer up to
  3 times, then the orchestrator's own Stop hook up to 3 times, then `ship` and CI.
- Classic mode is unchanged, apart from deferring the Stop check while a background
  subagent runs.

### Negative / Trade-offs

- Three agent prompts to maintain. `scripts/tests/agents.test.sh` pins their frontmatter
  to a canonical form and an exact tool set, so widening a tool list is a deliberate,
  tested change.
- More tokens than a classic session; worth it only for larger tasks.

### Risks

- "Implementer does not commit" is an instruction. Per-subcommand Bash limits per agent
  don't exist (`disallowedTools: Bash(git commit *)` removes all of Bash). An unwanted
  local commit is reversible and still gated by `ship` and CI.
- The reviewer and implementer share a model. Context separation is not independent
  judgment; the deterministic gates stay the primary guarantee.
- Runtime behavior can change between Claude Code versions. Re-run the smoke tests in
  `docs/architecture/orchestrated-mode.md` after upgrades.

### When to evolve

- **Worktrees / parallel implementers**: only when tasks are independent, touch
  disjoint files, and sequential time is a real bottleneck. Use `isolation: worktree`,
  and give each worktree its own verify run.
- **Implementer integrates**: only if the developer wants unattended integration and
  the GitHub ruleset (ADR-002) is active as the hard gate.

---

## Related

- ADR: [ADR-001](ADR-001-single-verification-entry-point.md), [ADR-002](ADR-002-layered-validation-and-github-gate.md), [ADR-004](ADR-004-permission-deny-rules-replace-git-guard.md)
- Docs: [orchestrated-mode.md](../architecture/orchestrated-mode.md) (usage, diagnosis, smoke tests)
- Config: `.claude/agents/`, `.claude/hooks/review-diff.sh`, `.claude/settings.json`
