# Feature: Bootstrap a New Project [ACCEPTED]

> `/bootstrap` turns a fresh copy of the template into the developer's project in one
> guided session, replacing the manual `SETUP.md` checklist.

---

## Context

The template is used as a GitHub template: "Use this template" creates a new repo
(usually private, on GitHub Free) with the files and one initial commit. Then the
developer follows `SETUP.md`: a 12-item manual checklist (identity, language, README,
project map, CHANGELOG, Docker, `scripts/verify` stages, CI runtime, Dependabot,
`VERIFY_STRICT`, ruleset, `.gitignore`, delete `SETUP.md`). It is the moment the
template is used most, and it is slow and easy to get half-done.

`SETUP.md` is also out of date: steps 1–2 (`git archive`, `git init`) don't apply to
"Use this template", and it says the project's own ADRs start at `ADR-005`, while the
template now ships ADR-001 to ADR-009.

Two practices from the video *como vibe codar corretamente* belong at this moment:
- **Architecture principles from the start:** decide how the code is split into
  modules and which way dependencies point (API modules expose abstractions,
  implementation modules depend on APIs, never on each other's internals; no cycles),
  so the agent places code correctly without being told every time.
- **Fast usage feedback:** know where the product runs (local only, a VPS, a PaaS),
  so feature Finish Lines can target it.

And one more: **version tags**, starting with `v0.1.0`, so a bug can be traced
between versions.

---

## Impact

**Today:** the developer reads `SETUP.md` and edits each file by hand, then runs the
`dockerize` and `setup-ci` skills. Nothing checks that every step was done.

**After:** the developer clones the new repo, runs `claude`, types `/bootstrap`,
answers a few questions, and gets a project ready for the first feature: files filled
in, Docker/CI decided and configured, `verify` green, the setup merged and tagged
`v0.1.0`. `SETUP.md` becomes a short pointer to `/bootstrap` and is deleted by it.

**Files touched:**

| File | Change |
|------|--------|
| `.claude/skills/bootstrap/SKILL.md` | New skill, invoked only as `/bootstrap` |
| `SETUP.md` | Rewritten: "Use this template" → clone → `/bootstrap`, plus what it does |
| `.claude/rules/docs.md` | ADR numbering: next free number (no fixed start) |
| `README.md`, `docs/architecture/overview.md` | Mention `/bootstrap`; skills list |
| `scripts/tests/` | Static check of the skill's frontmatter and its key steps |
| `CHANGELOG.md` | Entry |

---

## Scope

### In Scope

- A `bootstrap` skill with `disable-model-invocation: true`: it runs only when the
  developer types `/bootstrap`, and its description isn't loaded into every turn.
- **Guard:** if `SETUP.md` is gone and the `CLAUDE.md` identity placeholder is replaced,
  the project is already bootstrapped: say so and stop. A partly done bootstrap
  resumes at the first step not yet done.
- **Questions, asked together** (skip any the developer already answered in the
  request):
  1. Project name and one-line description.
  2. Stack (language, framework, package manager).
  3. Conversation language (code and docs stay in English).
  4. Where it runs: local only / VPS or own server / PaaS (e.g. Vercel, Render) /
     undecided — plus a staging URL if one exists.
  5. Module structure: single module / API and implementation modules (names) /
     decide later.
- **Writes:**
  - `CLAUDE.md`: identity line and `Reply to the developer in:`. Offers to set
    `"language"` in `.claude/settings.local.json` (untracked) so it is enforced.
  - `README.md`: name, description, prerequisites, install/run/test commands for the
    stack, and an *Environments* section (local run command; staging URL if any) —
    the `acceptance` agent reads run instructions there.
  - `docs/architecture/overview.md`: overview paragraph, stack, first modules under
    *Components*.
  - `.claude/rules/architecture.md` (only for "API and implementation modules"):
    `paths: ["src/**"]`, the module list, the allowed dependency direction, no cycles.
  - `CHANGELOG.md`: reset to the header plus `[Unreleased]` with one dated entry
    ("project created from Template-Claude"); the template's history doesn't belong to
    the project.
  - `.gitignore`: uncomment the stack's section; `.editorconfig` if the stack differs.
- **Delegates** to the existing skills: `dockerize` (its decision guide), then
  `setup-ci` (verify stages, CI runtime, Dependabot ecosystem, `VERIFY_STRICT`, ruleset
  or agent gate). No step of theirs is repeated in `bootstrap`.
- **Finishes:** `./scripts/verify full` green; deletes `SETUP.md`; integrates through
  `integrate` (branch `chore/bootstrap`, PR on GitHub — confirm first); after the
  merge, offers to create and push the annotated tag `v0.1.0` (confirm first).
- Keeps everything the template ships for the project: ADRs, the
  `finish-line-acceptance` spec, skills, agents, hooks, templates.
- `SETUP.md` rewritten for "Use this template" and pointing at `/bootstrap`; the ADR
  numbering rule becomes "next free number".

### Out of Scope

- Creating the GitHub repo (the developer uses "Use this template").
- Writing application code or a first feature (the `feature-spec` skill does that).
- Deploy pipelines or staging setup (the deploy target is only recorded).
- A release/versioning skill beyond the first tag.
- Enforcing module boundaries in CI (recorded as a rule now; enforcement is a
  project-level decision once there are modules).

---

## Acceptance Criteria

- [ ] On a fresh copy of the template, `/bootstrap` asks only the questions not
      answered in the request, then leaves: no template placeholder in `CLAUDE.md`,
      `README.md` or `overview.md`; `CHANGELOG.md` with one project entry; no
      `SETUP.md`.
- [ ] Choosing "API and implementation modules" creates
      `.claude/rules/architecture.md` with `paths:` and the module dependency rules;
      other choices don't.
- [ ] `README.md` has run instructions and an *Environments* section the `acceptance`
      agent can follow.
- [ ] Docker and CI are configured through `dockerize` and `setup-ci`; on a private
      GitHub Free repo, the ruleset is skipped with the agent-gate explanation.
- [ ] `./scripts/verify full` is green at the end, and the setup lands on master via
      `integrate`, followed by the `v0.1.0` tag when the developer confirms.
- [ ] Running `/bootstrap` again on a bootstrapped project stops without changes.
- [ ] The skill is not auto-invoked (`disable-model-invocation: true`), and a static
      self-test pins that and its key steps.

---

## Finish Line

- **Outcome:** a repo created with "Use this template" becomes a ready project in one
  `/bootstrap` session.
- **Run:** a throwaway copy of the template (`git archive HEAD | tar -x`, `git init`,
  one commit), then `claude -p "/bootstrap <answers to the five questions>"` with the
  permissions from the smoke-test setup in `docs/architecture/orchestrated-mode.md`.
- **Environment:** `local`
- **Check:**
  1. `grep -n "Replace this line" CLAUDE.md` → no match; `CLAUDE.md` has the project
     identity and language.
  2. `SETUP.md` → absent; `CHANGELOG.md` → one `[Unreleased]` entry.
  3. With "API and implementation modules": `.claude/rules/architecture.md` exists with
     `paths:`.
  4. `./scripts/verify full` → `verify: OK`.
  5. Run `/bootstrap` again → "already bootstrapped", `git status` clean.

---

## Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| Already bootstrapped | Says so, changes nothing |
| Interrupted half-way, run again | Resumes at the first step not done; finished steps untouched |
| No GitHub remote | `setup-ci` configures local stages only; `integrate` in local mode; tag stays local unless the developer pushes it |
| Stack not decided yet | Fills what it can, leaves `scripts/verify` stages for later (`setup-ci` reports them as not configured), says so in the summary |
| Deploy target "undecided" | *Environments* lists local only |
| `verify` red at the end | Fix per the `verify` skill; don't delete `SETUP.md` or integrate until green |
| Developer declines the PR or the tag | Leaves the branch / skips the tag and says what remains |

---

## Technical Notes

- `disable-model-invocation: true` keeps the skill out of the model's automatic skill
  selection and out of the per-turn skill list; it runs when invoked as `/bootstrap`.
  Confirm in the smoke test that the field is honored by the current Claude Code.
- The skill orchestrates; it doesn't duplicate. Docker, CI, verify stages, ruleset and
  integration stay in `dockerize`, `setup-ci` and `integrate`.
- The architecture rule's dependency direction follows the API/implementation
  principle: implementation modules depend on API modules; API modules depend on no
  implementation; integrating two modules is an implementation's job; no cycles.

---

## Open Questions

None.

---

## Related

This section is the feature's index — keep it current as you implement.

- ADR: — (no hard-to-reverse decision; process only)
- Spec: [finish-line-acceptance](../finish-line-acceptance/spec.md) (README run
  instructions feed the `acceptance` agent)
- Source files: `.claude/skills/bootstrap/SKILL.md`, `SETUP.md`, `.claude/rules/docs.md`,
  `README.md`
- Tests: `scripts/tests/skills.test.sh`; runtime: the Finish Line above, run as a smoke
  test on a throwaway copy
