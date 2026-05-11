# Traceability Matrix

> Links every feature requirement to its implementation and tests. Updated before every PR merge.

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

### Status Legend

| Symbol | Meaning |
|--------|---------|
| 🔵 Spec | Spec written, not yet started |
| 🟡 In Progress | Implementation ongoing |
| 🟠 Testing | Implementation done, tests in progress |
| 🟢 Done | Implemented, tested, merged |
| 🔴 Blocked | Blocked by dependency or open question |
| ⚫ Cancelled | Descoped |

---

## History

| Date | Author | Change |
|------|--------|--------|
| YYYY-MM-DD | <!-- author --> | Created |
