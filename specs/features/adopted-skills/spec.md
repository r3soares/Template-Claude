# Feature: Adopted Skills — grill-me, diagnosing-bugs, handoff, retro [ACCEPTED]

> Four skills adapted from Matt Pocock's `skills` collection (MIT) fill the template's
> gaps before and after the code: settling a design, hunting a hard bug, handing a
> session over, and improving the agent's environment.

---

## Context

The template covers the middle of the work well: spec, ADR, implementation, tests,
verify, acceptance, review, integration. It is thin at the edges:

- **Before the spec**, an under-specified request goes straight into `feature-spec`,
  whose *Open Questions* section collects what wasn't settled — after the fact.
- **A reported bug** has no procedure. The `verify` skill fixes red checks; it doesn't
  say how to hunt a bug nobody has a test for.
- **Long sessions** (often followed remotely) have no way to hand over to a fresh one.
- **The environment** only improves when someone notices: the `Template feedback`
  block catches wrong instructions, not missing checks or expensive habits.

Matt Pocock's collection (github.com/mattpocock/skills, MIT) has a skill for each.
Most of the collection overlaps the template (`to-spec`, `implement`, `code-review`,
`pr`, `tdd`, `triage`) and stays out: two skills for one job compete for the same
trigger. Only the four that fill a gap are adopted, adapted to the template's flow.

---

## Impact

**Today:** no interview step; bugs are handled ad hoc; no handoff; no retrospective.

**After:**

| Skill | Invoked | Role in the flow |
|-------|---------|------------------|
| `grill-me` | by the model ("grill me", "stress-test this") or `/grill-me` | Interview in rounds until every design decision is settled, then hand off to `feature-spec` or `adr` |
| `diagnosing-bugs` | by the model (a reported bug, wrong output, slowness) | Red feedback loop first, then minimise, hypothesise, instrument, fix with a regression test, clean up; then `integrate` as a small fix |
| `handoff` | `/handoff` only | Write a handoff document to the temp dir, pointing at specs/ADRs/branches instead of copying them |
| `retro` | `/retro` only | Review a session and propose improvements mapped to the template's pieces, with `Template feedback` blocks for template-level issues |

**Files touched:**

| File | Change |
|------|--------|
| `.claude/skills/grill-me/SKILL.md` | New (from `grilling` + `grill-me`) |
| `.claude/skills/diagnosing-bugs/SKILL.md`, `scripts/hitl-loop.template.sh` | New |
| `.claude/skills/handoff/SKILL.md` | New |
| `.claude/skills/retro/SKILL.md` | New |
| `.claude/skills/*/LICENSE` | MIT notice of the original, in each adopted skill |
| `.claude/skills/feature-spec/SKILL.md` | Suggest `/grill-me` when design decisions are open |
| `.claude/skills/verify/SKILL.md` | Point reported bugs to `diagnosing-bugs` |
| `.claude/skills/*/evals/` | Eval cases for `grill-me` and `diagnosing-bugs` |
| `scripts/tests/skills.test.sh` | Frontmatter and licence checks |
| `README.md`, `CHANGELOG.md` | Skills list, entry |

---

## Scope

### In Scope

- **`grill-me`** — the `grilling` method as one skill: design tree, rounds of the
  whole frontier, numbered questions each with a recommended answer worded so "yes"
  accepts it, facts looked up by Claude (an `Explore` subagent for broad sweeps) and
  decisions left to the developer. Asked in the conversation language. Ends only when
  the frontier is empty and the developer confirms; then offers the next step:
  `feature-spec` (settled decisions feed Impact and Scope, nothing left for Open
  Questions) or `adr` for a single hard decision. Writes no files itself.
- **`diagnosing-bugs`** — the original's six phases (feedback loop, reproduce and
  minimise, ranked falsifiable hypotheses, one-variable instrumentation with tagged
  logs, regression test before the fix at a correct seam, cleanup) and its redaction
  rule, adapted:
  - project map and ADRs (`docs/architecture/overview.md`, `docs/adr/`) instead of
    `GLOSSARY.md`;
  - the regression test follows `test-plan`; done means `./scripts/verify` green;
  - the Phase 1 loop's before/after becomes the repro lines for the `acceptance` agent
    when the bug is user-visible;
  - it ends in `integrate` as a small fix, with the confirmed hypothesis in the commit
    message;
  - the HITL loop script ships with the skill.
