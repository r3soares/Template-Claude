---
name: setup-ci
description: Configure quality gates — scripts/verify stage commands for the stack, the GitHub Actions workflow, branch protection. Use when asked to add CI, run tests on push, or protect master.
---

# Set up CI and quality gates

One entry point, three layers (ADR-001, ADR-002): the commands live **only** in
`scripts/verify`; the Stop hook, `ship` and CI all call it. Never copy a lint/test
command into `ci.yml` or a skill — that's how local and CI drift apart.

## 1. Configure `scripts/verify`

Fill in the stage commands at the top of the file for the stack:

| Stage | Purpose | Examples |
|-------|---------|----------|
| `LINT_CMD` | Static checks: lint, format check, type check | `template_lint && npm run lint && npx tsc --noEmit` · `template_lint && ruff check . && ruff format --check . && mypy .` · `template_lint && golangci-lint run` |
| `TEST_CMD` | Unit tests — fast, no external services | `template_test && npm test` · `template_test && pytest -q tests/unit` · `template_test && go test ./...` |
| `INTEGRATION_CMD` | Tests against real dependencies via Docker | `with_compose pytest -q tests/integration` |

- A stage that doesn't apply (e.g. no integration tests in a library) is set to `"n/a"`,
  not left empty — empty means "not configured yet" and fails under `VERIFY_STRICT=1`.
- Keep `fast` (lint + test) quick — the Stop hook runs it after every turn with changes.
  Slow suites belong in `integration`.
- **Keep `template_test` first in `TEST_CMD`** — the self-tests of `scripts/verify` and the
  Stop hook (`scripts/tests/`, under a second). Under `VERIFY_STRICT=1`, `template_test`
  alone fails as "not configured": chain the project's tests after it.
- **Keep `template_lint` first in `LINT_CMD`** — the stack-agnostic checks, each run only
  when its files exist: `shellcheck` (shell scripts), `actionlint` (workflows),
  `hadolint` (Dockerfiles, outside `templates/`), `gitleaks` (secrets in history and in
  changed/untracked files; gitignored files like `.env` are excluded). Missing tools are
  listed in the summary; under `VERIFY_STRICT=1` they fail.
- **Add the stack's quality tools** to `LINT_CMD`/`TEST_CMD` — formatter in *check*
  mode, linter, type checker, and a coverage floor (e.g. `pytest --cov
  --cov-fail-under=80`, `vitest --coverage`). The type checker and the coverage floor are
  the highest-value additions for catching bugs early.
- Tune instead of disabling: `.hadolint.yaml` for Dockerfile rules, `.gitleaksignore`
  (fingerprints) or a `gitleaks:allow` comment for a reviewed false positive.
- `with_compose` brings up `docker-compose.yml` (or `VERIFY_COMPOSE_FILE`), waits for
  **healthchecks**, runs the command, and tears down volumes. Every service the tests
  depend on needs a `healthcheck` (see `templates/docker/docker-compose.yml`). For a
  test-only stack, use a separate `docker-compose.test.yml` with fixed test credentials.
- Run `./scripts/verify full` locally until it is green.

### Non-essential files (docs, markdown) — don't test them

Tests should never spend time on files no test reads (ADR-003):

- `NON_ESSENTIAL` in `scripts/verify` lists them (`**/*.md`, `docs/`, `specs/`,
  `templates/`, `LICENSE*`, …). A change touching only those skips `test` and
  `integration` (reported `N/A`); lint still runs so gitleaks scans docs. Extend the
  list for the stack (e.g. design assets no test reads) — never with source, config,
  lockfiles or anything a build or test consumes.
- **Never add `paths-ignore`/`paths` to `ci.yml`**: `verify` is a required check, and a
  check that doesn't run blocks docs-only PRs forever. The skip lives in the script.
- **Scope every tool to code**, so a full run doesn't walk docs either: test discovery
  limited to `tests/` (`pytest tests/`, `testpaths`, vitest `include`), coverage limited
  to source dirs (`--cov=src`, `coverage.include`), linters/formatters on code paths
  (`ruff check src tests`, eslint ignores `docs/`). Don't add markdown/prose linters to
  the gate unless the developer asks.
- Keep docs out of Docker build contexts (`.dockerignore` already excludes `**/*.md`,
  `docs`, `specs`, `templates`), so a doc edit doesn't invalidate image layers in
  `with_compose`.

## 2. Wire the workflows

`.github/workflows/ci.yml` already installs the template tools (`scripts/install-tools`)
and runs `./scripts/verify full`. Only add the runtime setup + dependency install for the
stack (commented examples are in the file). Keep: the job name `verify` (it's the
required check), `fetch-depth: 0` (gitleaks scans the PR's commits),
`persist-credentials: false`, `permissions: contents: read`, the timeout and the
concurrency group. Pin every action you add by full commit SHA with the version as a
comment (`uses: owner/action@<sha> # vX.Y.Z`; get it with
`gh api repos/<owner>/<action>/commits/<tag> --jq .sha`) — Dependabot keeps it current. Don't add
deploy/release jobs unless asked.

`.github/workflows/audit.yml` runs `./scripts/verify audit` (osv-scanner over the
project's lockfiles) weekly and on demand — deliberately **not** a PR gate, so a newly
published CVE doesn't block unrelated work. It needs committed lockfiles to be useful.

If the project has a dependency ecosystem, add it to `.github/dependabot.yml`. Tool
versions in `scripts/install-tools` are pinned and Dependabot can't see them:
`.github/workflows/tool-versions.yml` runs `scripts/check-tool-versions` weekly and opens
an issue when one is behind — bump it on a branch. A tool added to `install-tools` with
the same release-URL pattern is checked automatically.

## 3. Turn on strict mode

Once every stage the project needs is configured, set the repo variable so an empty
stage fails CI instead of passing silently (confirm first — it changes repo settings):

```bash
gh variable set VERIFY_STRICT --body 1
```

## 4. Protect the default branch (GitHub remote only)

Outward-facing and changes how the repo accepts work — **confirm with the developer
before each command.**

```bash
gh repo edit --enable-auto-merge --delete-branch-on-merge
gh api repos/{owner}/{repo}/rulesets --method POST --input templates/github/branch-ruleset.json
```

The ruleset requires a PR, requires the `verify` check (from GitHub Actions) on an
up-to-date branch, and blocks force-push and deletion of the default branch. Zero
approvals are required — a solo dev can't approve their own PR; CI is the gate.

**Limitation:** rulesets on **private** repos require GitHub Pro/Team/Enterprise. On
GitHub Free, private repos keep CI as a signal but not a hard gate — say so to the
developer. Re-applying the ruleset creates a duplicate; update an existing one with
`gh api repos/{owner}/{repo}/rulesets/<id> --method PUT --input …`.

## 5. Validate

- Push a branch and open a PR (the `ship` skill, GitHub mode); `gh pr checks --watch`
  must show `verify` passing.
- Add a dated `CHANGELOG.md` entry. A new gate or required check is significant —
  record it with the `adr` skill if it departs from ADR-002.
