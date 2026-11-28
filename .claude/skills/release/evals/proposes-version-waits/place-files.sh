#!/usr/bin/env bash
# Scaffold for this eval case: a throwaway copy of the template (see
# scripts/tests/eval-scaffold.sh) as a project already at v0.1.0, with one Added entry
# and one Fixed entry under [Unreleased].
set -eu
root="$(cd "$(dirname "$0")/../../../../.." && pwd)"
"$root/scripts/tests/eval-scaffold.sh" --app
head_lines="$(awk '/^## \[Unreleased\]/ { exit } { print }' CHANGELOG.md)"
printf '%s\n\n## [Unreleased]\n\n### Added\n- **2026-11-01** Project created from Template-Claude.\n' "$head_lines" >CHANGELOG.md
git commit -qam "chore: bootstrap project from template"
git tag -a v0.1.0 -m "v0.1.0"
# shellcheck disable=SC2016  # backticks are literal Markdown
printf '%s\n\n## [Unreleased]\n\n### Added\n- **2026-11-20** `GET /orders?status=` filters orders by status.\n\n### Fixed\n- **2026-11-21** `GET /orders/<id>` returns 404 instead of 500 for an unknown id.\n\n## [0.1.0] - 2026-11-01\n\n### Added\n- **2026-11-01** Project created from Template-Claude.\n' "$head_lines" >CHANGELOG.md
git commit -qam "feat(orders): filter by status"
