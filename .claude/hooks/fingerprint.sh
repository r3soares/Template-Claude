#!/usr/bin/env bash
# fingerprint — hash of the working-tree state: HEAD + diff against HEAD + untracked
# files (path and content). Sourced by verify-on-stop.sh (last-green cache) and
# review-diff.sh (which state a review covers), so both name a state the same way.
# Read-only: it never touches the index or the tree. Gitignored files don't count.

fingerprint() {
  {
    git rev-parse HEAD
    git diff HEAD --binary
    git ls-files -o --exclude-standard -z |
      while IFS= read -r -d '' f; do printf '%s ' "$f"; git hash-object -- "$f"; done
  } 2>/dev/null | git hash-object --stdin
}
