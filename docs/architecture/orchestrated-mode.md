# Architecture: Orchestrated Mode

> How the optional orchestrated mode works, how to diagnose it, and the smoke tests that
> check its runtime behavior. The decision and its alternatives are in
> [ADR-005](../adr/ADR-005-orchestrated-mode.md).

---

## Use

```bash
claude --agent orchestrator        # orchestrated session
claude                             # classic session (the default), e.g. to ship
```

Use it for tasks big enough to benefit from separate planning, implementation and
review contexts. For a small fix, a classic session is cheaper and just as safe; the
orchestrator says so when it gets one.

The orchestrator delegates in the background. After it spawns an agent it ends its turn
and picks up again when the result arrives. Permission prompts from subagents appear in
the main session.

---

## Flow

```text
developer ─▶ orchestrator (Agent(implementer, reviewer), Read, Glob, Grep, …)
               │ plan, size by CLAUDE.md, ask approval for features
               ├─▶ implementer (Read, Edit, Write, Bash, Skill)
               │     SubagentStop ─▶ verify-on-stop.sh ─▶ scripts/verify fast
               │                     red: block (≤3), green: write .claude/.state/verify-pass
               ├─▶ reviewer (Read, Glob, Grep)
               │     SubagentStart ─▶ review-diff.sh ─▶ .claude/.state/review-<state>.diff
               │                                       + path/state via additionalContext
               │ compare review <state> with verify-pass; route findings back
               └─ Stop ─▶ verify-on-stop.sh (skipped while a subagent runs in background)
developer ─▶ classic session ─▶ ship ─▶ CI
```

The **workspace state** id is the fingerprint in `.claude/hooks/fingerprint.sh`:
HEAD, the diff against HEAD, and the untracked files' paths and contents. The same id
names the reviewed diff and the last green verify run, so a match means the reviewed
tree is the verified tree.

---

## Diagnose

| Symptom | Check |
|---------|-------|
| Reviewer answers `BLOCKED: no diff` | `review-diff.sh` didn't run or failed. Is the `SubagentStart` entry in `.claude/settings.json`? Is the script executable? Run `echo '{}' \| .claude/hooks/review-diff.sh` in the project. |
| Review state ≠ `verify-pass` | The tree changed after the review, or the last verify wasn't green. Re-run the review after the fix. |
| Implementer can't write or run commands | Project `permissions.allow` is ignored in an untrusted workspace: open `claude` interactively once and accept the trust dialog. In `-p` runs, pass `--permission-mode acceptEdits` and `--allowedTools`. |
| Verify loops on an environmental failure | It stops after 3 attempts per agent. Look for `VERIFY_*` overrides in the environment, a missing tool, or Docker. |
| Orchestrator lists unexpected tools | Ask it "which tools can you call?" and compare with `tools:` in `.claude/agents/orchestrator.md`. `scripts/tests/agents.test.sh` pins the file; a runtime difference means Claude Code behavior changed, so re-run the smoke tests. |
| Hook not firing at all | `claude --debug`, and look for the hook event (`SubagentStart`/`SubagentStop`/`Stop`) in the log. |

---

## Smoke tests

The static self-tests (`scripts/tests/agents.test.sh`, `review-diff.test.sh`,
`verify-on-stop.test.sh`, run by `./scripts/verify`) can't prove what Claude Code does
at runtime. These smoke tests can. Run them in a throwaway copy of the repo (not your
working tree):

```bash
dir="$(mktemp -d)"
git ls-files -co --exclude-standard -z | tar --null -T - -cf - | tar -xf - -C "$dir"
cd "$dir" && git init -q -b master && git add -A && git commit -qm init
perm=(--permission-mode acceptEdits --allowedTools 'Bash(./**)' 'Bash(chmod *)' 'Bash(mkdir *)')
```

`perm` stands in for the project allow rules, which an untrusted copy ignores.

| # | What | How | Expected | Status |
|---|------|-----|----------|--------|
| 1 | Mode starts, tool set | `claude -p --agent orchestrator "List every tool you can call, one per line. Call no tool."` | Only `Agent, Read, Glob, Grep` (+ `AskUserQuestion` / Task tools where the session has them). No Bash/Edit/Write, no MCP | Pass, automated (2.1.312) |
| 2 | Orchestrator can't write | Ask it to create `smoke-write.txt` with any tool | No write tool, no file | Pass, automated (2.1.312) |
| 3 | Delegation restricted | Ask it to spawn `Explore`, `general-purpose`, and an untyped agent | `Agent type '…' not found. Available agents: implementer, reviewer`; untyped: `subagent_type is required` | Pass, automated (2.1.312) |
| 4 | Reviewer reads the real diff | Modify a tracked file, add an untracked one, then ask it to spawn the reviewer and print the report | `.claude/.state/review-<state>.diff` lists both files; the report quotes `<state>`, equal to `verify-pass` | Pass, automated (2.1.312) |
| 5 | `SubagentStop` blocks a red verify | `VERIFY_TEST_CMD=false claude -p --agent orchestrator "${perm[@]}" "Have the implementer add src/hi.sh printing hi"` | Implementer blocked 3×, then orchestrator Stop blocked 3× | Pass, automated (2.1.312) |
| 6 | Failure reaches the report | Same run as 5 | Final report says not done, with the escalation details; no success claim, no gate bypass | Pass, automated (2.1.312) |
| 7 | Classic mode unchanged | `claude -p --permission-mode acceptEdits "Append a line to README.md"` | Stop hook runs verify; `verify-pass` equals the current fingerprint | Pass, automated (2.1.312) |
| 8 | Background deferral (interactive) | `claude --agent orchestrator`, delegate a multi-file task; while the implementer runs, the orchestrator's turn ends | No verify failure reported mid-implementation; verify runs when the orchestrator stops after the result | Manual, not yet run |
| 9 | Interactive niceties | Same session | `AskUserQuestion` available for approvals; workspace trust accepted, so project allow rules apply | Manual, not yet run |

When upgrading Claude Code, re-run 1–7 (a few minutes, a few cents of tokens) and
update the Status column.
