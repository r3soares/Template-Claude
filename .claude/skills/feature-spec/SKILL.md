---
name: feature-spec
description: Write or update a feature specification before implementing a new feature or significant change. Use when the user asks to start, plan, design, or spec a feature, or when a change adds new behavior or a user-facing surface. Not for small fixes.
---

# Feature Spec

A feature or significant change starts with a spec — it is the source of truth.
Small fixes (see the decision rule in `CLAUDE.md`) skip this entirely.

## Steps

1. **Check for an existing spec** under `specs/features/`. If one exists for this
   feature, update it instead of creating a new file.
2. **Create the spec** at `specs/features/{feature-name}/spec.md` (folder name in
   `kebab-case`). Base it on `templates/feature-template.md` — keep its sections.
3. **Fill in**, in order: Context (why) → Scope (in/out) → Acceptance Criteria →
   Edge Cases → Technical Notes → Open Questions.
4. **Status tag** in the title: start `[DRAFT]`, move to `[REVIEW]` when ready, then
   `[ACCEPTED]` once approved. Do not implement before `[ACCEPTED]`.
5. **History table**: add a dated row (`YYYY-MM-DD`) for every edit, including creation.
6. **Open Questions**: if anything in the request is ambiguous, list it here and surface
   it to the user rather than guessing.

## Rules

- Never add scope not described in the spec. If implementation must diverge, update the
  spec first and note why in History.
- If the feature needs a hard-to-reverse technical decision, use the `adr` skill before
  implementing.
- All content in English.

## Next steps after the spec is accepted

Implement in `src/` → use `test-plan` for tests → `traceability` to link artifacts →
`open-pr` to ship. Add a dated `CHANGELOG.md` entry.
