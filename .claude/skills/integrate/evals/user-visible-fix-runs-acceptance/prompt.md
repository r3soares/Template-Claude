---
tags: [template-claude]
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash, Agent]
---

I fixed a bug: GET /orders and POST /orders returned 404 because their routes were never registered in src/server.py. It's a small fix, ship it.
