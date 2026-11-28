# Feature: Release — version, CHANGELOG section and tag [ACCEPTED]

> `/release` cuts a version: proposes the next SemVer number from `[Unreleased]`, moves
> those entries into a dated section, integrates that, tags the merge, and offers a
> GitHub release.

---

## Context

The template tags `v0.1.0` at `/bootstrap` and asks for version tags so a bug can be
traced between versions, but nothing says how to cut the next one. Today it is done by
hand, if at all: pick a number, edit `CHANGELOG.md`, commit, tag, push. Steps get
skipped (a tag without a CHANGELOG section, a section without a tag, a tag on a
commit that never passed `verify`), and on GitHub the release commit has to pass the
same gate as any other change.

---

## Impact

**Today:** `v0.1.0` at bootstrap, then no procedure; `[Unreleased]` grows forever.

**After:** `/release` → a proposed version with its reason, confirmed by the developer
→ `CHANGELOG.md` gets `## [x.y.z] - <date>` and an empty `[Unreleased]` → `integrate`
→ an annotated tag `vx.y.z` on the default branch → optional `gh release` with the
section as notes. Push, tag push and the GitHub release each need confirmation.

**Files touched:**

| File | Change |
|------|--------|
| `.claude/skills/release/SKILL.md` | New, user-invoked only |
| `.claude/skills/release/evals/` | Eval: proposes a version and asks before writing |
| `scripts/tests/skills.test.sh` | Frontmatter and guard checks |
| `README.md`, `CHANGELOG.md` | Skills list, entry |

---

## Scope

### In Scope

- Preconditions, checked before anything is written: on the default branch
  (`./scripts/default-branch`), clean tree, up to date with `origin` when there is
  one, `[Unreleased]` not empty, `./scripts/verify full` green.
- Version proposal from the last `v*` tag and the `[Unreleased]` headings: `Removed`
  or a `BREAKING` entry → major; `Added` or `Changed` → minor; only `Fixed`/`Security`
  → patch. Before `1.0.0`, a breaking change bumps the minor. No tag yet → propose
  `0.1.0`. The developer confirms or picks another version; an existing tag is refused.
- `CHANGELOG.md`: `## [Unreleased]` stays, empty; its entries move under
  `## [x.y.z] - YYYY-MM-DD` (today); nothing else in the file changes.
- Commit `chore(release): vx.y.z` through `integrate` on branch `chore/release-x.y.z`
  (local merge or CI-gated PR, as for any change).
- After the merge, an annotated tag `vx.y.z` on the default branch's merge commit, and
  with a remote, `git push origin vx.y.z` and optionally
  `gh release create vx.y.z --notes-file <section>` — each confirmed first.

### Out of Scope

- Publishing packages, building artifacts, deploying.
- Bumping version fields in manifests (`package.json`, `pyproject.toml`): the skill
  mentions them if found, the developer decides.
- Release automation in CI.

---

## Acceptance Criteria

- [ ] `/release` with entries under `[Unreleased]` and a last tag `v0.1.0` proposes a
      version with the heading that justifies it, and writes nothing before the
      developer confirms.
- [ ] A dirty tree, a branch other than the default, an empty `[Unreleased]` or a red
      `verify` stops before any change, saying which.
- [ ] After confirmation, `CHANGELOG.md` has an empty `[Unreleased]` followed by the
      dated version section with the moved entries.
- [ ] The tag is annotated, on the default branch, created only after the release
      commit is merged; pushing it needs a confirmation.

---

## Finish Line

- **Outcome:** a release can be cut in one command without skipping a step.
- **Run:** the eval case via `scripts/tests/run-skill-evals.sh release <case>`.
- **Environment:** `local`
- **Check:** the run proposes `0.2.0` (an `Added` entry after `v0.1.0`), explains why,
  and leaves the tree, branches and tags unchanged while waiting for confirmation.

---

## Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| The proposed tag already exists | Refuse; show the existing tag and ask for another version |
| CHANGELOG has no `[Unreleased]` heading | Stop; point at the Keep a Changelog layout |
| CI fails on the release PR | `integrate`'s failure handling; no tag |
| No remote | Local merge and local tag; no push, no GitHub release |
| `gh` not authenticated | Tag pushed if confirmed; skip the GitHub release and say so |

---

## Technical Notes

- User-invoked only (`disable-model-invocation: true`): a release is a deliberate act;
  "ship it" must keep meaning `integrate`, not a version bump.
- The tag goes on the merge commit, never on the release branch: on GitHub the
  branch's commit is not what lands on the default branch.

---

## Open Questions

None.

---

## Related

- ADR: — (a procedure, nothing hard to reverse)
- Spec: [bootstrap](../bootstrap/spec.md) (creates `v0.1.0`)
- Source files: `.claude/skills/release/SKILL.md`
- Tests: `scripts/tests/skills.test.sh`; eval in `.claude/skills/release/evals/`
