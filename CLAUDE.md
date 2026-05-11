# Claude Instructions

This file is the entry point for Claude when working on this project.
Read the files below **in order** before starting any task.

## Required Reading (in order)

1. `.claude/project.md` — project structure and purpose of each folder
2. `.claude/workflow.md` — development lifecycle: spec → ADR → impl → test → PR
3. `.claude/conventions.md` — naming, commits, status tags, and language rules

---

## Behavior Rules

These rules apply in every session, every task, without exception.

### Before Starting Any Task

- Always read `.claude/project.md`, `.claude/workflow.md`, and `.claude/conventions.md` first
- If the task involves a feature, check whether a spec already exists in `specs/features/`
- If no spec exists, write one before doing anything else — even for small changes
- If the task requires a significant technical decision, create an ADR before implementing

### While Working

- Never add scope that is not described in the spec
- If the implementation needs to diverge from the spec, update the spec first and explain why
- Use the templates in `templates/` whenever creating a new artifact
- Follow naming conventions from `.claude/conventions.md` exactly
- All files, commits, and documentation must be in English

### Before Considering a Task Done

- Tests are written and cover: happy path, edge cases from spec, failure scenarios
- Traceability matrix in `docs/traceability/traceability.md` is updated
- Status tags on spec and ADR files are updated to reflect current state
- CHANGELOG.md is updated if the change is user-facing

### When in Doubt

- Ask before making architectural decisions
- Ask before creating files or folders not described in `.claude/project.md`
- Do not assume — if something is ambiguous in the spec, flag it as an open question

---

## Quick Reference

| I need to... | Go to |
|--------------|-------|
| Understand the project structure | `.claude/project.md` |
| Know the development flow | `.claude/workflow.md` |
| Check naming or commit rules | `.claude/conventions.md` |
| Create a feature spec | `templates/feature-template.md` → `specs/features/{name}/spec.md` |
| Record an architecture decision | `templates/adr-template.md` → `docs/adr/ADR-NNN-title.md` |
| Document architecture | `templates/architecture-template.md` → `docs/architecture/` |
| Write a test plan | `templates/test-template.md` → `tests/` |
| Update traceability | `docs/traceability/traceability.md` |
| Open a PR | `templates/pr-template.md` |
