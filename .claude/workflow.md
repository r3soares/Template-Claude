# Development Workflow

The development lifecycle. Read on demand — `CLAUDE.md` holds the short version; this
file is the detail. Each step maps to a **skill** that carries its own procedure.

## Process scales by size

This is a solo-dev template: don't impose feature ceremony on a small change.

| Tier | What it is | Flow |
|------|-----------|------|
| **Small change** | Bug fix, copy tweak, config, refactor with no behavior change | Code (+ regression test for a bug) → verify → commit → dated `CHANGELOG.md` entry → merge. No spec, no ADR. |
| **Feature / significant change** | New behavior or user-facing surface | Spec → ADR (if needed) → impl → tests → verify → merge. |

When unsure which tier applies, ask before assuming.

---

## The full flow (feature tier)

```
Spec → ADR (if needed) → Implementation → Tests → Verify → Merge
```

Each step is driven by a skill.

| Step | Skill | Output | Location |
|------|-------|--------|----------|
| 1. Spec | `feature-spec` | `spec.md` | `specs/features/{name}/` |
| 2. ADR (if a real decision) | `adr` | `ADR-NNN-title.md` | `docs/adr/` |
| 3. Implement | — | source files | `src/` |
| 4. Tests | `test-plan` | test files | `tests/` |
| 5. Verify | `verify` | green `./scripts/verify full` | — |
| 6. Merge | `ship` | branch + commit + review + integrate | Git (local or PR) |

### Step notes

1. **Spec first.** No code for a feature before its spec is `[ACCEPTED]`. If the
   implementation must diverge, update the spec first and note why.
2. **ADR only for real decisions** — adopting/replacing a library, a non-obvious pattern
   or data model, anything hard to reverse. Otherwise skip it.
3. **Implement** in `src/`, following `conventions.md` and designing for testability
   (see `test-plan`). No scope beyond the spec.
4. **Tests** cover happy path, the spec's edge cases, and failure scenarios — real tests
   in `tests/`, not a document.
5. **Verify** with `./scripts/verify full`. Failures are diagnosed and fixed by Claude
   (bounded attempts, then an escalation report) — see the `verify` skill.
6. **Merge** via `ship`: Conventional Commits, spec/ADR linked in the body when relevant,
   integrated locally or through a CI-gated PR (see *Git*).

The spec's *Related* section is the feature index — point it at the source and test
files as you go. A formal traceability matrix (the `traceability` skill) is **optional**,
for audited/compliance projects only; a typical solo-dev project doesn't need it.

---

## Verification layers

One entry point, `scripts/verify` (ADR-001), used by three layers (ADR-002):

| Layer | Runs | When | Purpose |
|-------|------|------|---------|
| 1. Agent | `verify fast` (lint + test) | Stop hook, end of every turn with changes | Claude finds and fixes its own failures (≤3 attempts, then reports) |
| 2. Ship | `verify full` (+ integration via Docker) | Before review and merge | Local gate |
| 3. GitHub | `verify full` in CI job `verify` | Every PR and push to master | Independent gate; required check via ruleset |

Stage commands live **only** in `scripts/verify` — CI, hooks and skills never repeat
them. Configure them with the `setup-ci` skill. `git-guard` blocks bypasses
(`--no-verify`, `--admin` merges, force-push to master).

## Git

- Work on branches (`feat/…`, `fix/…`, `docs/…`), not directly on `master`/`main`.
  The `git-guard` hook warns if you forget.
- Conventional Commits — see `conventions.md`.
- The `ship` skill handles branch → commit → verify → review → integrate, in two modes:
  - **Local** (no GitHub remote): `merge --no-ff` into master.
  - **GitHub**: push the branch, open a PR, auto-merge once CI `verify` passes.
  Pushing always requires explicit confirmation.

## CI/CD

- `.github/workflows/ci.yml` runs `./scripts/verify full` on PRs and pushes to master
  (least-privilege permissions, timeout, concurrency). Add only the runtime setup for
  the stack — the `setup-ci` skill.
- Branch protection: `templates/github/branch-ruleset.json` (PR + required `verify`
  check), applied with `gh api` after confirmation. Dependabot keeps Actions current.

## Docker (conditional)

- Containerize only when the project type fits (SaaS/API/web/worker → yes;
  CLI/desktop/library → no). The `dockerize` skill has the full decision guide and
  applies the templates in `templates/docker/`.

---

## Maintenance

- **Dependencies**: update and audit periodically (not just when something breaks). A
  notable bump is a `CHANGELOG.md` entry; record an ADR only if it's a hard-to-reverse
  decision (e.g. swapping a core library).
- **Docs describe the present.** When behavior changes, update the spec/architecture doc
  that describes it — don't leave a doc asserting something the code no longer does.

---

## Rules

- Match process to change size — don't over-document a one-liner, don't under-document a
  feature.
- Never merge a feature without tests; never fix a bug without a regression test
  (unless impractical — say why).
- **Master only receives verified commits**: `./scripts/verify full` must pass before
  any merge (and CI too, in GitHub mode).
- Never skip, delete or weaken a test, or bypass a gate, to get green.
- **Keep commits focused**: one concern per commit — do not mix feature, refactor, and
  bug fix in the same commit. If the diff spans independent activities, split it.
- ADRs are never deleted — supersede them (see the `adr` skill).
- `CHANGELOG.md` gets a dated entry for **every** change.
- No hand-maintained history tables inside docs — git records the past.
