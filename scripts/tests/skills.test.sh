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


out="$(cat "$ROOT/.claude/skills/integrate/SKILL.md")"
check "integrate: ship-it authorizes a local merge only" has 'is the go-ahead for a **local** merge'
check "integrate: push, PR and tags still need explicit confirmation" has 'still needs an'

finish
