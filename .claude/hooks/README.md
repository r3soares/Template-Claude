# Hooks

Deterministic shell commands the Claude Code harness runs on events. Configured in
`.claude/settings.json` under `"hooks"`. Keep them few and light — this is a solo-dev
template. Both parse the payload with plain shell (no `jq` dependency).

## Active

### `git-guard.sh` — PreToolUse(Bash)

- **Blocks** (exit 2) gate bypasses: `--no-verify` on commit/push, `gh pr merge --admin`,
  and force-push to `master`/`main`.
- **Warns** (non-blocking) when a `git commit`/`git push` runs on `master`/`main`,
  nudging you to branch first.

It matches the command text, so it catches mistakes — not a determined bypass.

### `verify-on-stop.sh` — Stop

The agent's self-correction loop (ADR-002). When Claude ends a turn with uncommitted
changes, it runs `./scripts/verify fast`:

- **Pass / clean tree** → Claude stops normally.
- **Fail** → exit 2: the output goes back to Claude, which must fix the root cause (the
  `verify` skill) before stopping.
- After **3** consecutive failures in a session it lets Claude stop, so Claude reports to
  you instead of looping. Counters live in `.claude/.state/` (gitignored).

It is a no-op until `scripts/verify` has configured stages. Keep `fast` quick — it runs
after every turn with changes. Disable for a session with `CLAUDE_VERIFY_ON_STOP=0`
(e.g. `CLAUDE_VERIFY_ON_STOP=0 claude`). The hook timeout is 300s (`settings.json`).

## Optional: format-on-edit (disabled by default)

A formatter is stack-specific, so it ships disabled. To enable it, add a `PostToolUse`
hook to `.claude/settings.json` and point it at your formatter. Example:

```json
"PostToolUse": [
  {
    "matcher": "Edit|Write",
    "hooks": [
      { "type": "command", "command": "<your-formatter> $CLAUDE_FILE_PATHS" }
    ]
  }
]
```

Replace `<your-formatter>` with e.g. `prettier --write`, `ruff format`, `gofmt -w`,
`rustfmt`. Use the same formatter whose *check* runs in `scripts/verify`'s lint stage,
so the hook and CI agree.

## Notes

- `$CLAUDE_PROJECT_DIR` resolves to the project root; use it for script paths.
- Hooks run with the project as the working directory.
- A hook that exits `2` blocks the tool call (PreToolUse) or the stop (Stop); any other
  non-zero is a non-blocking error.
