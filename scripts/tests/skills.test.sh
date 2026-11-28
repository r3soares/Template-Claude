#!/usr/bin/env bash
# Static self-tests for skills whose wiring matters beyond their prose:
# - bootstrap runs only when invoked (/bootstrap) and keeps its guard and delegation.

# shellcheck source=scripts/tests/lib.sh
. "$(dirname "$0")/lib.sh"

SKILL="$ROOT/.claude/skills/bootstrap/SKILL.md"
out="$(awk 'NR == 1 && $0 == "---" { next } $0 == "---" { exit } { print }' "$SKILL")"
check "bootstrap: name in frontmatter" has 'name: bootstrap'
check "bootstrap: not auto-invoked" has 'disable-model-invocation: true'
check "bootstrap: has a description" has 'description: '

out="$(cat "$SKILL")"
check "bootstrap: already-done guard uses the CLAUDE.md placeholder" has 'Replace this line with the project identity'
check "bootstrap: delegates Docker to dockerize" has 'dockerize'
check "bootstrap: delegates CI to setup-ci" has 'setup-ci'
check "bootstrap: integrates through integrate" has 'integrate'
check "bootstrap: no integration before a green verify" has "don't integrate"
check "bootstrap: README gets an Environments section" has 'Environments'
check "bootstrap: SETUP.md deleted only after verify" has "Don't delete"
check "bootstrap: no application code or tests" has 'no application code and no tests'
check "bootstrap: guard checks the tag" has 'git tag -l v0.1.0'
check "bootstrap: guard fills a missing conversation language" has 'ask only for the'
check "bootstrap: tag needs confirmation" has 'confirm before each command'
check "bootstrap: suggests grill-me for an unclear stack or modules" has '/grill-me'
out="$(cat "$ROOT/.claude/skills/grill-me/SKILL.md")"
check "grill-me: hands a not-yet-bootstrapped project to /bootstrap" has 'Replace this line with the project identity'


out="$(cat "$ROOT/.claude/skills/integrate/SKILL.md")"
check "integrate: ship-it authorizes a local merge only" has 'is the go-ahead for a **local** merge'
check "integrate: push, PR and tags still need explicit confirmation" has 'still needs an'

# release: deliberate only; nothing written before confirmation; tag after the merge.
out="$(awk 'NR == 1 && $0 == "---" { next } $0 == "---" { exit } { print }' "$ROOT/.claude/skills/release/SKILL.md")"
check "release: not auto-invoked" has 'disable-model-invocation: true'
out="$(cat "$ROOT/.claude/skills/release/SKILL.md")"
check "release: waits for confirmation before writing" has 'Wait for the developer'"'"'s'
check "release: integrates through integrate" has "Run \`integrate\`"
check "release: tags only after the merge" has 'only after the release commit is on'
check "release: annotated tag" has 'git tag -a vx.y.z'
check "release: reads the default branch" has './scripts/default-branch'
check "release: refuses an existing tag" has 'already exists'

# Adopted skills (Matt Pocock's collection, MIT): notice kept, invocation as designed.
for sk in grill-me diagnosing-bugs handoff retro; do
  out="$(cat "$ROOT/.claude/skills/$sk/LICENSE" 2>/dev/null)"
  check "$sk: MIT notice of the original kept" has 'Copyright (c) 2026 Matt Pocock'
  out="$(cat "$ROOT/.claude/skills/$sk/SKILL.md")"
  check "$sk: says where it was adapted from" has 'github.com/mattpocock/skills'
done
for sk in handoff retro; do
  out="$(awk 'NR == 1 && $0 == "---" { next } $0 == "---" { exit } { print }' "$ROOT/.claude/skills/$sk/SKILL.md")"
  check "$sk: not auto-invoked" has 'disable-model-invocation: true'
done
out="$(cat "$ROOT/.claude/skills/diagnosing-bugs/SKILL.md")"
check "diagnosing-bugs: no hypothesis before a red loop" has 'Reading code'
check "diagnosing-bugs: ships its HITL script" test -f "$ROOT/.claude/skills/diagnosing-bugs/scripts/hitl-loop.template.sh"

finish
