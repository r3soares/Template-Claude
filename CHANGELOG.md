# Changelog

All notable changes to this project are documented here. This is the **lightweight
history**: every change — feature or small fix — adds a dated entry under
`[Unreleased]`. It is the one document that is always current.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).  
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**Keep it lean:** always append at the top (under `[Unreleased]`), and read only
`[Unreleased]` + the latest released version day-to-day. When the file gets long, move
older released sections to `docs/CHANGELOG-ARCHIVE.md` so the working file stays small.

---

## [Unreleased]

### Added
- **2026-10-24** Self-tests for `scripts/verify` (stage selection, docs-only skip, strict mode, failure handling) and the `verify-on-stop` hook (bounded retries, opt-out) in `scripts/tests/`, plain bash, under a second. Run as `template_test`, the new default `TEST_CMD`; under `VERIFY_STRICT=1`, `template_test` alone fails as not configured, so projects still chain their own tests.
- **2026-10-19** `scripts/install-tools` — pinned, checksum-verified install of gitleaks, actionlint, hadolint and osv-scanner (Linux/macOS); weekly `audit.yml` workflow for dependency vulnerabilities.
- **2026-10-19** Quality gates (ADR-001, ADR-002): `scripts/verify` as the single entry point for lint/test/integration (`fast`/`full`, `VERIFY_STRICT`, Docker `with_compose`); `verify-on-stop` Stop hook for a bounded agent self-correction loop; `verify` skill; branch ruleset template (`templates/github/branch-ruleset.json`); Dependabot for GitHub Actions; first ADRs in `docs/adr/`.
### Changed
- **2026-10-24** Skill descriptions shortened (~38% fewer characters, same triggers) — they are in Claude's context every turn. `ship` gains a security-review step (Claude Code's built-in `security-review`) for features and security-sensitive small changes.
- **2026-10-24** `verify-on-stop` skips `verify fast` when the tree is identical to the last green run (fingerprint: HEAD + diff + untracked files), so turns that change nothing — e.g. answering a question with a dirty tree — no longer re-run the checks. Failures are never cached; `ship` and CI don't use the cache.
- **2026-10-24** CI and audit workflows pin actions by commit SHA (version in a comment; Dependabot bumps both) and check out with `persist-credentials: false`, so a moved tag can't swap the code that runs and build scripts can't read the token. `setup-ci` tells Claude to pin any action it adds.
- **2026-10-24** Reference docs consolidated. `.claude/conventions.md` → path-scoped `.claude/rules/docs.md` (loads when Claude edits `docs/`, `specs/`, `templates/`) plus branch/commit conventions in the `ship` skill; `.claude/project.md` → `docs/architecture/overview.md`, the project map `CLAUDE.md` points to; `.claude/workflow.md` → `CLAUDE.md`, skills and the README (verification-layers table). `CLAUDE.md` drops the skill and reference-doc tables (skill descriptions are already in context every turn). README gains *When the project grows* (rules per area, keep the map current, Explore subagent) and suggests running skills as `/name`; `feature-spec` reminds to update the map when a module is added.
- **2026-10-24** `.claude/settings.json` drops allow rules for commands Claude Code already runs without a prompt (`ls`, `cat`, `head`, `tail`, `grep`, `find`, `wc`, read-only `git`); remaining rules use the current `Bash(cmd *)` form.
- **2026-10-24** Gate bypasses (`--no-verify`/`commit -n`, `gh pr merge --admin`, any force-push) are blocked by `permissions.deny` rules instead of the `git-guard.sh` hook (ADR-004). Deny rules match per subcommand; Claude can no longer force-push any branch, and the on-master warning is gone (`ship` branches first).
- **2026-10-19** `scripts/verify` skips `test` and `integration` (reported `N/A`) when a change touches only non-essential files — `NON_ESSENTIAL` list (`*.md`, `docs/`, `specs/`, `templates/`, …), compared against `VERIFY_BASE` or the merge-base with the default branch; lint/gitleaks still run; `VERIFY_ALL=1` forces every stage (ADR-003). CI passes the PR base and deliberately avoids `paths-ignore` (required check). `setup-ci`, `test-plan` and `verify` skills tell Claude to keep test discovery, coverage, linters and Docker contexts scoped to code.
- **2026-10-19** Lint stage starts with `template_lint`: stack-agnostic checks run when their files exist — shellcheck, actionlint, hadolint, gitleaks (history + changed/untracked files, gitignored excluded). Missing tools are listed in the summary (and fail under `VERIFY_STRICT=1`); a lint with no tool available shows as SKIPPED. A stage set to `n/a` is reported as not applicable and passes strict mode. New `verify audit` mode (osv-scanner). CI installs the tools and fetches full history. Template Dockerfile uses a numeric UID (hadolint DL3066).
- **2026-10-19** CI runs `./scripts/verify full` as job `verify` (least-privilege permissions, timeout, concurrency, strict mode via repo variable). `ship` verifies before review and integrates locally (`--no-ff`) or, on GitHub, through a PR with auto-merge gated by CI. `git-guard` now blocks `--no-verify`, `--admin` PR merges and force-push to master/main (matched per command segment). `test-plan` covers design for testability, test layers, determinism and regression tests; `setup-ci` configures verify stages and branch protection; compose template gains healthchecks; `CLAUDE.md`, workflow, project, README and SETUP docs updated.
- **2026-06-10** Workflow updated: replaced GitHub PR step with branch → review → tests → merge to master flow. Push to origin is now optional and requires explicit confirmation. Added commit hygiene rules (one concern per commit, descriptive messages). Master branch only receives commits after tests pass.
### Fixed
- **2026-10-24** `NON_ESSENTIAL` used `*.md`, which under git glob pathspecs matches only top-level files — a change to nested markdown (`.claude/skills/*/SKILL.md`, `src/**/README.md`) ran the test stages. Now `**/*.md`, and the same fix in `templates/docker/.dockerignore` (nested docs no longer enter the build context). Found by the new self-tests.
- **2026-10-24** Format-on-edit example in `.claude/hooks/README.md` used a nonexistent `$CLAUDE_FILE_PATHS` variable; it now reads `tool_input.file_path` from the hook payload on stdin.
- **2026-10-19** `with_compose` rebuilds images (`--build`) — without it, integration tests ran against a stale cached image and missed bugs. `verify-on-stop` resets the attempt counter when the tree is clean (a fix that was committed no longer leaves a stale count). Both found by the test projects.
- **2026-10-19** Stale references: `git-guard` pointed to the removed `open-pr` skill; `feature-spec` referred to the removed History section.
### Removed
- **2026-10-19** `templates/pr-template.md` — duplicate of `.github/PULL_REQUEST_TEMPLATE.md`.

---

<!-- 
## [1.0.0] - YYYY-MM-DD

### Added
- Initial release

-->
