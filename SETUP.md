# Using This Template

How to start a new project from this template. The `/bootstrap` skill deletes this file
once the project is set up.

---

## 1. Create the repository

On GitHub, open the template and choose **Use this template → Create a new
repository** (private is fine — the template works on GitHub Free). Then clone it:

```bash
git clone <your-new-repo-url>
cd <your-new-repo>
```

Without GitHub, copy the committed files only (not the template's history or local
state) and start a repo:

```bash
git -C /path/to/Template-Claude archive HEAD | tar -x -C /path/to/NewProject
cd /path/to/NewProject && git init && git add . && git commit -m "chore: initial project structure from template"
```

## 2. Run `/bootstrap`

```bash
claude
```

Then type `/bootstrap`. Claude asks five questions — project name and description,
stack, conversation language, where it runs, and how the code is split into modules —
and then:

- fills in `CLAUDE.md` (identity, language), `README.md` (run instructions and
  environments), `docs/architecture/overview.md` and, for a modular project,
  `.claude/rules/architecture.md`;
- resets `CHANGELOG.md` and uncomments the stack's `.gitignore` section;
- decides on Docker (`dockerize`) and configures checks and CI (`setup-ci`), including
  the merge gate: a ruleset where GitHub allows it, the agent gate on private GitHub
  Free repos (ADR-008);
- runs `./scripts/verify full`, deletes this file, merges the setup (`integrate`) and
  offers the `v0.1.0` tag.

Pushing, the PR and the tag each wait for your confirmation. Running `/bootstrap` again
on a bootstrapped project changes nothing.

## 3. Optional

- Install the template's quality tools locally, so the Stop hook runs the same checks
  as CI: `./scripts/install-tools` and `shellcheck` (apt/brew).
- Enable a format-on-edit hook for your formatter: see `.claude/hooks/README.md`.

## 4. Start building

Ask for the first feature ("New feature: … — write the spec first"); the `feature-spec`
skill takes it from there.
