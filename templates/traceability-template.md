# Traceability Matrix

> **Optional — for projects that require formal traceability** (audited / regulated /
> compliance contexts). For a typical solo-dev project, skip this file: the spec's
> *Related* section already links each feature to its source and test files, kept current
> where the work happens. See the `traceability` skill.

---

## How to Use

- Add a row for each feature or significant change
- Link each artifact as it is created
- Status reflects the current state of the feature end-to-end

---

## Matrix

| ID | Feature | Spec | ADR | Source Files | Test Files | Status |
|----|---------|------|-----|--------------|------------|--------|
| F-001 | <!-- Feature name --> | [spec](../../specs/features/feature-name/spec.md) | — | `src/...` | `tests/...` | 🔵 Spec |
| F-002 | | | | | | |

### Status Legend

| Symbol | Meaning |
|--------|---------|
| 🔵 Spec | Spec written, not yet started |
| 🟡 In Progress | Implementation ongoing |
| 🟠 Testing | Implementation done, tests in progress |
| 🟢 Done | Implemented, tested, merged |
| 🔴 Blocked | Blocked by dependency or open question |
| ⚫ Cancelled | Descoped |