- **`handoff`** — user-invoked; writes to `$TMPDIR` (else `/tmp`), references the spec,
  ADRs, branch, PR and `CHANGELOG.md` entries instead of repeating them, lists
  suggested skills, redacts secrets, and tailors to an optional argument.
- **`retro`** — user-invoked; reads the session and proposes improvements in order of
  severity, mapped to the template: `CLAUDE.md` kept lean, `.claude/rules/` for an area,
  the reviewer for judgement calls, `scripts/verify` / hooks / deny rules for anything
  mechanical, skills for procedures, tool economy, information access. Problems that
  come from the template itself are written as `Template feedback` blocks.
- Each adopted skill keeps the original's MIT copyright notice in a `LICENSE` file next
  to `SKILL.md`, and says in one line where it was adapted from.
- `feature-spec` suggests `/grill-me` when a request leaves design decisions open;
  `verify` points a reported bug (no failing check yet) to `diagnosing-bugs`.
- Eval cases: `grill-me` asks a numbered round with recommendations and writes nothing;
  `diagnosing-bugs` builds a red loop before proposing a cause, and finishes with a
  regression test.

### Out of Scope

- The rest of the collection, including the `grilling` / `grill-me` split, the
  `writing-for-agents` style guide, issue-tracker skills and `setup-matt-pocock-skills`.
- Installing the upstream plugin, or keeping these copies in sync with it.
- Evals for `handoff` and `retro` (prose output, judged by reading).

---

## Acceptance Criteria

- [ ] "Grill me on this plan: …" starts a round of numbered questions, each with a
      recommended answer, in the conversation language, and no file is written.
- [ ] After the developer confirms a shared understanding, `grill-me` offers
      `feature-spec` or `adr` as the next step.
- [ ] A reported bug ("`GET /orders` returns 500 when …") triggers `diagnosing-bugs`,
      which shows a command that goes red on the bug before it states a cause.
- [ ] The fix comes with a regression test, `./scripts/verify` green, and no
      `[DEBUG-` tag left in the tree.
- [ ] `/handoff` writes a document outside the project that references existing
      artifacts by path.
- [ ] `/retro` lists improvements mapped to template pieces, by severity.
- [ ] Each adopted skill has a `LICENSE` with the original MIT notice; `handoff` and
      `retro` are not model-invoked; self-tests pin both.

---

## Finish Line

- **Outcome:** the four skills are available in a project created from the template and
  behave as above.
- **Run:** the eval cases, via `scripts/tests/run-skill-evals.sh` (a throwaway template
  copy with the demo orders app).
- **Environment:** `local`
- **Check:**
  1. `grill-me` case → a numbered round with recommendations, clean working tree.
  2. `diagnosing-bugs` case on a seeded bug → a red command shown before the cause, a
     regression test added, `verify` green, no `[DEBUG-` left.

---

## Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| Developer answers only part of a round | Recompute the frontier; re-ask what's open next round |
| A grill question needs a fact from the code | Claude looks it up; never asks the developer for it |
| Bug can't be reproduced by a command | Stop, list what was tried, ask for access, an artifact or instrumentation — no guessing |
| A red `verify` (not a reported bug) | `verify` skill, not `diagnosing-bugs` |
| No correct seam for a regression test | Say so as a finding; don't add a shallow test for false confidence |
| `/handoff` with nothing worth handing over | Short document; says so |

---

## Technical Notes

- `grill-me` and `diagnosing-bugs` stay model-invoked: their triggers ("grill me", a
  bug report) are exactly when they should load, and their descriptions are short.
  `handoff` and `retro` are deliberate commands (`disable-model-invocation: true`).
- Upstream text is adapted, not vendored: the procedures are kept, references to
  upstream-only files and skills are replaced with template equivalents. The `LICENSE`
  file satisfies MIT's notice requirement.

---

## Open Questions

None.

---

## Related

This section is the feature's index — keep it current as you implement.

- ADR: — (adopting procedures, nothing hard to reverse)
- Spec: [finish-line-acceptance](../finish-line-acceptance/spec.md) (repro lines feed
  the `acceptance` agent)
- Source files: `.claude/skills/{grill-me,diagnosing-bugs,handoff,retro}/` (`SKILL.md`,
  `LICENSE`; `diagnosing-bugs/scripts/hitl-loop.template.sh`),
  `.claude/skills/feature-spec/SKILL.md`, `.claude/skills/verify/SKILL.md`
- Tests: `scripts/tests/skills.test.sh`; evals in `.claude/skills/grill-me/evals/` and
  `.claude/skills/diagnosing-bugs/evals/`
