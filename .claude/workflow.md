# Development Workflow

The development lifecycle. Read on demand — `CLAUDE.md` holds the short version; this
file is the detail. Each step maps to a **skill** that carries its own procedure.

## Process scales by size

This is a solo-dev template: don't impose feature ceremony on a small change.

| Tier | What it is | Flow |
|------|-----------|------|
| **Small change** | Bug fix, copy tweak, config, refactor with no behavior change | Code → commit → dated `CHANGELOG.md` entry → PR. No spec, no ADR. |
| **Feature / significant change** | New behavior or user-facing surface | Spec → ADR (if needed) → impl → tests → PR. |

When unsure which tier applies, ask before assuming.

---

## The full flow (feature tier)

```
Spec → ADR (if needed) → Implementation → Tests → PR
```

Each step is driven by a skill.

| Step | Skill | Output | Location |
|------|-------|--------|----------|
| 1. Spec | `feature-spec` | `spec.md` | `specs/features/{name}/` |
| 2. ADR (if a real decision) | `adr` | `ADR-NNN-title.md` | `docs/adr/` |
| 3. Implement | — | source files | `src/` |
| 4. Tests | `test-plan` | test files | `tests/` |
| 5. PR | `open-pr` | branch + commit + PR | Git / GitHub |

### Step notes

1. **Spec first.** No code for a feature before its spec is `[ACCEPTED]`. If the
   implementation must diverge, update the spec first and note why.
2. **ADR only for real decisions** — adopting/replacing a library, a non-obvious pattern
   or data model, anything hard to reverse. Otherwise skip it.
3. **Implement** in `src/`, following `conventions.md`. No scope beyond the spec.
4. **Tests** cover happy path, the spec's edge cases, and failure scenarios — real tests
   in `tests/`, not a document.
5. **PR** uses Conventional Commits and links the spec/ADR (or `N/A`).

The spec's *Related* section is the feature index — point it at the source and test
files as you go. A formal traceability matrix (the `traceability` skill) is **optional**,
for audited/compliance projects only; a typical solo-dev project doesn't need it.

---

## Git

- Work on branches (`feat/…`, `fix/…`, `docs/…`), not directly on `master`/`main`.
  The `git-guard` hook warns if you forget.
- Conventional Commits — see `conventions.md`.
- The `open-pr` skill handles branch → commit → PR for both tiers.

## CI/CD

- A stack-agnostic GitHub Actions workflow lives at `.github/workflows/ci.yml`
  (lint + test on push/PR). Fill it in with the `setup-ci` skill.
- CI runs the same lint/test commands you run locally.

## Docker (conditional)

- Containerize only when the project type fits (SaaS/API/web/worker → yes;
  CLI/desktop/library → no). The `dockerize` skill has the full decision guide and
  applies the templates in `templates/docker/`.

---

## Maintenance

- **Dependencies**: update and audit periodically (not just when something breaks). A
  notable bump is a `CHANGELOG.md` entry; record an ADR only if it's a hard-to-reverse
  decision (e.g. swapping a core library).
- **Docs describe the present.** When behavior changes, update the spec/architecture doc
  that describes it — don't leave a doc asserting something the code no longer does.

---

## Rules

- Match process to change size — don't over-document a one-liner, don't under-document a
  feature.
- Never merge a feature without tests.
- ADRs are never deleted — supersede them (see the `adr` skill).
- `CHANGELOG.md` gets a dated entry for **every** change.
- No hand-maintained history tables inside docs — git records the past.
