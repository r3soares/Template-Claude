---
name: feature-spec
description: Write or update a feature spec before implementing new behavior or a user-facing change. Use when asked to start, plan, design or spec a feature. Not for small fixes.
---

# Feature Spec

A feature or significant change starts with a spec — it is the source of truth.
Small fixes (see the decision rule in `CLAUDE.md`) skip this entirely.

## Steps

1. **Check for an existing spec** under `specs/features/`. If one exists for this
   feature, update it instead of creating a new file.
2. **Create the spec** at `specs/features/{feature-name}/spec.md` (folder name in
   `kebab-case`). Base it on `templates/feature-template.md` — keep its sections.
3. **Fill in**, in order: Context (why) → Impact → Scope (in/out) → Acceptance
   Criteria → Finish Line → Edge Cases → Technical Notes → Open Questions.
   - **Impact first:** read the code the feature touches and write how it works today,
     how it will work after, and the files that change. Show it to the developer
     before the rest — that's where a wrong approach is cheapest to catch.
   - **Observable criteria and a Finish Line:** phrase criteria as behavior seen from
     outside (a response, a screen, a command's output). The Finish Line says how to
     run the product and the steps that prove it works; the `acceptance` agent checks
     exactly that, without reading the code (ADR-009). No way to run it locally →
     point at a staging URL or say so in Open Questions.
   - **UI features — three directions:** before Technical Notes, write three distinct,
     self-contained HTML mockups (inline CSS, no build) in
     `specs/features/{feature-name}/directions/` (`a.html`, `b.html`, `c.html`).
     Screenshot them with Playwright if the project has it; otherwise point the
     developer at the files. The developer picks one or a mix; record the choice in
     Technical Notes. When the feature changes an existing screen, include a "before"
     screenshot next to the chosen direction.
4. **Status tag** in the title: start `[DRAFT]`, move to `[REVIEW]` when ready, then
   `[ACCEPTED]` once approved. Do not implement before `[ACCEPTED]`.
5. **Related section is the feature index**: as you implement, fill in the Source files
   and Tests paths there. The spec describes the *present* desired state — "what changed"
   is answered by git (`git log -p -- <spec>`), not a hand-maintained history table.
6. **Open Questions**: if anything in the request is ambiguous, list it here and surface
   it to the user rather than guessing.

## Rules

- Never add scope not described in the spec. If implementation must diverge, update the
  spec first and explain why in the commit message (git keeps the history).
- If the feature needs a hard-to-reverse technical decision, use the `adr` skill before
  implementing.
- All content in English.

## Next steps after the spec is accepted

Implement in `src/` (design for testability) → use `test-plan` to cover and write real
tests → `./scripts/verify full` green (the `verify` skill) → the Finish Line checked by
the `acceptance` agent (`integrate` step 4c) → keep the spec's
*Related* section pointing at the source/test files → if the feature added a module or
top-level folder, update `docs/architecture/overview.md` → `integrate` to merge. Add a dated
`CHANGELOG.md` entry. (A formal `traceability` matrix is optional — compliance only.)
