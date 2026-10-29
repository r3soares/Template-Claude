#!/usr/bin/env bash
# Self-tests for .claude/hooks/review-diff.sh: the diff file covers every kind of
# uncommitted change, leaves git state untouched, and is named by the same
# fingerprint verify-on-stop.sh caches.

# shellcheck source=scripts/tests/lib.sh
. "$(dirname "$0")/lib.sh"

new_repo .claude/hooks/review-diff.sh .claude/hooks/fingerprint.sh
echo "keep" >src/old.sh
echo "gone" >src/gone.sh
printf '\0\1\2' >src/blob.bin
printf '%s\n' .claude/.state/ ignored.txt >.gitignore
git add -A
git commit -qm "more files"
export CLAUDE_PROJECT_DIR="$repo"

hook() { run sh -c 'printf "{\"hook_event_name\":\"SubagentStart\",\"agent_type\":\"reviewer\"}" | .claude/hooks/review-diff.sh'; }
diff_file() { ls .claude/.state/review-*.diff 2>/dev/null; }
in_diff() { grep -qF -- "$1" "$(diff_file)"; }
not_in_diff() { ! in_diff "$1"; }
one_diff_file() { [ "$(diff_file | wc -l | tr -d ' ')" -eq 1 ]; }
git_state() { git status --porcelain=v1 --untracked-files=all; git ls-files -s; }

hook
check "clean tree: exits 0" status_is 0
check "clean tree: says there is nothing to review" has "no uncommitted changes"
check "clean tree: writes no diff file" test -z "$(diff_file)"

echo "echo changed" >>src/app.sh                 # modified, unstaged
echo "staged" >src/staged.sh && git add src/staged.sh   # new, staged
rm src/gone.sh                                   # deleted
git mv src/old.sh src/renamed.sh                 # renamed
printf '\3\4\5' >src/blob.bin                    # binary change
echo "brand new" >"src/with space.sh"            # untracked, name with a space
echo "secret" >ignored.txt                       # gitignored
before="$(git_state)"
index_before="$(git hash-object .git/index)"

hook
check "changes: exits 0" status_is 0
check "changes: emits SubagentStart additionalContext" has '"hookEventName":"SubagentStart","additionalContext":"review-diff: the real diff'
check "changes: context gives the absolute path" has "$repo/.claude/.state/review-"
check "changes: exactly one diff file" one_diff_file
check "modified file is in the diff" in_diff "+echo changed"
check "staged new file is in the diff" in_diff "+staged"
check "deleted file is in the diff" in_diff "deleted file mode"
check "rename is in the diff" in_diff "rename to src/renamed.sh"
check "binary change is reported" in_diff "Binary files"
check "untracked file is in the diff" in_diff "+brand new"
check "untracked file with a space is in the diff" in_diff "with space.sh"
check "gitignored file is not in the diff" not_in_diff "secret"
check "git status and index entries unchanged" test "$before" = "$(git_state)"
check "index file byte-identical" test "$index_before" = "$(git hash-object .git/index)"

. .claude/hooks/fingerprint.sh
fp="$(fingerprint)"
check "file is named by the verify-on-stop fingerprint" test "$(diff_file)" = ".claude/.state/review-$fp.diff"
check "context quotes the same workspace state" has "workspace state $fp"
check "diff header quotes the same workspace state" in_diff "# workspace state: $fp"

echo "later edit" >>src/app.sh
hook
check "new state: old diff file replaced" one_diff_file
check "new state: new fingerprint" test "$(diff_file)" != ".claude/.state/review-$fp.diff"

finish
