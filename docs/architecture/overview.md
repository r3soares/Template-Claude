# Architecture: Project Overview

> The project map: what each folder holds and where new code goes. Keep it current —
> update it when a module or top-level folder is added, moved or removed.

---

## Overview

A stack-agnostic, solo-dev project template tuned for Claude Code. Replace this
paragraph with what the system does once the template is in use, and add a section per
module under *Components* as the code grows.

---

## Directory Structure

```text
.
├── .claude/
│   ├── settings.json     # Harness config: permissions (incl. gate-bypass deny rules), hooks
│   ├── agents/           # Orchestrated mode (opt-in): orchestrator, implementer, reviewer (ADR-005)
│   ├── hooks/            # verify-on-stop (self-correction loop), review-diff (reviewer's diff) + README
│   ├── rules/            # Path-scoped instructions, loaded when Claude works on matching files
│   └── skills/           # On-demand procedures (one folder per skill, SKILL.md)
├── .github/
│   ├── PULL_REQUEST_TEMPLATE.md
│   ├── dependabot.yml    # Keeps GitHub Actions (and your ecosystem) current
│   └── workflows/        # ci.yml runs scripts/verify (job `verify`); audit.yml weekly CVE scan;
│                         # tool-versions.yml weekly check of the pinned tools
├── docs/                 # What the system IS now (git holds the history)
│   ├── adr/              # Architecture Decision Records (ADR-001–004, 006: quality gates; 005: orchestrated mode)
│   ├── architecture/     # THIS FILE + component/system docs
│   └── traceability/     # OPTIONAL — formal matrix, compliance projects only
├── specs/features/       # What features SHOULD do — one folder per feature, spec.md
├── scripts/
│   ├── verify            # Single entry point for lint/test/integration/audit (ADR-001)
│   ├── install-tools     # Pinned, checksum-verified install of the template's quality tools
│   ├── check-tool-versions  # Are those pins current? (exit 1 if one is behind)
│   └── tests/            # Self-tests for scripts/verify, the hooks and the agents (template_test)
├── src/                  # Source code (stack-specific structure goes here)
├── templates/            # Blank models: *-template.md, docker/, github/
├── tests/                # Project tests (unit, integration, e2e)
└── CHANGELOG.md          # Lightweight history — a dated entry for every change
```

---

## Components

<!-- One subsection per module as the project grows:

### [Module Name] — `src/<path>/`

- **Responsibility:** What it does
- **Interfaces:** How other modules use it
- **Rules:** `.claude/rules/<module>.md` (if it has module-specific conventions)
-->

---

## Key Distinctions

| Location | Contains | Updated when |
|----------|----------|--------------|
| `specs/` | What a feature *should* do | Before implementation |
| `docs/` | What the system *actually* does | After implementation |
| `docs/adr/` | Why a decision was made | When a significant decision is taken |
| `templates/` | Blank models for new files | When a new document type is needed |
| `.claude/skills/` | How to perform a procedure | When the workflow changes |
| `.claude/rules/` | Conventions for one area of the code | When that area's conventions change |
| `scripts/verify` | The commands that define "passing" | When the stack's checks change |

---

## Key Decisions

| Decision | ADR |
|----------|-----|
| One verification entry point | [ADR-001](../adr/ADR-001-single-verification-entry-point.md) |
| Layered validation + GitHub gate | [ADR-002](../adr/ADR-002-layered-validation-and-github-gate.md) |
| Skip tests for non-essential changes | [ADR-003](../adr/ADR-003-skip-tests-for-non-essential-changes.md) |
| Permission deny rules block gate bypasses | [ADR-004](../adr/ADR-004-permission-deny-rules-replace-git-guard.md) |
| Optional orchestrated mode (native subagents) | [ADR-005](../adr/ADR-005-orchestrated-mode.md) |
| CI skips the redundant post-merge run | [ADR-006](../adr/ADR-006-skip-ci-on-pr-merge-push.md) |
