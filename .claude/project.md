# Project Overview

Structural context of the project. Read on demand (not auto-loaded).

## Purpose

A **stack-agnostic, solo-dev project template** tuned for working with Claude Code. It
favors simplicity and progressive disclosure: small always-on rules in `CLAUDE.md`,
specialized procedures in **skills** that load only when triggered, and a process that
scales with the size of the change. Copy it, fill in the placeholders, and start.

## Directory Structure

```
.
├── .claude/
│   ├── project.md        # THIS FILE — structure and purpose of each folder
│   ├── workflow.md       # The development lifecycle (tiered by change size)
│   ├── conventions.md    # Naming, commits, status tags, language rules
│   ├── settings.json     # Harness config: hooks, permissions
│   ├── hooks/            # Deterministic guardrails (e.g. git-guard) + README
│   └── skills/           # On-demand procedures (one folder per skill, SKILL.md)
├── .github/
│   ├── PULL_REQUEST_TEMPLATE.md  # PR description template for GitHub
│   └── workflows/        # CI/CD — ci.yml (stack-agnostic, fill per stack)
├── docs/                 # Documentation of what IS (current truth)
│   ├── adr/              # Architecture Decision Records — one file per decision
│   ├── architecture/     # System/component diagrams and architecture docs
│   └── traceability/     # Traceability matrix linking requirements to impl
├── specs/                # Specifications of what SHOULD BE
│   └── features/         # One folder per feature, containing spec.md
├── src/                  # Source code (stack-specific structure goes here)
├── templates/            # Reusable file templates
│   ├── *-template.md     # Spec, ADR, test, PR, architecture, traceability
│   └── docker/           # Dockerfile, docker-compose.yml, .dockerignore
├── tests/                # Tests (unit, integration, e2e)
├── CHANGELOG.md          # Lightweight history — a dated entry for every change
└── README.md             # Project entry point — setup, purpose, links
```

## Skills

Procedures load only when a task triggers them (progressive disclosure). See each
`SKILL.md` for details: `feature-spec`, `adr`, `test-plan`, `traceability`, `open-pr`,
`dockerize`, `setup-ci`. `CLAUDE.md` has the "which skill, when" table.

## Key Distinctions

| Folder | Contains | Updated when |
|--------|----------|--------------|
| `specs/` | What a feature *should* do | Before implementation |
| `docs/` | What the system *actually* does | After implementation |
| `docs/adr/` | Why a decision was made | When a significant decision is taken |
| `templates/` | Blank models for new files | When a new document type is needed |
| `.claude/skills/` | How to perform a procedure | When the workflow changes |

## When Starting a New Project from This Template

Follow `SETUP.md`. In short: copy the folder, fill in `README.md` and the project
identity in `CLAUDE.md`, reset `CHANGELOG.md`, decide on Docker/CI, and begin with a
feature spec (the `feature-spec` skill) before writing code.
