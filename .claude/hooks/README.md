# Hooks

Deterministic shell commands the Claude Code harness runs on events. Configured in
`.claude/settings.json` under `"hooks"`. Keep them few and light — this is a solo-dev
template. They parse the payload with plain shell (no `jq` dependency).

Gate bypasses (`--no-verify`, `gh pr merge --admin`, force-push) are not a hook: they are
`permissions.deny` rules in `.claude/settings.json` (ADR-004). Deny rules are matched per
subcommand (`&&`, `;`, `|`, subshells), so they need no parsing here. They match the
command text — they catch mistakes, not a determined bypass.

## Active

### `verify-on-stop.sh` — Stop

The agent's self-correction loop (ADR-002). When Claude ends a turn with uncommitted
changes, it runs `./scripts/verify fast`:

- **Pass / clean tree** → Claude stops normally.
- **Fail** → exit 2: the output goes back to Claude, which must fix the root cause (the
  `verify` skill) before stopping.
- After **3** consecutive failures in a session it lets Claude stop, so Claude reports to
  you instead of looping. Counters live in `.claude/.state/` (gitignored).

Out of the box it runs the template checks whose tools are installed (see
`scripts/install-tools`) — about a second. Keep `fast` quick — it runs after every turn
with changes. Disable for a session with `CLAUDE_VERIFY_ON_STOP=0`
(e.g. `CLAUDE_VERIFY_ON_STOP=0 claude`). The hook timeout is 300s (`settings.json`).

## Optional: format-on-edit (disabled by default)

A formatter is stack-specific, so it ships disabled. The edited file's path arrives in
the hook payload on stdin (`tool_input.file_path`) — there is no environment variable
for it. To enable it, create `.claude/hooks/format-on-edit.sh` (and `chmod +x` it):

```bash
#!/usr/bin/env bash
# format-on-edit — PostToolUse(Edit|Write): format the file Claude just edited.
f="$(sed -nE 's/.*"file_path"[[:space:]]*:[[:space:]]*"(([^"\\]|\\.)*)".*/\1/p')"
[ -n "$f" ] && [ -f "$f" ] || exit 0
<your-formatter> "$f"
```

and register it in `.claude/settings.json`:

```json
"PostToolUse": [
  {
    "matcher": "Edit|Write",
    "hooks": [
      { "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/format-on-edit.sh" }
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
