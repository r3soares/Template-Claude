# ADR-001: Single Verification Entry Point (`scripts/verify`) [ACCEPTED]

> Every quality check — by Claude, hooks, the `ship` skill and CI — runs through one
> script, `scripts/verify`, whose stage commands are the only place lint/test commands live.

---

## Status

`[ACCEPTED]`

Supersedes: —  
Superseded by: —

---

## Context

The template must work for any stack, but "run the tests" was described in four places
(the `ship` skill, `ci.yml` placeholders, README, `setup-ci`) without a concrete command.
That invites drift: CI and local runs diverge ("green local, red CI"), Claude guesses
the command per session, and a hook cannot run anything deterministic.

Forces: stack-agnostic, zero extra dependencies, simple for a solo dev, callable from a
hook and from GitHub Actions, and able to express "fast" (every turn) vs "full" (before
merge, including Docker-based integration tests).

---

## Decision

Add `scripts/verify` (bash, no dependencies) with three stages — `lint`, `test`,
`integration` — and two modes: `fast` (lint + test) and `full` (all stages). Stage
commands are variables at the top of the script, overridable via `VERIFY_*_CMD` env
vars. An empty stage is reported as `SKIPPED`; `VERIFY_STRICT=1` makes it fail, to stop
an unconfigured project from looking green. A `with_compose` helper runs integration
tests against `docker compose up --wait` and always tears down.

All consumers call the script and never repeat its commands: the `verify-on-stop` hook
(`fast`), the `ship` skill (`full`), and CI (`full`).

---

## Options Considered

### Option A: `scripts/verify` bash script (chosen)

**Pros:**
- No dependency; runs anywhere bash runs (Linux, macOS, CI, Git Bash/WSL).
- Already allowed by the template's `Bash(./**)` permission.
- Easy to read and extend; stages and modes are explicit.

**Cons:**
- Not native on Windows without Git Bash/WSL.
- Projects with an existing task runner may already have equivalent targets.

### Option B: Makefile (`make check`)

**Pros:**
- Conventional and discoverable.

**Cons:**
- Tab sensitivity, `make` missing on Windows, awkward for env-driven overrides.

### Option C: Stack-native runner (npm scripts, tox, just, Taskfile)

**Pros:**
- Idiomatic for that stack.

**Cons:**
- Not stack-agnostic; the template would need one variant per stack. A project can
  still call its native runner *from* `scripts/verify`.

---

## Consequences

### Positive

- Local and CI run identical commands; one place to change them.
- Hooks and skills can be deterministic without knowing the stack.

### Negative / Trade-offs

- Each project must fill in the stage commands (the `setup-ci` skill guides it).

### Risks

- A project forgets to configure a stage and gets a false green — mitigated by the
  visible `SKIPPED` summary and `VERIFY_STRICT=1` in CI.

---

## Related

- ADR: [ADR-002](ADR-002-layered-validation-and-github-gate.md) — how the layers use it
