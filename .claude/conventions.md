# Conventions

Naming, formatting, and organizational rules. Read on demand (not auto-loaded); the
skills link here. Claude must follow these in every file it creates or edits.

---

## File Naming

| Type | Pattern | Example |
|------|---------|---------|
| Feature spec | `kebab-case.md` | `user-authentication/spec.md` |
| ADR | `ADR-NNN-kebab-title.md` | `ADR-001-use-postgresql.md` |
| Architecture doc | `kebab-case.md` | `system-overview.md` |
| Test file | mirrors source file name | `user-auth.test.{ext}` |
| Template | `{type}-template.md` | `feature-template.md` |

---

## Folder Naming

- Always `kebab-case`
- Feature folders under `specs/features/` use the feature name: `specs/features/user-authentication/`

---

## Markdown Documents

- Use `#` for the document title (only one per file)
- Use `##` for major sections
- Use `###` for subsections
- Always include a brief description at the top of the file, below the title
- Use tables for structured comparisons
- Use code blocks with language tags for all code snippets

---

## ADR Numbering

- Sequential, starting at `001`
- Never reuse a number, even if an ADR is superseded
- When superseding, add a note to the old ADR and create a new one

---

## Branch Naming

Work on a branch, never directly on `master`/`main` (the `git-guard` hook warns you).

| Pattern | Example |
|---------|---------|
| `<type>/<short-name>` | `feat/user-auth`, `fix/expired-token`, `docs/adr-001` |

Use the same `type` values as commits (below).

---

## Commit Messages

Follow Conventional Commits:

```
<type>(<scope>): <short description>

[optional body]

[optional footer: refs, closes, breaks]
```

Types:
- `feat` — new feature
- `fix` — bug fix
- `docs` — documentation only
- `test` — adding or updating tests
- `refactor` — code change that is not a fix or feature
- `chore` — maintenance, tooling, dependencies

Examples:
```
feat(auth): add JWT refresh token flow
docs(adr): record decision to use PostgreSQL (ADR-001)
test(auth): add edge cases for expired token
```

---

## Spec Status Tags

Use these tags in spec and ADR files to indicate status:

| Tag | Meaning |
|-----|---------|
| `[DRAFT]` | Work in progress, not ready for review |
| `[REVIEW]` | Ready for review |
| `[ACCEPTED]` | Approved, implementation can begin |
| `[IMPLEMENTED]` | Code is merged |
| `[SUPERSEDED]` | Replaced by another document (link it) |
| `[DEPRECATED]` | No longer applicable |

---

## Language

- All technical documentation in **English**
- Comments in code in **English**
- Commit messages in **English**
