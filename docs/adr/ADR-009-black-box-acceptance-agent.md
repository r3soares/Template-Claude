# ADR-009: Black-Box Acceptance Agent [ACCEPTED]

> A separate `acceptance` agent checks a change against its finish line by running the
> product the way a user would, without reading the implementation. A `PreToolUse` hook
> keeps it out of `src/` and `tests/`. It runs before the reviewer, for features with a
> finish line and for small user-visible changes with repro lines.

---

## Status

`[ACCEPTED]`

Supersedes: —  
Superseded by: —  
Amends: ADR-005 (orchestrator's delegation list), ADR-002 ("done" for features)  
Amended by: ADR-010 (decision 3: evidence moves to `.acceptance/<state>/`)

---

## Context

The quality gates (ADR-001, ADR-002) prove that the code passes the tests the
implementer wrote. The reviewer (ADR-005) reads the diff. Neither uses the product, so a
feature can be green and still broken for a user: an unrouted endpoint, missing wiring,
a blank page. The implementer judging its own work is the developer-as-QA problem.

The feature spec `specs/features/finish-line-acceptance/spec.md` adds a **Finish Line**
(an observable outcome with run and check steps) to every feature spec. Something has
to check it, independently.

Facts that shape the options:
- Hook input carries `agent_type` for tool calls made inside a subagent, so a
  project-level `PreToolUse` hook can apply to one agent only.
- `scripts/tests/agents.test.sh` accepts only flat `key: value` agent frontmatter, so
  hooks declared in an agent's frontmatter (nested YAML) would need a parser change.
- Acceptance needs a model to interpret steps and judge results, so it can't run in CI.

---

## Decision

1. **New agent `acceptance`** (`.claude/agents/acceptance.md`, `tools: Bash, Read`,
   `model: inherit`, `effort: high`). It reads the spec and the README's run
   instructions, starts the product in isolation (temp `HOME` and data dirs, a free
   port, stopped at the end), checks each criterion with `curl` or Playwright (when the
   project has it), and reports `PASS` / `FAIL` / `BLOCKED` per criterion with
   evidence. It never edits project files.
2. **Black box by hook**: `acceptance-guard.sh`, a `PreToolUse` hook on `Read` in
   `settings.json`, denies paths under `src/` and `tests/` when `agent_type` is
   `acceptance`. Every other agent passes through. It fails open on an unparseable
   payload: it guards against mistakes, it isn't a security boundary. Bash reads are
   forbidden by the prompt only (see Risks).
3. **Evidence by state**: a `SubagentStart` hook (`acceptance-start.sh`) creates
   `.claude/.state/acceptance/<state>/`, named by the `fingerprint.sh` workspace state,
   and passes the path and the state id via `additionalContext`, as `review-diff.sh`
   does for the reviewer. *(Amended by ADR-010: `.acceptance/<state>/`.)*
4. **When it runs** (the orchestrator or the classic main session decides, never the
   implementer): feature-tier changes whose spec has a Finish Line, and small changes
   that alter user-visible behavior, using one or two repro lines as the finish line.
   Skipped for refactors, docs, config and internal changes.
5. **Where**: orchestrated mode runs it after the implementer (verify green) and before
   the reviewer, so the reviewer sees a change that already works. `FAIL` findings join
   must-fix review findings in the single fix round, then one focused re-check. Classic
   mode: `integrate` step 4c.
6. **"Done" for a feature**: `verify` green and the finish line checked (`CLAUDE.md`).

---

## Options Considered

### Option A: Separate black-box agent with a hook guard (chosen)

**Pros:**
- Independence by construction: the tester never sees the code, only the spec.
- Reuses the existing patterns: tool allowlist, `SubagentStart` context, state ids.
- Works in classic and orchestrated mode, for any stack that can run locally.

**Cons:**
- More tokens and minutes per checked change.
- The Bash black box is instruction-only.

### Option B: End-to-end tests in the project (Playwright/BDD), run by `verify`

**Pros:**
- Deterministic, runs in CI, no model needed.

**Cons:**
- Written by the same implementer, so the same blind spots. Valuable and still
  encouraged by `test-plan`, but it doesn't replace an independent check.

### Option C: Let the reviewer also run the product

**Cons:**
- The reviewer reads the code by design; it can't be a black box. Mixing roles also
  dilutes the review. Rejected.

### Option D: Guard via hooks in the agent's frontmatter

**Pros:**
- The guard lives next to the agent.

**Cons:**
- Nested YAML breaks the canonical-frontmatter check that pins agent tool sets.
  Rejected for now; `settings.json` matches the existing hooks.

---

## Consequences

### Positive

- Features and user-visible fixes are checked against observable behavior, with
  evidence (HTTP excerpts, screenshots) a developer can review remotely.
- Specs get sharper: a finish line forces an observable goal.

### Negative / Trade-offs

- Cost: one more agent run per feature or user-visible fix, plus app start-up time.
- Web checks depend on Playwright being in the project; otherwise they report
  `BLOCKED`.
- The orchestrator's tool list gains `Agent(acceptance)`; `agents.test.sh` and smoke
  test 3 change.

### Risks

- **Bash bypass:** the agent could `cat src/...`. A Bash guard would also block
  legitimate commands that start the app from `src/`, so the prompt forbids it and the
  report must list the commands it ran.
- **Flaky environment:** ports, Docker or missing tools produce `BLOCKED`, not `FAIL`.
  The report keeps them apart, so an environment problem doesn't send good code back
  for a fix.
- **Skipping by classification:** "is this user-visible?" is a judgment. Keeping it with
  the orchestrator, not the implementer, removes the incentive to skip.

---

## Related

- Feature spec: [finish-line-acceptance](../../specs/features/finish-line-acceptance/spec.md)
- ADR: [ADR-002](ADR-002-layered-validation-and-github-gate.md),
  [ADR-005](ADR-005-orchestrated-mode.md), [ADR-007](ADR-007-autonomous-integration-in-orchestrated-mode.md)
