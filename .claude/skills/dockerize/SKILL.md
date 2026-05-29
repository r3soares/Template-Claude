---
name: dockerize
description: Containerize the project with Docker when the project type warrants it. Use when the user asks to dockerize, add a Dockerfile/compose, or set up containers. Includes a decision guide — apply only when containerization makes sense.
---

# Dockerize

Add Docker support — but only when it fits the project. Containerization is great for
services that run somewhere other than the developer's machine; it adds friction for
software that runs *on* the user's machine.

## Step 1 — Decide (do this first)

| Project type | Containerize? | Why |
|--------------|---------------|-----|
| SaaS, web app, HTTP/gRPC API, backend service | **Yes** | Reproducible runtime, easy deploy, parity dev/prod |
| Worker / cron / queue consumer | **Yes** | Same deploy target as services |
| Anything needing a DB/cache/broker locally | **Yes** (compose) | One command to bring up dependencies |
| CLI tool, desktop app, mobile app | **No** | Ships to the user's machine; Docker adds friction |
| Library / SDK / package | **No** | Consumed as a dependency, not run |

If the answer is **No**, tell the user why and stop — don't add Docker files. If it's
borderline, ask the user before proceeding.

## Step 2 — Apply the templates

Copy from `templates/docker/` into the project root and fill in the placeholders for the
actual stack:

- `Dockerfile` — adapt base image, build steps, run command. Prefer a small base
  (e.g. `-slim`/`-alpine`) and a multi-stage build for compiled stacks. Run as a
  non-root user. Expose the right port.
- `.dockerignore` — exclude VCS, deps, build output, secrets. Keep the build context small.
- `docker-compose.yml` — include the app service; add DB/cache/broker services only if
  the project needs them locally. Use env vars for config; never hardcode secrets.

## Step 3 — Wire it in

- Document the run commands in `README.md` (`docker build`, `docker compose up`).
- If a hard-to-reverse choice was made (base image strategy, orchestration), record it
  with the `adr` skill.
- Add a dated `CHANGELOG.md` entry.

## Rules

- Keep it simple — this is a solo-dev template. No multi-service orchestration the
  project doesn't actually need.
- Secrets come from the environment / `.env` (gitignored), never baked into images.
