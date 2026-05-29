# [Project Name]

> One-line description of the project.

---

## Overview

<!-- Describe what this project does, who it is for, and why it exists. -->

---

## Getting Started

### Prerequisites

<!-- List required tools, runtimes, or environment setup. -->

### Installation

```bash
# Clone the repository
git clone <repo-url>
cd <project-folder>

# Install dependencies
# (add stack-specific command here)
```

### Running Locally

```bash
# (add stack-specific command here)
```

### Running Tests

```bash
# (add stack-specific command here)
```

---

## Project Structure

```
.
├── .claude/        # Claude config: skills (on-demand procedures), hooks, settings, reference docs
├── .github/        # GitHub PR template and CI workflows
├── docs/           # Documentation (ADRs, architecture)
├── specs/          # Feature specifications
├── src/            # Source code
├── templates/      # File + Docker templates
└── tests/          # Tests
```

See `.claude/project.md` for a detailed breakdown.

---

## Development Workflow

See `.claude/workflow.md` for the full lifecycle. The process scales with change size:

- **Small fix** → code → conventional commit → dated `CHANGELOG.md` entry → PR.
- **Feature** → spec → ADR (if needed) → implement → tests → PR.

Specialized steps are handled by Claude **skills** (`.claude/skills/`) that load only
when relevant — `feature-spec`, `adr`, `test-plan`, `open-pr`, `dockerize`, `setup-ci`
(plus an optional `traceability` skill for compliance projects).

---

## Links

| Resource | Location |
|----------|----------|
| Architecture | `docs/architecture/` |
| Decisions (ADR) | `docs/adr/` |
| Feature specs | `specs/features/` |
| Changelog | `CHANGELOG.md` |

---

## License

<!-- Specify the license. -->
