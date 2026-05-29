---
name: open-pr
description: Branch, commit with Conventional Commits, and open a pull request. Use when the user asks to commit, push, open a PR, or ship a change. Covers both small fixes and full features.
---

# Open a PR

The Git + PR flow. Works for both tiers — only the linked artifacts differ.

## 1. Branch

Never commit feature work directly to `master`/`main`. Create a branch named for the
change: `feat/short-name`, `fix/short-name`, `docs/short-name`, etc.

```bash
git switch -c feat/short-name
```

(The `git-guard` hook warns if you try to commit on master/main.)

## 2. Commit — Conventional Commits

Format: `<type>(<scope>): <short description>`. Types: `feat`, `fix`, `docs`, `test`,
`refactor`, `chore`. See `.claude/conventions.md` for the full spec and examples.

Commit only what the user asked to commit. Keep commits focused.

## 3. CHANGELOG

Add a dated entry under `[Unreleased]` in `CHANGELOG.md` — **always**, including for
small fixes. This is the lightweight history.

## 4. Open the PR

Use `gh` and base the description on `templates/pr-template.md`
(`.github/PULL_REQUEST_TEMPLATE.md` pre-fills it on GitHub).

```bash
git push -u origin HEAD
gh pr create --fill   # then edit the body to match the template
```

The PR body must link, when they exist: the **spec**, the **ADR**, and the
**traceability** entry. For a small fix, those are `N/A` — say so explicitly.

## Pre-PR checklist (full features)

- [ ] Spec is `[ACCEPTED]`
- [ ] Tests written and passing (see `test-plan`)
- [ ] Traceability matrix updated (see `traceability`)
- [ ] No scope added beyond the spec
- [ ] `CHANGELOG.md` updated

## For small fixes

Skip spec/ADR/traceability. Still: branch, conventional commit, `CHANGELOG.md` entry, PR.

## Confirm before pushing

Pushing and opening a PR are outward-facing. Confirm with the user before `git push`
and `gh pr create` unless they already told you to ship.
