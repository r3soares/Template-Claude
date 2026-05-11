# Project Overview

This file gives Claude the structural context of the project. Read this first before any task.

## Purpose

This is a **generic project template**. It is stack-agnostic and language-agnostic. When starting a real project, this template is copied and the placeholders are filled in.

## Directory Structure

```
.
├── .claude/              # Claude instructions — read these before working
│   ├── project.md        # THIS FILE — structure and purpose of each folder
│   ├── workflow.md       # How to work: the development lifecycle
│   └── conventions.md    # Naming, commits, file organization rules
├── .github/
│   └── PULL_REQUEST_TEMPLATE.md  # PR description template for GitHub
├── docs/                 # Documentation of what IS (current truth)
│   ├── adr/              # Architecture Decision Records — one file per decision
│   ├── architecture/     # System/component diagrams and architecture docs
│   └── traceability/     # Traceability matrix linking requirements to impl
├── specs/                # Specifications of what SHOULD BE
│   └── features/         # One folder per feature, containing spec.md
├── src/                  # Source code (stack-specific structure goes here)
├── templates/            # Reusable file templates for this project type
│   ├── adr-template.md
│   ├── feature-template.md
│   ├── pr-template.md
│   ├── test-template.md
│   └── traceability-template.md
├── tests/                # Tests (unit, integration, e2e)
├── CHANGELOG.md          # History of notable changes per version
└── README.md             # Project entry point — setup, purpose, links
```

## Key Distinctions

| Folder | Contains | Updated when |
|--------|----------|--------------|
| `specs/` | What the feature *should* do | Before implementation |
| `docs/` | What the system *actually* does | After implementation |
| `docs/adr/` | Why a decision was made | When a significant decision is taken |
| `templates/` | Blank models for new files | When a new document type is needed |

## When Starting a New Project from This Template

1. Copy this entire folder to the new project location
2. Fill in `README.md` with project-specific information
3. Update `.claude/project.md` with the actual project name and stack details
4. Remove placeholder content from `CHANGELOG.md`
5. Begin with a feature spec in `specs/features/` before writing any code
