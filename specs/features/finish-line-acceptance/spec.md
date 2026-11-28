# Feature: Finish Line and Black-Box Acceptance [IMPLEMENTED]

> Every feature spec states a finish line observable outside the code, and an
> independent `acceptance` agent checks it the way a user would, without reading the
> implementation.

---

## Context

Today "done" means `./scripts/verify` is green. That is a code-level criterion: the
same agent that wrote the code also wrote the tests that judge it, and the reviewer
only reads the diff. Nobody uses the product. A feature can pass every check and still
not work for a user: wrong route, missing wiring, a page that renders blank.

Two practices fix this (from the video *como vibe codar corretamente*):

1. **A finish line outside the code.** The goal of a feature is an observable outcome:
   "`POST /orders` returns 201 and the order shows in `GET /orders`", not "tests pass".
   An agent working toward an observable goal checks the real thing.
2. **A client agent.** A separate agent that knows only the spec, runs the built
   product, and uses it like a customer. It is the developer-as-QA problem solved by
   separation: the tester never saw the code.

Two smaller practices from the same source fit the same flow:

3. **Before/after before deciding.** Before proposing a change, show how it works today,
   which files it touches, and how it will work. This makes the change precise and acts
   as a cheap architecture review.
4. **Three visual directions for UI work.** For a new screen, compare three directions
   before writing production code, then show before/after screenshots. Iterating on
   mockups is much cheaper than iterating in code.

Screenshots and HTTP transcripts from the acceptance agent also serve a developer who
follows the work remotely (for example from a phone over Remote Control): the evidence
is in the report, not only in a test log.

---

## Impact

**Today:**
- `templates/feature-template.md` has Context, Scope, Acceptance Criteria, Edge Cases,
  Technical Notes, Open Questions, Related. Criteria can be anything, often internal.
- `feature-spec` fills those sections. No impact analysis, no UI directions.
- Orchestrated mode: implementer → `verify` hook → reviewer (features, risky changes) →
  integrator. Classic mode: `integrate` runs verify, security review (features), then
  merges.
- `CLAUDE.md`: "Done means verified" = `./scripts/verify` passes.

**After:**
- The spec template gains **Impact** (today / after / files) and **Finish Line**
  (observable outcome, how to run, how to check, target environment).
- `feature-spec` fills both, and for UI features produces three HTML directions and
  records the choice.
- A new read-only-on-code agent, `acceptance`, checks the Finish Line and each
  acceptance criterion against the running product, with evidence.
- It runs for feature-tier changes whose spec has a Finish Line, and for small changes
  that alter user-visible behavior (checked against one or two repro lines): in
  orchestrated mode after the implementer's verify is green and before the reviewer;
  in classic mode as a step of `integrate`.
- "Done" for a feature = verify green **and** the finish line checked.

**Files touched:**

| File | Change |
|------|--------|
| `templates/feature-template.md` | New Impact and Finish Line sections |
| `.claude/skills/feature-spec/SKILL.md` | Fill Impact and Finish Line; UI directions step |
| `.claude/agents/acceptance.md` | New agent (`tools: Bash, Read`) |
| `.claude/hooks/acceptance-guard.sh` | New PreToolUse hook: deny `Read` under `src/`, `tests/` for `acceptance` |
| `.claude/hooks/acceptance-start.sh` | New SubagentStart hook: evidence dir + workspace state |
| `.claude/settings.json` | Register both hooks |
| `.claude/agents/orchestrator.md` | Delegate to `acceptance`; tools gain `Agent(acceptance)` |
| `.claude/skills/integrate/SKILL.md` | Acceptance step for features (classic mode) |
| `CLAUDE.md` | One clause: features also need the finish line checked |
| `scripts/tests/` | Agent tools, hook behavior, settings wiring |
| `docs/adr/ADR-009-*.md` | Decision: separate black-box agent, guard by hook |
| `docs/architecture/orchestrated-mode.md`, `overview.md`, `README.md` | Flow, smoke tests, map |
| `CHANGELOG.md` | Entry |

---

## Scope

### In Scope

- Spec template: **Impact** and **Finish Line** sections. Finish Line fields: outcome
  (one sentence a user would recognize), run (command that starts the product
  locally, or a URL), check (numbered steps: HTTP requests or browser actions with
  expected results), environment (`local` by default, or a staging URL).
- `feature-spec`: fill Impact before Scope; write the Finish Line with criteria phrased
  as observable behavior; for features with a user interface, write three
  self-contained HTML mockups in `specs/features/{name}/directions/` (`a.html`,
  `b.html`, `c.html`), screenshot them, ask the developer to pick one (or a mix), and
  record the choice in Technical Notes.
- `acceptance` agent:
  - Reads only the spec (Finish Line, Acceptance Criteria, Edge Cases) and the README's
    run instructions. Never reads `src/` or `tests/`.
  - Starts the product as the Finish Line says, in isolation: temp `HOME` and data
    dirs, a free port, stopped at the end.
  - Checks HTTP APIs with `curl`; checks web UIs with Playwright when the project
    has it (screenshots per checked step).
  - Report: per criterion `PASS` / `FAIL` / `BLOCKED` with evidence (command and
    response excerpt, or screenshot path), the workspace state id, and the evidence
    directory.
- Guard hook: `PreToolUse` on `Read` denies paths under `src/` and `tests/` when
  `agent_type` is `acceptance`. Other agents are unaffected.
- Start hook: `SubagentStart` for `acceptance` creates
  `.claude/.state/acceptance/<state>/` and passes its path and the state id
  (`fingerprint.sh`) via `additionalContext`.
