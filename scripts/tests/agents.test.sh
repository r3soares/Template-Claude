#!/usr/bin/env bash
# Static self-tests for the orchestrated-mode agents (.claude/agents/, ADR-005) and
# their wiring in .claude/settings.json.
#
# Agent frontmatter must use a canonical subset of YAML so plain bash can verify it
# without a parser: one `key: value` per line, no lists, quotes, comments or
# continuation lines, known keys only (Claude Code silently ignores an unknown key —
# a misspelled `tools` would inherit every tool), no duplicates, and `tools` as one
# comma-separated line compared against an EXACT expected set. Anything else fails.
# Widening an agent's tools means updating this test on purpose.
#
# What this cannot prove — that Claude Code enforces these lists at runtime, and that
# the hooks fire — is covered by the smoke tests in docs/architecture/orchestrated-mode.md.

# shellcheck source=scripts/tests/lib.sh
. "$(dirname "$0")/lib.sh"

AGENTS="$ROOT/.claude/agents"
SETTINGS="$ROOT/.claude/settings.json"
ORCHESTRATOR_TOOLS="Agent(implementer, reviewer), Read, Glob, Grep, AskUserQuestion, TaskCreate, TaskGet, TaskList, TaskUpdate"
REVIEWER_TOOLS="Read, Glob, Grep"
IMPLEMENTER_TOOLS="Read, Edit, Write, Bash, Skill"
KEYS=" name description tools model "
REQUIRED="name description tools"

# frontmatter <file> — lines between a first-line `---` and the next `---`.
frontmatter() {
  awk 'NR == 1 { if ($0 != "---") exit 1; next }
       $0 == "---" { closed = 1; exit }
       { print }
       END { if (!closed) exit 1 }' "$1"
}

# tool_entries <tools value> — one entry per line, sorted; split on ", " outside
# parentheses. Fails on any other separator or unbalanced parentheses.
tool_entries() {
  awk -v s="$1" 'BEGIN {
    n = length(s); d = 0; e = ""
    for (i = 1; i <= n; i++) {
      c = substr(s, i, 1)
      if (c == "(") d++
      if (c == ")") d--
      if (c == "," && d == 0) {
        if (substr(s, i + 1, 1) != " " || e == "") bad = 1
        print e; e = ""; i++; continue
      }
      e = e c
    }
    print e
    if (bad || d != 0 || e == "") exit 1
  }' | LC_ALL=C sort
  [ "${PIPESTATUS[0]}" -eq 0 ]
}

# valid_agent <file> <expected tools> — canonical frontmatter, name == file name,
# required keys present, tools exactly the expected set. Reason in $out on failure.
valid_agent() {
  local file="$1" fm line key val first seen=" " name="" tools="" got want
  out=""
  fm="$(frontmatter "$file")" || { out="$file: no ---/--- frontmatter"; return 1; }
  while IFS= read -r line; do
    if [[ $line =~ [[:space:]]$ ]] || ! [[ $line =~ ^([a-zA-Z]+):\ ([^[:space:]].*)$ ]]; then
      out="$file: non-canonical frontmatter line: '$line'"; return 1
    fi
    key="${BASH_REMATCH[1]}" val="${BASH_REMATCH[2]}"
    case "$KEYS" in *" $key "*) ;; *) out="$file: unknown key '$key'"; return 1 ;; esac
    case "$seen" in *" $key "*) out="$file: duplicate key '$key'"; return 1 ;; esac
    seen="$seen$key "
    first="${val:0:1}"
    case "$first" in "'" | '"' | '[' | '{' | '&' | '*' | '!' | '|' | '>' | '%' | '@' | '`' | '-' | '#' | '?' | ':' | ',')
      out="$file: '$key' value starts with a YAML indicator"; return 1 ;;
    esac
    case "$val" in *': '* | *' #'*) out="$file: '$key' value contains ': ' or ' #'"; return 1 ;; esac
    [ "$key" = name ] && name="$val"
    [ "$key" = tools ] && tools="$val"
  done <<<"$fm"
  for key in $REQUIRED; do
    case "$seen" in *" $key "*) ;; *) out="$file: missing required key '$key'"; return 1 ;; esac
  done
  [ "$name" = "$(basename "$file" .md)" ] || { out="$file: name '$name' != file name"; return 1; }
  got="$(tool_entries "$tools")" || { out="$file: tools not one ', '-separated line: '$tools'"; return 1; }
  want="$(tool_entries "$2")"
  [ "$got" = "$want" ] || { out="$file: tools '$tools' != expected '$2'"; return 1; }
}

