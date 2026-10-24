# Claude Instructions

Entry point for Claude on this project. This file is intentionally small — it is
loaded into context every session. Specialized procedures live in **skills**
(`.claude/skills/`), which load when a task matches their description — invoke them
instead of reinventing their steps inline. Path-scoped rules (`.claude/rules/`) load
when you work on matching files. The project map is `docs/architecture/overview.md`.

> Replace this line with the project identity once the template is in use.

---

## Core Principles

These hold in every session, without exception.

- **Solo dev → simplicity.** Favor the smallest change that solves the problem. Do not
  add scaffolding, abstraction, or process the task does not need.
- **Process scales by size** (see decision rule below). Don't impose feature-level
  ceremony on a one-line fix.
- **English everywhere** — code, comments, docs, and commit messages.
- **Done means verified.** A change is done only when `./scripts/verify` passes — show
  the result, don't assume it. On failure, find the root cause and fix it (the `verify`
  skill) before asking the developer; never skip or weaken tests to get green.
- **Specs are the source of truth for features.** When code and spec disagree, fix the
  spec first, then the code.
- **Every change updates `CHANGELOG.md`** with a dated entry — even small ones. This is
  the lightweight history that is always current.
- **Docs describe the present, git records the past.** Don't keep hand-maintained
  history/edit logs inside files; `git log` answers "what changed", on demand.
- **Keep this file lean.** `CLAUDE.md` is paid in every session — put detail in skills or
  path-scoped rules, not here. If a rule isn't always-relevant, it doesn't belong in `CLAUDE.md`.

---

## Decision Rule: how much process?

| Change | What to do |
|--------|------------|
| **Small** (bug fix, copy tweak, config, refactor with no behavior change) | Code (+ regression test for a bug) → verify → commit → dated `CHANGELOG.md` entry → merge. No spec, no ADR. |
| **Feature / significant change** (new behavior, new surface, user-facing) | Full flow via skills: spec → ADR (if a real decision) → impl → tests → verify → merge. |
| **Significant technical decision** (library, data model, pattern hard to reverse) | Record an ADR before implementing (use the `adr` skill). |

When unsure which tier applies, ask before assuming.

---

## When in Doubt

- Ask before architectural decisions or before creating modules/folders not described in
  `docs/architecture/overview.md` (update the map when one is added).
- Don't assume — if a spec is ambiguous, flag it as an open question instead of guessing.

## Template Feedback

This project was created from the Template-Claude template. If an instruction that came
from it — `CLAUDE.md`, a skill, a rule, a hook, `scripts/`, a workflow or a
`templates/` file — turns out wrong, outdated (e.g. a Claude Code feature or tool
behaves differently now) or contradictory, tell the developer in a separate block, so
they can fix it in the template too:

> **Template feedback:** `<file>` — what is wrong · evidence · suggested fix

Do it as soon as you notice, even mid-task. Fix the local copy only if the developer asks.
