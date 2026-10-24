---
name: ship
description: Branch, commit with Conventional Commits, verify, await dev review, and integrate into master — locally (no GitHub remote) or through a pull request gated by CI (GitHub remote). Use when the user asks to commit, ship, or merge a change.
---

# Ship a Change

Branch → commit → CHANGELOG → verify → review → integrate. Works for both tiers — only
the linked artifacts differ. Integration has two modes (ADR-002):

| Mode | When | Gate before master |
|------|------|--------------------|
| **Local** | No GitHub remote, or the developer asks for local | `./scripts/verify full` |
| **GitHub** | `origin` is on GitHub and `gh auth status` succeeds | Same, **plus** CI `verify` as a required check on a PR |

## 1. Branch

Never commit work directly to `master`/`main`. Name the branch for the change:
`feat/short-name`, `fix/short-name`, `docs/short-name`, etc.

```bash
git switch -c feat/short-name
```

## 2. Commit — Conventional Commits

Format: `<type>(<scope>): <short description>`. Types: `feat`, `fix`, `docs`, `test`,
`refactor`, `chore`. See `.claude/conventions.md`. Commit only what the user asked to
commit; one concern per commit (see *Commit hygiene*).

## 3. CHANGELOG

Add a dated entry under `[Unreleased]` in `CHANGELOG.md` — **always**, including for
small fixes.

## 4. Verify

```bash
./scripts/verify full
```

If it fails, follow the `verify` skill (diagnose → fix → re-run, bounded). Do not move
on with a red result; if you hit the bound, stop and give the escalation report.

## 5. Await dev review

Show what will be integrated, plus the verify summary:

```bash
git diff master...HEAD --stat
git log master..HEAD --oneline
```

Wait for explicit confirmation before integrating.

## 6a. Integrate — Local mode

```bash
git switch master
git merge --no-ff <branch>
git branch -d <branch>
```

`--no-ff` keeps the branch visible in history. Pushing master afterwards is optional
and needs explicit confirmation (and fails if the repo has the GitHub ruleset — use
GitHub mode there).

## 6b. Integrate — GitHub mode

Pushing is outward-facing: **confirm with the developer first.**

```bash
git push -u origin <branch>
gh pr create --title "<type>(<scope>): <description>" --body-file <body.md>
                                             # body = .github/PULL_REQUEST_TEMPLATE.md, filled in
gh pr merge --auto --merge --delete-branch   # merges once required checks pass
gh pr checks --watch                         # wait for CI
```

- `--merge` makes a merge commit, the equivalent of `--no-ff`.
- **CI fails** → `gh run view <run-id> --log-failed`, fix on the branch (the `verify`
  skill), commit, `git push`. Auto-merge stays armed. Same 3-attempt bound, then
  escalate.
- **Auto-merge unavailable** (not enabled on the repo, or no ruleset): wait for
  `gh pr checks --watch` to pass, then `gh pr merge --merge --delete-branch`.
- **After the merge**: `git switch master && git pull --ff-only`.
- Never `--admin`, never force-push (permission deny rules block both).

---

## Commit hygiene

- **One concern per commit.** Do not mix a feature, a refactor, and a bug fix. If the
  diff spans independent activities, split it into focused commits.
- **Descriptive messages.** `feat(auth): add JWT expiry check`, not `feat(auth): update auth`.

## Pre-merge checklist (full features)

- [ ] Spec is `[ACCEPTED]`, and its *Related* section points at the source/test files
- [ ] Tests cover the spec (the `test-plan` skill) and `./scripts/verify full` is green
- [ ] No scope added beyond the spec
- [ ] `CHANGELOG.md` updated

## For small fixes

Skip spec/ADR. Still: branch, a regression test for a bug, conventional commit,
`CHANGELOG.md` entry, verify, integrate.
