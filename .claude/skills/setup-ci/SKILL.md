---
name: setup-ci
description: Set up or adjust continuous integration (GitHub Actions). Use when the user asks to add CI, configure GitHub Actions, run tests/lint on push, or fill in the CI workflow for their stack.
---

# Set up CI

Wire up a minimal, stack-agnostic CI pipeline that lints and tests on every push/PR.
Keep it simple — a solo dev wants fast, useful signal, not a release pipeline.

## Steps

1. **Start from** `.github/workflows/ci.yml` (already in the template, commented with
   placeholders). If it doesn't exist, create it from that shape.
2. **Fill in the stack specifics** in the placeholder steps:
   - Runtime setup (e.g. `actions/setup-node`, `setup-python`, `setup-go`, …).
   - Dependency install command.
   - Lint command.
   - Test command.
3. **Keep the triggers** to `push` and `pull_request` on the default branch. Don't add
   deploy/release jobs unless the user asks.
4. **Match the local commands** — CI should run the same lint/test commands the
   developer runs locally, so green local == green CI.
5. Add a dated `CHANGELOG.md` entry.

## Optional

- If the project is containerized (`dockerize` skill), CI can build the image as a job.
- Cache dependencies (`actions/cache` or the setup action's built-in cache) for speed.

## Rule

CI must stay green. If a workflow change is significant (new gating, required checks),
note the reasoning — an ADR only if it's hard to reverse.
