# Using This Template

Step-by-step checklist for starting a new project from this template. Delete this file
from the new project once you're done.

---

## 1. Copy the Template

```bash
cp -r /path/to/Template /path/to/NewProject
cd /path/to/NewProject
```

---

## 2. Initialize Git

```bash
git init
git add .
git commit -m "chore: initial project structure from template"
```

---

## 3. Update Project Identity

| File | What to update |
|------|---------------|
| `CLAUDE.md` | Replace the project-identity placeholder line. Add project-specific rules only if needed. |
| `README.md` | Project name, description, stack-specific setup/run/test commands |
| `.claude/project.md` | Actual stack details and any structure changes |
| `CHANGELOG.md` | Start fresh; the first entry is your project's start |

---

## 4. Clean Up Placeholder Content

- Remove placeholder comments from `README.md`
- Delete `SETUP.md` (template-only)

---

## 5. Decide on Docker, configure checks and CI

- **Docker**: use the `dockerize` skill — it has a decision guide. SaaS/API/web/worker →
  yes; CLI/desktop/library → no. If yes, it applies `templates/docker/`.
- **Checks + CI**: use the `setup-ci` skill. It fills the stage commands in
  `scripts/verify` (the only place they live), adds the runtime setup to
  `.github/workflows/ci.yml`, sets `VERIFY_STRICT=1`, and — if the repo is on GitHub —
  applies the branch ruleset and enables auto-merge (it asks first).
- **ADRs**: keep `docs/adr/ADR-001` and `ADR-002` — they record why the quality gates
  work this way. Your project's own decisions start at `ADR-003`.

---

## 6. Configure Stack Tooling

- Update `.gitignore` — uncomment the relevant stack section
- Update `.editorconfig` if your stack differs
- (Optional) Enable a format-on-edit hook — see `.claude/hooks/README.md`
- (Optional) Install `shellcheck` to lint the template's own scripts locally
  (`scripts/verify` reports it as SKIPPED otherwise; CI runs it regardless)

---

## 7. Start Development

Process scales by change size (see `.claude/workflow.md`):

- **Small fix** → code (+ regression test) → verify → conventional commit → dated
  `CHANGELOG.md` entry → merge (the `ship` skill).
- **Feature** → start with the `feature-spec` skill: `specs/features/{name}/spec.md`.

Claude loads the right skill when the task calls for it — you don't need to read all the
docs up front.

---

## Checklist Summary

- [ ] Template copied to new project folder
- [ ] Git initialized and first commit made
- [ ] `CLAUDE.md` project identity filled in
- [ ] `README.md` updated with project details
- [ ] `.claude/project.md` updated with stack details
- [ ] `CHANGELOG.md` reset
- [ ] Docker decision made (`dockerize` skill if applicable)
- [ ] `scripts/verify` stages configured and `./scripts/verify` green (`setup-ci` skill)
- [ ] CI runtime filled in, `VERIFY_STRICT=1` set, branch ruleset applied (GitHub only)
- [ ] `.gitignore` stack section uncommented
- [ ] `SETUP.md` deleted from new project
- [ ] First feature spec created (or first small fix shipped)
