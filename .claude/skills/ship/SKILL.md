---
name: ship
description: Branch, commit with Conventional Commits, await dev review, and merge to master. Use when the user asks to commit, ship, or merge a change. Push to origin is optional.
---

# Ship a Change

Branch → commit → review → tests → merge to master. Works for both tiers — only the
linked artifacts differ. Push to origin is always optional.

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

## 4. Await dev review

Show the diff summary so the developer can inspect what will be merged:

```bash
git diff master...HEAD --stat
git log master..HEAD --oneline
```

Wait for explicit confirmation before proceeding. Do not merge without it.

## 5. Run tests

Before merging, run the project's test suite. If any test fails, **stop**: report the
failures and wait for the developer to fix them. Master only receives stable commits.

```bash
# run whatever the project's test command is (npm test, pytest, go test ./..., etc.)
```

## 6. Merge to master

```bash
git switch master
git merge --no-ff <branch>
```

`--no-ff` keeps branch history visible in `git log`. After merging you may delete the
feature branch: `git branch -d <branch>`.

## 7. Push to origin (optional)

Confirm with the developer before pushing:

```bash
git push
```

Do **not** push unless the developer explicitly says to.

---

## Commit hygiene

- **One concern per commit.** Do not mix a new feature, a refactor, and a bug fix in
  the same commit. If the diff spans independent activities, split into focused commits.
- **Descriptive messages.** The `<short description>` must be clear about *what* was
  done: `feat(auth): add JWT expiry check` not `feat(auth): update auth`.

---

## Pre-merge checklist (full features)

- [ ] Spec is `[ACCEPTED]`, and its *Related* section points at the source/test files
- [ ] Tests written and passing
- [ ] No scope added beyond the spec
- [ ] `CHANGELOG.md` updated

(A formal traceability matrix is optional — compliance projects only; see `traceability`.)

## For small fixes

Skip spec/ADR. Still: branch, conventional commit, `CHANGELOG.md` entry, tests, merge.
