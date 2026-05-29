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

## 5. Decide on Docker and CI

- **Docker**: use the `dockerize` skill — it has a decision guide. SaaS/API/web/worker →
  yes; CLI/desktop/library → no. If yes, it applies `templates/docker/`.
- **CI**: fill in `.github/workflows/ci.yml` with the `setup-ci` skill (runtime, install,
  lint, test for your stack).

---

## 6. Configure Stack Tooling

- Update `.gitignore` — uncomment the relevant stack section
- Update `.editorconfig` if your stack differs
- (Optional) Enable a format-on-edit hook — see `.claude/hooks/README.md`

---

## 7. Start Development

Process scales by change size (see `.claude/workflow.md`):

- **Small fix** → code → conventional commit → dated `CHANGELOG.md` entry → PR.
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
- [ ] CI workflow filled in (`setup-ci` skill)
- [ ] `.gitignore` stack section uncommented
- [ ] `SETUP.md` deleted from new project
- [ ] First feature spec created (or first small fix shipped)
