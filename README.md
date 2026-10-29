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

### Running Checks

All lint, test and integration checks run through one entry point — the same one CI
uses:

```bash
./scripts/verify fast   # lint + unit tests
./scripts/verify        # full: + integration tests (Docker)
./scripts/verify audit  # dependency vulnerability scan (also weekly in CI)
```

Lint includes stack-agnostic checks — secrets (gitleaks), workflows (actionlint),
Dockerfiles (hadolint), shell scripts (shellcheck) — that run when the tool is installed.
CI always installs them; to run them locally too:

```bash
./scripts/install-tools                 # gitleaks, actionlint, hadolint → ~/.local/bin
./scripts/install-tools osv-scanner     # for `verify audit`
./scripts/check-tool-versions           # are the pinned tool versions current? (weekly in CI)
sudo apt install shellcheck             # or: brew install shellcheck
```

---

## Project Structure

```
.
├── .claude/        # Claude config: skills (on-demand procedures), rules (path-scoped), agents, hooks, settings
├── .github/        # GitHub PR template and CI workflows
├── docs/           # Documentation (ADRs, architecture)
├── scripts/        # verify — the single entry point for all checks
├── specs/          # Feature specifications
├── src/            # Source code
├── templates/      # File + Docker templates
└── tests/          # Tests
```

See `docs/architecture/overview.md` — the project map Claude reads — for a detailed breakdown.

---

## Development Workflow

The process scales with change size (`CLAUDE.md` holds the rule Claude follows):

- **Small fix** → code (+ regression test for a bug) → verify → conventional commit → dated `CHANGELOG.md` entry → merge.
- **Feature** → spec → ADR (if needed) → implement → tests → verify → merge.

Specialized steps are handled by Claude **skills** (`.claude/skills/`) that load only
when relevant — `feature-spec`, `adr`, `test-plan`, `verify`, `ship`, `dockerize`,
`setup-ci` (plus an optional `traceability` skill for compliance projects).

### Quality gates

Three layers, one command set (`scripts/verify`) — see ADR-001 and ADR-002 in `docs/adr/`:

| Layer | Runs | When | Purpose |
|-------|------|------|---------|
| 1. Claude | `verify fast` (lint + test) | `verify-on-stop` hook, end of every turn with changes | Claude fixes its own failures (≤3 attempts, then reports) |
| 2. Ship | `verify full` (+ integration via Docker) | Before review and merge | Local gate |
| 3. GitHub | `verify full` in CI job `verify` | Every PR and push to master | Independent gate; required check via the branch ruleset, `ship` auto-merges |
| — Audit | `verify audit` (osv-scanner) | Weekly + on demand (`audit.yml`) | Known-vulnerable dependencies; not a PR gate |
| — Tool versions | `scripts/check-tool-versions` | Weekly + on demand (`tool-versions.yml`) | Opens an issue when a tool pinned in `install-tools` is behind |

Lint always starts with `template_lint` (gitleaks, actionlint, hadolint, shellcheck),
then the stack's own tools. Stage commands live **only** in `scripts/verify` — CI,
hooks and skills never repeat them (configure them with the `setup-ci` skill).

Changes that touch only non-essential files (docs, `*.md`, `specs/`, `templates/` —
`NON_ESSENTIAL` in `scripts/verify`) run lint only; test and integration are skipped
(ADR-003).

---

## Working with Claude

