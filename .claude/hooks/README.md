# Hooks

Deterministic shell commands the Claude Code harness runs on events. Configured in
`.claude/settings.json` under `"hooks"`. Keep them few and light — this is a solo-dev
template.

## Active

### `git-guard.sh` — PreToolUse(Bash)

Warns (non-blocking) when a `git commit`/`git push` runs on `master`/`main`, nudging you
to branch first. To make it **blocking**, change its final `exit 0` to `exit 2`.

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
`rustfmt`. Match the formatter the project already uses so CI and local agree.

## Notes

- `$CLAUDE_PROJECT_DIR` resolves to the project root; use it for script paths.
- Hooks run with the project as the working directory.
- A hook that exits `2` blocks the tool call; any other non-zero is a non-blocking error.
