# Claude Instructions

Entry point for Claude on this project. This file is intentionally small — it is
loaded into context every session. Specialized procedures live in **skills**
(`.claude/skills/`), which load only when a task triggers them. Reference docs
(`.claude/project.md`, `.claude/workflow.md`, `.claude/conventions.md`) are read
**on demand**, not eagerly.

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
  reference docs, not here. If a rule isn't always-relevant, it doesn't belong in `CLAUDE.md`.

---

## Decision Rule: how much process?

| Change | What to do |
|--------|------------|
| **Small** (bug fix, copy tweak, config, refactor with no behavior change) | Code (+ regression test for a bug) → verify → commit → dated `CHANGELOG.md` entry → merge. No spec, no ADR. |
| **Feature / significant change** (new behavior, new surface, user-facing) | Full flow via skills: spec → ADR (if a real decision) → impl → tests → verify → merge. |
| **Significant technical decision** (library, data model, pattern hard to reverse) | Record an ADR before implementing (use the `adr` skill). |

When unsure which tier applies, ask before assuming.

---

## Which skill, when

Invoke these skills (don't reinvent their steps inline):

| When you need to… | Skill |
|-------------------|-------|
| Start a feature / write a spec | `feature-spec` |
| Record an architecture decision | `adr` |
| Cover and write tests, design for testability | `test-plan` |
| Validate a change, fix failing checks/CI | `verify` |
| Branch, commit, merge to master (push optional) | `ship` |
| Formal traceability matrix (compliance only) | `traceability` |
| Containerize the project (when it fits) | `dockerize` |
| Set up CI, verify stages, branch protection | `setup-ci` |

---

## Reference docs (read on demand)

| To understand… | Read |
|----------------|------|
| Folder structure & purpose | `.claude/project.md` |
| The development lifecycle | `.claude/workflow.md` |
| Naming, commits, status tags | `.claude/conventions.md` |

---

## When in Doubt

- Ask before architectural decisions or before creating files/folders not described in
  `.claude/project.md`.
- Don't assume — if a spec is ambiguous, flag it as an open question instead of guessing.
