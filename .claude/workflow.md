# Development Workflow

This file defines the expected development lifecycle. Claude should follow this flow for every feature or change.

## The Flow

```
Spec → ADR (if needed) → Implementation → Tests → PR
```

Every step produces a file. Every file lives in a specific folder.

---

## Step 1 — Write the Feature Spec

**Before writing any code**, create a spec.

- Location: `specs/features/{feature-name}/spec.md`
- Template: `templates/feature-template.md`
- The spec defines: what the feature does, acceptance criteria, edge cases, and open questions.

> Do not start implementation until the spec is reviewed and accepted.

---

## Step 2 — Record Architecture Decisions (when needed)

If the feature requires a significant technical decision (choice of library, pattern, data model, integration approach), record it as an ADR.

- Location: `docs/adr/ADR-{NNN}-{short-title}.md`
- Template: `templates/adr-template.md`
- Numbering: sequential, zero-padded to 3 digits (e.g. `ADR-001`, `ADR-002`)

An ADR is needed when:
- A technology or library is being adopted or replaced
- A non-obvious architectural pattern is chosen
- A decision will be hard to reverse later
- There is disagreement or uncertainty about the approach

---

## Step 3 — Implement

- Source code goes in `src/`
- Follow the conventions in `.claude/conventions.md`
- Reference the spec while implementing — do not add scope that is not in the spec
- If the implementation diverges from the spec, update the spec first and note why

---

## Step 4 — Write Tests

- Tests go in `tests/`
- Use `templates/test-template.md` as the base for test documentation
- Cover: happy path, edge cases listed in the spec, and failure scenarios

---

## Step 5 — Update Traceability

After implementation and tests, update the traceability document.

- Location: `docs/traceability/traceability.md`
- Template: `templates/traceability-template.md`
- Link: feature spec → ADR (if any) → source files → test files

---

## Step 6 — Open a PR

- Use `templates/pr-template.md` as the base
- The PR description must reference: the spec, the ADR (if any), and the traceability entry
- `.github/PULL_REQUEST_TEMPLATE.md` pre-fills this on GitHub

---

## Summary Table

| Step | Output file | Location |
|------|-------------|----------|
| Spec | `spec.md` | `specs/features/{feature-name}/` |
| ADR | `ADR-NNN-title.md` | `docs/adr/` |
| Code | source files | `src/` |
| Tests | test files | `tests/` |
| Traceability | `traceability.md` | `docs/traceability/` |
| PR | pull request description | GitHub / `.github/` |

---

## Rules

- Never skip the spec step, even for small changes
- Never merge without tests
- ADRs are never deleted — if a decision is reversed, create a new ADR that supersedes the old one
- The traceability document is always up to date before a PR is merged
