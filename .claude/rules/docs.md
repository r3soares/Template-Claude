---
paths:
  - "docs/**"
  - "specs/**"
  - "templates/**"
---

# Documentation Conventions

Applies to specs, ADRs, architecture docs and templates.

## File and folder naming

| Type | Pattern | Example |
|------|---------|---------|
| Feature spec | `specs/features/{kebab-name}/spec.md` | `specs/features/user-authentication/spec.md` |
| ADR | `docs/adr/ADR-NNN-kebab-title.md` | `ADR-005-use-postgresql.md` |
| Architecture doc | `docs/architecture/kebab-case.md` | `system-overview.md` |
| Template | `templates/{type}-template.md` | `feature-template.md` |

Folders are always `kebab-case`.

## Markdown

- One `#` title per file, followed by a one-line description; `##` sections, `###` subsections.
- Tables for structured comparisons; code blocks always carry a language tag.
- Describe the present; no hand-maintained history or edit logs — git records the past.

## ADR numbering

- Sequential, zero-padded to 3 digits, never reused — even when superseded.
- Superseding: new ADR with `Supersedes: ADR-NNN`; old one gets `[SUPERSEDED]` and
  `Superseded by: ADR-MMM`. Never delete or rewrite an accepted ADR.

## Status tags (specs and ADRs)

| Tag | Meaning |
|-----|---------|
| `[DRAFT]` | Work in progress, not ready for review |
| `[REVIEW]` | Ready for review |
| `[ACCEPTED]` | Approved, implementation can begin |
| `[IMPLEMENTED]` | Code is merged |
| `[SUPERSEDED]` | Replaced by another document (link it) |
| `[DEPRECATED]` | No longer applicable |
