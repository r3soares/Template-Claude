---
name: bootstrap
description: Turn a fresh copy of this template into the developer's project — identity, language, README, project map, module rule, CHANGELOG, Docker, CI, first verify, merge and v0.1.0 tag. Run once, as /bootstrap, right after "Use this template".
disable-model-invocation: true
---

# Bootstrap a new project

Turns a repo just created from the template into the developer's project in one
session (spec: `specs/features/bootstrap/spec.md`). It orchestrates; Docker, CI,
verify stages and integration stay in `dockerize`, `setup-ci` and `integrate` — run
those skills, don't repeat their steps.

## 0. Already done?

- `SETUP.md` is gone **and** `CLAUDE.md` no longer contains
  `Replace this line with the project identity` → the project is bootstrapped. If
  `CLAUDE.md` still says `Reply to the developer in: <language>`, ask only for the
  conversation language and fill that line in. If `git tag -l v0.1.0` prints nothing,
  offer step 5.4. Otherwise say so and stop. Change nothing else.
- Otherwise, check each step below before doing it and skip the ones already done
  (a run that was interrupted resumes where it stopped).

## 1. Ask — once, all together

Skip any question the request already answers. Ask the rest in one go (with
`AskUserQuestion` when available):

1. **Project name** and a one-line description.
2. **Stack**: language, framework, package manager.
3. **Conversation language** (code, comments, docs and commits stay in English).
4. **Where it runs**: local only · VPS / own server · PaaS (e.g. Vercel, Render) ·
   undecided — and a staging URL, if one exists.
5. **Module structure**: single module · API and implementation modules (ask for the
   names) · decide later.

## 2. Branch

Follow `integrate` step 1: `git switch -c chore/bootstrap`.

## 3. Fill in the project files

Configuration and docs only: no application code and no tests — the first feature
brings those. For a modular project, create just the empty module folders the overview
names (with the stack's package marker if it needs one). Don't delete `SETUP.md` yet —
step 5 does, after verify is green.

- **`CLAUDE.md`** — replace the identity placeholder line with the name and description;
  set `Reply to the developer in: <language>`. Offer to also set `"language"` in
  `.claude/settings.local.json` (untracked), which enforces it.
- **`README.md`** — name, description, prerequisites, and install / run / test commands
  for the stack. Add an **Environments** section: how to run it locally (the command and
  the URL or port it answers on) and the staging URL, if any. The `acceptance` agent
  starts the product from these instructions (ADR-009). Remove the placeholder comments.
- **`docs/architecture/overview.md`** — replace the overview paragraph; add the stack and
  one *Components* subsection per first module.
- **`.claude/rules/architecture.md`** — only for "API and implementation modules":

  ```markdown
  ---
  paths:
    - "src/**"
  ---

  # Module Boundaries

  Modules: <api modules> (abstractions) · <implementation modules>.

  - Implementation modules depend on API modules, never on another implementation.
  - API modules depend on no implementation module.
  - Wiring two modules together is an implementation's job, not an API's.
  - No dependency cycles. An exception needs an ADR.
  ```

  Adapt the paths to the stack's source layout.
  Claude Code asks for approval before writing under `.claude/`, even when edits are
  auto-accepted: expected. Declined or not possible (a non-interactive run) → show the
  content, ask the developer to create it, and stop; a later `/bootstrap` resumes.
- **`CHANGELOG.md`** — keep the header (title, intro, format/versioning lines), replace
  everything below with `## [Unreleased]`, `### Added` and one dated entry:
  "Project created from Template-Claude." The template's history isn't the project's.
- **`.gitignore`** — uncomment the stack's section. **`.editorconfig`** — adjust if the
  stack's conventions differ.

Keep what the template ships for the project: `docs/adr/`, `specs/`, skills, agents,
hooks, `templates/`. The project's own ADRs take the next free number.

## 4. Docker, then CI

1. Run the `dockerize` skill — its decision guide says whether this project gets Docker.
2. Run the `setup-ci` skill — verify stages for the stack, CI runtime, Dependabot
   ecosystem, `VERIFY_STRICT`, and the ruleset (or, on a private GitHub Free repo, the
   agent-gate explanation). Stages the stack can't fill yet stay unconfigured; say so.
   If the stack's test runner fails when no tests exist yet (e.g. `unittest` exits 5),
   keep `TEST_CMD="template_test"` and report it as the first thing to wire up with the
   first feature — don't write a placeholder test to make it pass.

## 5. Verify, clean up, integrate, tag

1. `./scripts/verify full` must be green (the `verify` skill on failure). Not green →
   stop here: don't delete `SETUP.md` and don't integrate.
2. Delete `SETUP.md`.
3. Run the `integrate` skill (`chore: bootstrap project from template`). Pushing and the
   PR need the developer's confirmation, as always.
4. After the merge, offer the first tag — confirm before each command:

   ```bash
   git switch master && git pull --ff-only   # skip the pull without a remote
   git tag -a v0.1.0 -m "v0.1.0: project bootstrapped from Template-Claude"
   git push origin v0.1.0                    # only with a remote
   ```

## 6. Summary

List what was filled in, the Docker/CI decisions, the gate (ruleset, agent gate or
local), anything left unconfigured, and the next step: the first feature with the
`feature-spec` skill.
