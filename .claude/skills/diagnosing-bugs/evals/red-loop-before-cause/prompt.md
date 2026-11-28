---
tags: [template-claude]
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash, Agent]
---

Bug report: POST /orders with {"item": "book"} returns 201, but the order comes back with "item": null, and GET /orders shows null too. Please fix it.
