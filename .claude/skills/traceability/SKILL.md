---
name: traceability
description: Update the traceability matrix that links each feature to its spec, ADR, source files, and tests. Use after implementing/testing a feature and before opening a PR for a significant change.
---

# Traceability

Keep `docs/traceability/traceability.md` current so every feature traces from spec to
tests. This is part of the full feature flow — small fixes don't need a row.

## Steps

1. **Open** `docs/traceability/traceability.md` (its shape comes from
   `templates/traceability-template.md`).
2. **Add or update the feature's row** with a sequential ID (`F-001`, `F-002`, …):
   - Feature name
   - Spec link (`specs/features/{name}/spec.md`)
   - ADR link, or `—` if none
   - Source files touched (`src/...`)
   - Test files (`tests/...`)
   - Status (use the legend in the file)
3. **Set the status** to reflect the real end-to-end state: 🔵 Spec → 🟡 In Progress →
   🟠 Testing → 🟢 Done. Use 🔴 Blocked or ⚫ Cancelled when applicable.
4. **Update the History table** with a dated row.

## Rule

The matrix must be current before a feature PR is merged. If a feature is descoped,
mark it ⚫ Cancelled rather than deleting the row.
