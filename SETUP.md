# Using This Template

Step-by-step checklist for starting a new project from this template.

---

## 1. Copy the Template

```bash
cp -r /path/to/Template /path/to/NewProject
cd /path/to/NewProject
```

Or on Windows:
```
xcopy /E /I D:\Projetos\Template D:\Projetos\NewProjectName
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
| `README.md` | Project name, description, stack-specific setup instructions |
| `CLAUDE.md` | No changes needed unless you want to add project-specific rules |
| `.claude/project.md` | Project name, actual stack details, any folder structure changes |
| `CHANGELOG.md` | Replace placeholder with actual project start date |

---

## 4. Clean Up Placeholder Content

- Remove example rows from `docs/traceability/traceability.md`
- Remove placeholder comments from `README.md`
- Delete `SETUP.md` from the new project (this file is for template use only)

---

## 5. Configure Stack-Specific Tooling

- Update `.gitignore` — uncomment the relevant stack section at the bottom
- Update `.editorconfig` if your stack has different indentation conventions
- Add any CI/CD workflow files to `.github/workflows/`

---

## 6. Start Development

Follow the workflow in `.claude/workflow.md`. The first step is always a feature spec:

```
specs/features/{feature-name}/spec.md
```

Use `templates/feature-template.md` as the base.

---

## Checklist Summary

- [ ] Template copied to new project folder
- [ ] Git initialized and first commit made
- [ ] `README.md` updated with project details
- [ ] `.claude/project.md` updated with stack details
- [ ] `CHANGELOG.md` placeholder updated
- [ ] Traceability matrix example rows removed
- [ ] `.gitignore` stack section uncommented
- [ ] `SETUP.md` deleted from new project
- [ ] First feature spec created in `specs/features/`
