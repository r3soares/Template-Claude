# ADR-004: Block Gate Bypasses with Permission Deny Rules [ACCEPTED]

> Gate bypasses (`--no-verify`, `gh pr merge --admin`, force-push) are blocked by
> `permissions.deny` rules in `.claude/settings.json`, replacing the `git-guard.sh`
> `PreToolUse` hook. The decision of ADR-002 (block bypasses deterministically) stands;
> only the mechanism changes.

---

## Status

`[ACCEPTED]`

Supersedes: —  
Superseded by: —  
Amends: ADR-002 (Layer 1, the bypass guard)

---

## Context

ADR-002 added `git-guard.sh`: a shell script that regex-matched the Bash command text
to block bypasses and warn on commits to master. Claude Code now matches Bash
permission rules per subcommand — it splits `&&`, `||`, `;`, `|`, newlines, and looks
inside subshells, command substitutions and loop bodies — and a deny rule always wins
over allow rules. That covers what the script did, with less code to maintain and
fewer parsing edge cases.

---

## Decision

1. Remove `git-guard.sh` and its `PreToolUse` entry.
2. Add `permissions.deny` rules for: `--no-verify` and `-n` on `git commit`,
   `--no-verify` on `git push`, any force-push (`--force*`, `-f`, `+refspec`), and
   `gh pr merge --admin`.
3. Branching first is the `ship` skill's job; there is no on-master warning.

---

## Options Considered

### Option A: Deny rules (chosen)

**Pros:**
- Declarative, no script; compound commands handled by the harness.
- Same configuration file as the rest of the permissions.

**Cons:**
- Can't depend on state (current branch): force-push is denied on every branch.
- Text patterns can false-positive (e.g. a commit message containing ` -n `).

### Option B: Keep `git-guard.sh`

**Pros:**
- Branch-aware: force-push allowed on feature branches; can warn on master.

**Cons:**
- 50+ lines of regex that misses forms the harness parser catches.

---

## Consequences

### Positive

- One less script to lint, test and keep in sync with Claude Code's payload format.

### Negative / Trade-offs

- Claude cannot force-push at all; the developer does it by hand when needed.

### Risks

- Like the hook, rules match the command text — they catch mistakes, not a determined
  bypass (e.g. `git -c … push`). CI and the branch ruleset remain the real gate.

---

## Related

- ADR: [ADR-002](ADR-002-layered-validation-and-github-gate.md)
- Config: `.claude/settings.json` → `permissions.deny`