- **When acceptance runs** (decided by the orchestrator, or the main session in classic
  mode — never by the implementer, who would be judging its own change):
  - feature-tier changes whose spec has a Finish Line;
  - small changes that alter user-visible behavior (an endpoint, a screen, a command's
    output). The finish line is one or two repro lines in the task: "before: …,
    after: …". No repro lines → no acceptance run, reported as skipped;
  - skipped for refactors, docs, config and internal-only changes.
- Orchestrated mode: for those tasks, run `acceptance` after
  the implementer (verify green), before the reviewer. `FAIL` findings go back to the
  implementer in the same single fix round as must-fix review findings, then one
  focused re-check. Still failing → stop and report, don't commit.
- Classic mode: `integrate` step 4c for the same cases — spawn the
  `acceptance` agent; fix `FAIL`s before asking the developer to integrate.
- Final reports (orchestrator, `integrate` step 5) list the acceptance verdict and the
  evidence paths.

### Out of Scope

- Deploying to staging. The Finish Line can point at a staging URL, but setting one up
  is a separate, project-specific concern.
- Installing Playwright. If a web criterion needs it and the project doesn't have it,
  the criterion is `BLOCKED` with that reason; `test-plan` / `setup-ci` remain where
  test tooling is chosen.
- Mobile, desktop GUI and CLI-only products. CLI products can still write their Finish
  Line as commands and expected output; the agent runs them with Bash. No special
  support beyond that.
- A design-tool MCP (Figma, Paper). HTML mockups work everywhere without auth.
- Enforcing the black box on Bash: the guard covers `Read`; Bash reads of the code are
  forbidden by the agent's prompt only (a Bash guard would also block legitimate
  commands that start the app from `src/`).
- Running acceptance in CI. It needs a model; CI stays `scripts/verify`.

---

## Acceptance Criteria

- [ ] A new spec created by `feature-spec` has Impact and Finish Line sections filled,
      with criteria a user could observe.
- [ ] For a UI feature, `feature-spec` produces three HTML directions with screenshots
      and records the developer's choice.
- [ ] In orchestrated mode, a feature task whose spec has a Finish Line is checked by
      `acceptance` before review, and the final report shows its verdict and evidence
      paths.
- [ ] A deliberately broken feature (e.g. the endpoint exists in code but is not
      routed) passes `verify` but gets `FAIL` from `acceptance`, with evidence.
- [ ] `acceptance` cannot read `src/` or `tests/` with `Read` (the hook denies it);
      other agents can.
- [ ] In classic mode, `integrate` runs acceptance for a feature before asking to merge.
- [ ] A small user-visible fix with repro lines is checked by `acceptance`; refactors,
      docs, config, internal changes and specs without a Finish Line skip it.
- [ ] Self-tests pin the new agent's tools and the hooks' wiring and behavior;
      `./scripts/verify` is green.

---

## Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| The product fails to start | Every criterion `BLOCKED`, with the start command's output; reported, not retried in a loop |
| Web criterion, project has no Playwright | That criterion `BLOCKED: no Playwright`; HTTP criteria still checked |
| Port already in use | Pick another free port; never kill a process it didn't start |
| Finish Line points at a staging URL that is unreachable | `BLOCKED` with the error; no fallback to local unless the spec allows it |
| The spec has no Finish Line | Acceptance skipped; reported as "no finish line" |
| Small user-visible change without repro lines | Skipped and reported; the orchestrator adds repro lines to the task when it can state them |
| `acceptance` tries `Read src/app.py` | Denied by the hook with a reason; the agent continues black-box |
| A criterion is ambiguous | `BLOCKED: ambiguous` with the question; never guessed |
| The tree changes after acceptance ran | The report's state id no longer matches `verify-pass`; the orchestrator re-runs acceptance before committing |

---

## Technical Notes

- Hook input carries `agent_type` for tool calls made inside a subagent (Claude Code
  hooks docs), so one project-level `PreToolUse` hook can scope the guard to
  `acceptance`. Agent-frontmatter `hooks:` would also work, but `agents.test.sh`
  accepts only flat `key: value` frontmatter; keeping hooks in `settings.json` matches
  the existing `review-diff` / `verify-on-stop` pattern.
- The guard denies with `permissionDecision: "deny"` and a reason; it never blocks other
  agents and fails open (allows) on an unparseable payload, since it is a guard against
  mistakes, not a security boundary.
- Evidence lives in `.claude/.state/` (already gitignored), named by the workspace state
  so a report can be matched to a tree, like `review-<state>.diff`.
- `acceptance` uses `model: inherit` and `effort: high`: judging observable behavior is
  where an independent, careful pass pays off.
- UI directions are throwaway HTML (inline CSS, no build step), screenshotted with
  Playwright when available; otherwise the developer opens the files.
- A real decision (separate agent, black-box by hook, placement before review) →
  ADR-009 before implementing.

---

- This spec ships with projects created from the template, like ADR-005–009: it
  documents how the feature was designed.

---

## Open Questions

None.

---

## Related

This section is the feature's index — keep it current as you implement.

- ADR: [ADR-009](../../../docs/adr/ADR-009-black-box-acceptance-agent.md)
- Spec: —
- Source files: `templates/feature-template.md`, `.claude/skills/feature-spec/SKILL.md`,
  `.claude/agents/acceptance.md`, `.claude/agents/orchestrator.md`,
  `.claude/hooks/acceptance-guard.sh`, `.claude/hooks/acceptance-start.sh`,
  `.claude/settings.json`, `.claude/skills/integrate/SKILL.md`, `CLAUDE.md`
- Tests: `scripts/tests/acceptance-hooks.test.sh`, `scripts/tests/agents.test.sh`;
  runtime: smoke tests 11–12 in `docs/architecture/orchestrated-mode.md`
