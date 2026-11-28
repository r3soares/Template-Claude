---
tags: [template-claude]
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash, Agent]
---

New feature: let clients cancel an order with DELETE /orders/<id>. A cancelled order disappears from GET /orders, and an unknown id returns 404. Write the spec first; don't implement it yet.