# lacks_tool <file> <tool> — explicit statement of a forbidden tool (the exact-set
# check already implies it; this keeps the intent readable in a failure).
lacks_tool() { ! frontmatter "$1" | grep -E '^tools: ' | tr ',' '\n' | sed 's/^ *//' | grep -qxE "$2(\(.*)?"; }

for a in orchestrator:ORCHESTRATOR_TOOLS reviewer:REVIEWER_TOOLS implementer:IMPLEMENTER_TOOLS; do
  name="${a%%:*}" var="${a#*:}"
  check "$name: canonical frontmatter with exactly the expected tools" valid_agent "$AGENTS/$name.md" "${!var}"
done
for t in Bash Edit Write NotebookEdit PowerShell Monitor Skill Workflow WebFetch; do
  check "orchestrator: no $t" lacks_tool "$AGENTS/orchestrator.md" "$t"
done
for t in Bash Edit Write NotebookEdit PowerShell Agent; do
  check "reviewer: no $t" lacks_tool "$AGENTS/reviewer.md" "$t"
done
check "implementer: no Agent (no nested delegation)" lacks_tool "$AGENTS/implementer.md" Agent

# settings.json: mode is per session, agent teams stay off, hooks are wired.
out="$(cat "$SETTINGS")"
check "settings: no default \"agent\" (classic mode stays the default)" lacks '"agent"'
check "settings: agent teams not enabled" lacks "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS"
check "settings: SubagentStop wired for implementer" has '"matcher": "^implementer$"'
check "settings: SubagentStart wired for reviewer" has '"matcher": "^reviewer$"'
check "settings: review-diff hook registered" has '.claude/hooks/review-diff.sh"'

# Mutations — each must be rejected, so a later edit can't silently loosen an agent.
mut_dir="$(mktemp -d)"
tmp_dirs+=("$mut_dir")
# rejects <description> <agent> <expected tools> <sed script> — mutate a copy; expect failure.
rejects() {
  local desc="$1" name="$2" tools="$3"
  sed "$4" "$AGENTS/$name.md" >"$mut_dir/$name.md"
  if valid_agent "$mut_dir/$name.md" "$tools"; then
    out="mutation accepted: $desc"
    check "rejects: $desc" false
  else
    check "rejects: $desc" true
  fi
}
O="$ORCHESTRATOR_TOOLS"
rejects "tools removed" orchestrator "$O" '/^tools: /d'
rejects "Bash added" orchestrator "$O" 's/^tools: /tools: Bash, /'
rejects "delegation widened" orchestrator "$O" 's/Agent(implementer, reviewer)/Agent(implementer, reviewer, Explore)/'
rejects "unrestricted Agent" orchestrator "$O" 's/Agent(implementer, reviewer)/Agent/'
rejects "duplicate tool entry" orchestrator "$O" 's/^tools: /tools: Read, /'
rejects "tools as a YAML list" orchestrator "$O" 's/^tools: .*/tools:\n  - Read/'
rejects "tools in brackets" orchestrator "$O" 's/^tools: \(.*\)/tools: [\1]/'
rejects "comma without space" orchestrator "$O" 's/Read, Glob/Read,Glob/'
rejects "duplicate tools key" orchestrator "$O" 's/^\(tools: .*\)/\1\ntools: Read/'
rejects "misspelled key (Tools)" orchestrator "$O" 's/^tools:/Tools:/'
rejects "disallowedTools added" orchestrator "$O" 's/^\(tools: .*\)/\1\ndisallowedTools: Edit/'
rejects "comment in a value" orchestrator "$O" 's/^\(tools: .*\)/\1 # note/'
rejects "unclosed frontmatter" orchestrator "$O" '1!{/^---$/d}'
rejects "name differs from file" orchestrator "$O" 's/^name: .*/name: boss/'
rejects "Edit added to reviewer" reviewer "$REVIEWER_TOOLS" 's/^tools: .*/&, Edit/'
rejects "Agent added to implementer" implementer "$IMPLEMENTER_TOOLS" 's/^tools: .*/&, Agent/'

finish
