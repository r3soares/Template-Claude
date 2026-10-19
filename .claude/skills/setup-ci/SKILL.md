---
name: setup-ci
description: Set up or adjust the project's quality gates — the stage commands in scripts/verify, the GitHub Actions workflow that runs them, and GitHub branch protection (ruleset + auto-merge). Use when the user asks to add CI, configure GitHub Actions, run tests/lint on push, protect the main branch, or fill in verification for their stack.
---

# Set up CI and quality gates

One entry point, three layers (ADR-001, ADR-002): the commands live **only** in
`scripts/verify`; the Stop hook, `ship` and CI all call it. Never copy a lint/test
command into `ci.yml` or a skill — that's how local and CI drift apart.

## 1. Configure `scripts/verify`

Fill in the stage commands at the top of the file for the stack:

| Stage | Purpose | Examples |
|-------|---------|----------|
| `LINT_CMD` | Static checks: lint, format check, type check | `npm run lint && npx tsc --noEmit` · `ruff check . && ruff format --check . && mypy .` · `golangci-lint run` |
| `TEST_CMD` | Unit tests — fast, no external services | `npm test` · `pytest -q tests/unit` · `go test ./...` |
| `INTEGRATION_CMD` | Tests against real dependencies via Docker | `with_compose pytest -q tests/integration` |

- Keep `fast` (lint + test) quick — the Stop hook runs it after every turn with changes.
  Slow suites belong in `integration`.
- Keep the template's shellcheck lint (`default_lint`) by chaining:
  `LINT_CMD="${default_lint:+$default_lint && }npm run lint"` (drop it if the project has
  no shell scripts).
- `with_compose` brings up `docker-compose.yml` (or `VERIFY_COMPOSE_FILE`), waits for
  **healthchecks**, runs the command, and tears down volumes. Every service the tests
  depend on needs a `healthcheck` (see `templates/docker/docker-compose.yml`). For a
  test-only stack, use a separate `docker-compose.test.yml` with fixed test credentials.
- Run `./scripts/verify full` locally until it is green.

## 2. Wire the workflow

`.github/workflows/ci.yml` already runs `./scripts/verify full`. Only add the runtime
setup + dependency install for the stack (commented examples are in the file). Keep:
the job name `verify` (it's the required check), `permissions: contents: read`, the
timeout and the concurrency group. Don't add deploy/release jobs unless asked.

If the project has a dependency ecosystem, add it to `.github/dependabot.yml`.

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