This template is built for [Claude Code](https://claude.com/claude-code). It works best
when you understand what Claude does on its own versus what you decide.

### What Claude does automatically

- **Loads `CLAUDE.md` every session** — it already knows the core principles, the
  size-based process, and which skill to use when.
- **Loads path-scoped rules** (`.claude/rules/`) only when it works on matching files —
  e.g. the documentation conventions load when it edits `docs/` or `specs/`.
- **Triggers the right skill** from your request, and **reads the rest on demand** —
  no need to paste docs into the prompt.
- **Verifies its own work** — runs `./scripts/verify`, and the `verify-on-stop` hook
  makes it fix failures (root cause, no skipped/weakened tests) before handing back.
  After 3 failed attempts it stops and gives you an escalation report.
- **Permission deny rules** (`.claude/settings.json`) block gate bypasses:
  `--no-verify`, `--admin` merges, force-push.
- **Confirms outward actions** — it asks before `git push`, opening a PR, or changing
  repo settings (branch protection).
- Keeps scope inside the spec and adds a dated `CHANGELOG.md` entry for every change.

> Skill triggering is the model's judgment, not guaranteed. For determinism, run the
> skill directly as a command (e.g. `/adr`, `/ship`).

### What you decide / approve

- **The tier**: Claude infers small-fix vs feature; override by saying which it is.
- **Accept the spec** (`[ACCEPTED]`) before implementation, and the ADR before a
  hard-to-reverse decision.
- **Push / PR**, and the **Docker / CI / branch protection** setup decisions.
- **Escalations** — when Claude reports a failure it couldn't fix in 3 attempts.

### Per-task prompts

| You want… | Say something like… | What happens |
|-----------|---------------------|--------------|
| A feature | "New feature: … — write the spec first" | `feature-spec` → you approve → implement → tests → verify → merge |
| A decision | "Record an ADR for choosing X over Y" | `adr` (use for libraries, data models, hard-to-reverse choices) |
| A small fix | "Fix … — this is a small fix" | regression test → fix → verify → commit → CHANGELOG → merge |
| Tests | "Cover feature X with tests" | real tests in `tests/` derived from the spec |
| Check a change | "Verify this" / "CI failed, fix it" | `verify`: run, diagnose, fix, re-run (bounded) |
| Commit + merge | "Ship this" | `ship`: branch → commit → CHANGELOG → verify → review → merge locally or via CI-gated PR |
| Docker / CI | "Containerize this" / "Set up CI" | `dockerize` (decision guide first) / `setup-ci` (verify stages, workflow, protection) |

### Prompt tips

1. **Signal size/intent** ("small fix" vs "new feature") so Claude picks the right tier.
2. **For features, ask for the spec first and review it** — cheapest place to correct course.
3. **Be explicit about scope** — vague prompt, vague spec; out-of-spec scope is rejected.
4. **Run the skill as `/name`** when you want a guaranteed path.
5. **Say when to commit/push** — nothing is published without your go-ahead.
6. **Don't dump huge context** — point at files/skills; let progressive disclosure work.
7. **Keep `CLAUDE.md` lean** — if a rule isn't always relevant, it belongs in a skill or doc.

### When the project grows

The template keeps Claude's context proportional to the task, not to the size of the
project. As modules multiply:

- **One rule per area.** Put conventions that apply to one part of the code in
  `.claude/rules/<area>.md` with `paths:` frontmatter (e.g. `paths: ["src/api/**"]`).
  They load only when Claude works there. Don't put a README inside `.claude/rules/` —
  every `.md` there is loaded as a rule.
- **Keep the map current.** `docs/architecture/overview.md` is how Claude finds its way
  around; update it whenever a module or top-level folder is added (`feature-spec`
  reminds you).
- **Keep `CLAUDE.md` under ~200 lines.** Anything not relevant to every session moves to
  a rule or a skill.
- **Specs are the feature index.** Each spec's *Related* section points at its source
  and tests — ask Claude to start from the spec instead of searching the codebase.
- **Broad searches go to a subagent.** Ask Claude to "use the Explore agent" for sweeps
  across many files, so the search results don't fill the main conversation.

### Orchestrated mode (optional)

For larger tasks, `claude --agent orchestrator` starts a session whose main agent can't
write: it plans, delegates to an `implementer` (one task at a time) and a read-only
`reviewer`, and reports. The reviewer gets the real diff from a hook, and the same
verify gates block the implementer. You ship from a classic session (`claude`). Classic
mode stays the default. See `docs/architecture/orchestrated-mode.md` and ADR-005.

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
