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

## Working with Claude

This template is built for [Claude Code](https://claude.com/claude-code). It works best
when you understand what Claude does on its own versus what you decide.

### What Claude does automatically

- **Loads `CLAUDE.md` every session** — it already knows the core principles, the
  size-based process, and which skill to use when.
- **Reads reference docs on demand** (`.claude/workflow.md`, `conventions.md`,
  `project.md`) — only when a task needs them.
- **Triggers the right skill** from your request, and **reads the rest on demand** —
  no need to paste docs into the prompt.
- **`git-guard` hook** warns before committing/pushing on `master`/`main`.
- **Confirms outward actions** — it asks before `git push` or opening a PR.
- Keeps scope inside the spec and adds a dated `CHANGELOG.md` entry for every change.

> Skill triggering is the model's judgment, not guaranteed. For determinism, name the
> skill in your prompt (e.g. "use the `adr` skill").

### What you decide / approve

- **The tier**: Claude infers small-fix vs feature; override by saying which it is.
- **Accept the spec** (`[ACCEPTED]`) before implementation, and the ADR before a
  hard-to-reverse decision.
- **Push / PR**, and the **Docker / CI** setup decisions.

### Per-task prompts

| You want… | Say something like… | What happens |
|-----------|---------------------|--------------|
| A feature | "New feature: … — write the spec first" | `feature-spec` → you approve → implement → tests → PR |
| A decision | "Record an ADR for choosing X over Y" | `adr` (use for libraries, data models, hard-to-reverse choices) |
| A small fix | "Fix … — this is a small fix" | code → conventional commit → CHANGELOG → PR |
| Tests | "Cover feature X with tests" | real tests in `tests/` derived from the spec |
| Commit + PR | "Open the PR" | `open-pr`: branch → commit → CHANGELOG → PR (confirms before push) |
| Docker / CI | "Containerize this" / "Set up CI" | `dockerize` (decision guide first) / `setup-ci` |

### Prompt tips

1. **Signal size/intent** ("small fix" vs "new feature") so Claude picks the right tier.
2. **For features, ask for the spec first and review it** — cheapest place to correct course.
3. **Be explicit about scope** — vague prompt, vague spec; out-of-spec scope is rejected.
4. **Name the skill** when you want a guaranteed path.
5. **Say when to commit/push** — nothing is published without your go-ahead.
6. **Don't dump huge context** — point at files/skills; let progressive disclosure work.
7. **Keep `CLAUDE.md` lean** — if a rule isn't always relevant, it belongs in a skill or doc.

### Maintenance

Audit dependencies periodically (a notable bump is a CHANGELOG entry; swapping a core
library is an ADR). Keep docs describing the *present* — "what changed" is answered by
git, not by history tables. Archive old `CHANGELOG.md` sections to
`docs/CHANGELOG-ARCHIVE.md` when the file grows.

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
