---
name: traceability
description: Maintain a formal traceability matrix — ONLY for projects that require it (audited, regulated, compliance). For typical solo-dev projects this is not used; the feature spec's Related section already links source and tests. Use only when the user explicitly asks for a traceability matrix or works under compliance.
---

# Traceability (optional / compliance)

Most projects do **not** need this. By default, each feature's links to its source and
test files live in the *Related* section of its spec (`templates/feature-template.md`),
kept current where the work happens — no separate, drift-prone file.

Use this skill only when the project genuinely requires a formal, central traceability
matrix (audited / regulated / compliance contexts), or when the user asks for one.

## Steps (when it applies)

1. **Create** `docs/traceability/traceability.md` from `templates/traceability-template.md`
   if it doesn't exist.
2. **Add or update the feature's row** with a sequential ID (`F-001`, …):
   feature name · spec link · ADR link (or `—`) · source files · test files · status.
3. **Set the status** from the legend (🔵 Spec → 🟡 In Progress → 🟠 Testing → 🟢 Done;
   🔴 Blocked, ⚫ Cancelled).
4. Keep the matrix current before merging a feature PR.

## Rule

If you're maintaining this matrix, the feature's spec *Related* section and this matrix
must not disagree. When in doubt, the spec is the source of truth.
