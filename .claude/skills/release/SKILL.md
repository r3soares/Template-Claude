---
name: release
description: Cut a version — propose the next SemVer number from CHANGELOG [Unreleased], move those entries into a dated section, integrate, then tag and optionally publish a GitHub release. Run as /release [version].
argument-hint: "Optional version, e.g. 1.2.0"
disable-model-invocation: true
---

# Release

Cuts version `x.y.z` (spec: `specs/features/release/spec.md`). Integration goes
through the `integrate` skill — don't repeat its steps. `<default>` is the output of
`./scripts/default-branch`.

## 1. Preconditions — stop at the first that fails, change nothing

```bash
./scripts/default-branch                      # → <default>
git branch --show-current                     # must be <default>
git status --porcelain                        # must be empty
git remote                                    # with origin: git pull --ff-only
git tag -l 'v*' --sort=-v:refname | head -1   # last tag (none → propose 0.1.0)
./scripts/verify full                         # must be green (the verify skill on failure)
```

`CHANGELOG.md` must have a `## [Unreleased]` heading with at least one entry under it.
Missing heading → stop and point at the Keep a Changelog layout in the file's header.
Report which precondition failed and how to fix it; don't fix it yourself.

## 2. Propose the version

Read the `###` headings under `[Unreleased]` and bump the last tag:

| Under `[Unreleased]` | Bump | Before `1.0.0` |
|----------------------|------|----------------|
| `### Removed`, or an entry marked `BREAKING` | major | minor |
| `### Added` or `### Changed` | minor | minor |
| only `### Fixed` / `### Security` | patch | patch |

Show the proposal with its reason (the heading or entry that decided it) and the
entries that will go into it. A version given as the argument replaces the proposal,
but still show what the rule would pick. If `vx.y.z` already exists
(`git tag -l vx.y.z`), refuse and ask for another. **Wait for the developer's
confirmation before writing anything.**

If the project has a manifest with a version field (`package.json`,
`pyproject.toml`, `Cargo.toml`, …), mention it; bump it only if the developer says so.

## 3. CHANGELOG and integration

1. `git switch -c chore/release-x.y.z`
2. In `CHANGELOG.md`, insert `## [x.y.z] - YYYY-MM-DD` (today) right after the
   `## [Unreleased]` line plus a blank line, so `[Unreleased]` is left empty and its
   entries now sit under the new heading. Change nothing else in the file.
3. Run `integrate` with the message `chore(release): vx.y.z`. This change *is* the
   CHANGELOG entry: don't add another under `[Unreleased]`. Acceptance doesn't apply.
   The developer's `/release` confirmation in step 2 is the go-ahead for a local
   merge; push and PR still need their own confirmation, as `integrate` says.

## 4. Tag — only after the release commit is on `<default>`

Confirm before each command:

```bash
git switch <default> && git pull --ff-only    # skip the pull without a remote
git tag -a vx.y.z -m "vx.y.z"
git push origin vx.y.z                        # only with a remote
```

The tag goes on the commit `<default>` points at after the merge — never on the release
branch, whose commit is not the one GitHub merged. CI failed or the PR isn't merged →
no tag; report where it stopped.

## 5. GitHub release (optional, GitHub remote only)

Offer it; confirm first. Notes are the version's CHANGELOG section, written to a temp
file:

```bash
gh release create vx.y.z --title "vx.y.z" --notes-file <section.md>
```

`gh auth status` fails → skip it and say so.

## 6. Report

The version and why, the CHANGELOG section, the merge (local or PR URL), the tag and
whether it was pushed, the GitHub release URL, and anything skipped.
