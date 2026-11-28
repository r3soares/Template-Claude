---
name: handoff
description: Compact the current session into a handoff document a fresh session can pick up from. Run as /handoff [what the next session will do].
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

# Handoff

Adapted from `handoff` in Matt Pocock's skills (github.com/mattpocock/skills, MIT —
see `LICENSE`).

Write a handoff document so a fresh session can continue the work. Save it to the
OS temp directory (`$TMPDIR`, else `/tmp`), not the project — it's a working note, not
project history. Give its path at the end.

- **State:** the goal, what is done, what is in progress, what is next, and decisions
  made in this session that aren't recorded anywhere else.
- **Point, don't copy:** reference what already exists by path or URL — the spec
  (`specs/features/…`), ADRs, the branch and PR, `CHANGELOG.md` entries, commits —
  instead of repeating it.
- **Suggested skills:** which skills the next session should use (e.g. `feature-spec`,
  `integrate`, `diagnosing-bugs`).
- **Redact** secrets and personal data.

If an argument was given, it describes what the next session will focus on: tailor the
document to it. If there's little worth handing over, keep it short and say so.
