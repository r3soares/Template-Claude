# ADR-010: Acceptance Evidence Outside `.claude/` [ACCEPTED]

> The `acceptance` agent's evidence moves from `.claude/.state/acceptance/<state>/` to
> `.acceptance/<state>/` at the project root (gitignored), because Claude Code asks for
> approval before any Bash write under `.claude/`.

---

## Status

`[ACCEPTED]`

Supersedes: —  
Superseded by: —  
Amends: ADR-009 (decision 3: where the evidence lives)

---

## Context

ADR-009 put the evidence (HTTP transcripts, start-up logs, screenshots) in
`.claude/.state/acceptance/<state>/`, next to the other hook state. Claude Code treats
`.claude/` as a protected directory: a Bash command that writes there
(`curl … > file`, `| tee file`) needs approval even with edits auto-accepted.

- **Headless and orchestrated runs** have nobody to approve: the write is denied, and
  the agent reports `BLOCKED` on criteria the product actually meets. Found by the
  integrate eval `feature-marks-spec-implemented` (2026-11-28).
- **Interactive sessions** get one approval prompt per evidence file.
- Earlier passes worked only because the path was in a shell variable, which the check
  doesn't resolve. That is a blind spot, not a design.

Tested with Claude Code 2.1.332: `echo hi > .claude/.state/x` and
`echo hi | tee .claude/.state/x` are denied in `claude -p --permission-mode
acceptEdits --allowedTools Bash`; the same writes to `.acceptance/x` run.

---

## Decision

1. `acceptance-start.sh` creates `.acceptance/<state>/` (same fingerprint name, older
   directories removed) and hands the absolute path to the agent, as before.
2. `.acceptance/` is in `.gitignore`. Ignored files stay out of the workspace
   fingerprint, the gitleaks scan and `git status`, so evidence never changes the state
   it describes.
3. Everything else in ADR-009 stands: the hook, the black-box guard, the report format.

---

## Options Considered

### Option A: `.acceptance/` at the project root (chosen)

**Pros:**
- Writes need no approval; the agent runs unattended.
- Still inside the project, so a remote reviewer finds it at a fixed path.

**Cons:**
- One more ignored directory at the root.

### Option B: Tell the agent to write through a variable or `curl -o`

**Pros:**
- No file moves.

**Cons:**
- Relies on what the permission check happens not to detect; a later Claude Code
  version can close it, and the failure returns silently as `BLOCKED`.

### Option C: A temp dir outside the project

**Pros:**
- No approval, nothing to ignore.

**Cons:**
- The path changes every run and disappears with the container; evidence for remote or
  phone review (ADR-009) needs a stable place.

---

## Consequences

**Positive:**
- Acceptance works in orchestrated mode, `claude -p` and evals without prompts.

**Trade-offs:**
- Projects created before this change keep `.claude/.state/acceptance/` in old runs;
  it is ignored and can be deleted.

**Risks:**
- If Claude Code starts protecting other dot-directories, the same failure returns:
  the integrate eval `feature-marks-spec-implemented` catches it.

---

## Related

- [ADR-009](ADR-009-black-box-acceptance-agent.md) — the acceptance agent
- `.claude/hooks/acceptance-start.sh`, `.gitignore`, `scripts/tests/acceptance-hooks.test.sh`
