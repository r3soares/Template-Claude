---
name: adr
description: Record an Architecture Decision Record (ADR) when adopting/replacing a technology or library, choosing a non-obvious pattern or data model, or making a decision that is hard to reverse. Use when the user asks to document a decision, or before implementing such a decision.
---

# ADR — Architecture Decision Record

Record the *why* behind a significant, hard-to-reverse technical decision, before
implementing it.

## When an ADR is needed

- A technology or library is being adopted or replaced.
- A non-obvious architectural pattern or data model is chosen.
- A decision will be costly to reverse later.
- There is genuine uncertainty between options worth documenting.

If none of these apply, skip the ADR.

## Steps

1. **Pick the next number.** Scan `docs/adr/` for the highest `ADR-NNN` and increment.
   Numbers are sequential, zero-padded to 3 digits, never reused.
2. **Create** `docs/adr/ADR-{NNN}-{short-title}.md` (`kebab-case` title) from
   `templates/adr-template.md`.
3. **Fill in**: Context (forces at play, options considered) → Decision (clear and
   direct) → Options Considered (pros/cons) → Consequences (positive, trade-offs, risks).
4. **Status**: `[DRAFT]` → `[REVIEW]` → `[ACCEPTED]`. Implement only after `[ACCEPTED]`.
5. **History table**: add a dated row for each edit.

## Superseding a decision

Never delete or rewrite an accepted ADR. To reverse one:
- Create a new ADR that states the new decision.
- Set the new ADR's `Supersedes: ADR-NNN`.
- On the old ADR, set status `[SUPERSEDED]` and `Superseded by: ADR-MMM`.

## Link it

Reference the ADR from the related feature spec and from the `traceability` matrix.
