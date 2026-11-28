---
name: retro
description: Retrospective on a coding session — propose improvements to the agent's environment (rules, checks, skills, hooks, docs) by severity. Run as /retro [session].
disable-model-invocation: true
---

# Retro

Adapted from `retro` in Matt Pocock's skills (github.com/mattpocock/skills, MIT — see
`LICENSE`), rewritten for this template's pieces.

You suggest improvements to the agent's **environment** so future sessions go better.
Read the primary sources of the session the developer names (default: the current
one) — the conversation, tool calls, failed attempts, hook and verify output.

## Where an improvement belongs

Look for these, and map each to the cheapest place that fixes it for good:

- **Navigation** — the agent took long to find something, or missed a hidden link
  between files → a pointer in `docs/architecture/overview.md`, or a path-scoped
  `.claude/rules/<area>.md`. `CLAUDE.md` only for what every session needs.
- **Automated checks** — a mistake a check could have caught → a deterministic check in
  `scripts/verify`'s stages (the only place check commands live, ADR-001), a hook in
  `.claude/settings.json`, or a `permissions.deny` rule. A check that exists but isn't
  wired into `scripts/verify` or CI is the finding. Prefer a check over a written rule
  for anything mechanical (a banned API, an import shape, a file location).
- **Judgement calls** — something only a reader can judge (cross-file consistency,
  matching surrounding style) slipped through → a rule for the `reviewer` agent, or the
  area's `.claude/rules/` file. The reviewer has the least context pressure, so
  standards belong to review, not implementation.
- **Procedures** — a multi-step task was improvised → a skill, or a step in an existing
  one (`feature-spec`, `integrate`, `verify`, …).
- **No-ops** — instructions in `CLAUDE.md` or rules that didn't change behavior → remove
  them (`CLAUDE.md` is paid every session).
- **Tool economy** — expensive or repeated tool calls → a script, a narrower command,
  or a subagent for broad sweeps.
- **Information access** — something crucial wasn't visible (logs, a service's state) →
  a way to expose it (log file, read-only access, a run command in the README).

## Report

Present the candidates **by severity**, each with the evidence from the session, the
target file and the concrete change. Change nothing until the developer picks.

When the problem comes from an instruction the project inherited from Template-Claude,
also write it as a template feedback block (see `CLAUDE.md`):

> **Template feedback:** `<file>` — what is wrong · evidence · suggested fix
