#!/usr/bin/env bash
# run-skill-evals — run one skill eval case the way skill-creator lays out results.
#
# Usage: run-skill-evals.sh <skill> <case> <config> <workspace-iteration-dir> [<old-ref>]
#   config: with_skill (current SKILL.md) or old_skill (SKILL.md from <old-ref>).
# Creates <iteration>/<case>/<config>/{project,outputs,timing.json}. Real, billed
# `claude -p` run with edits auto-accepted, confined to the throwaway project copy.
set -uo pipefail

skill="$1" case="$2" config="$3" iter="$4" old_ref="${5:-}"
root="$(cd "$(dirname "$0")/../.." && pwd)"
case_dir="$root/.claude/skills/$skill/evals/$case"
run="$iter/$case/$config"
rm -rf "$run"; mkdir -p "$run/project" "$run/outputs"
cd "$run/project" || exit 1
"$case_dir/place-files.sh" >/dev/null || { echo "scaffold failed" >"$run/outputs/error.txt"; exit 1; }
if [ "$config" = old_skill ]; then
  git -C "$root" show "$old_ref:.claude/skills/$skill/SKILL.md" >".claude/skills/$skill/SKILL.md"
  git commit -qm "eval: old $skill skill" -- ".claude/skills/$skill/SKILL.md"
fi
head_before="$(git rev-parse HEAD)"
prompt="$(awk 'BEGIN{n=0} /^---$/ && n<2 {n++; next} n>=2' "$case_dir/prompt.md")"

start=$(date +%s%3N)
timeout 1200 claude -p --permission-mode acceptEdits \
  --allowedTools Bash Read Edit Write Skill Agent Glob Grep \
  --output-format stream-json --verbose -- "$prompt" >"$run/outputs/transcript.jsonl" 2>"$run/outputs/stderr.txt"
end=$(date +%s%3N)

python3 -I - "$run" "$((end - start))" <<'PY'
import json, sys, pathlib
run, ms = pathlib.Path(sys.argv[1]), int(sys.argv[2])
result, tokens = "", 0
for line in (run / "outputs/transcript.jsonl").read_text().splitlines():
    try: ev = json.loads(line)
    except ValueError: continue
    if ev.get("type") == "result":
        result = ev.get("result", "")
        u = ev.get("usage", {})
        tokens = sum(u.get(k, 0) for k in ("input_tokens", "output_tokens", "cache_creation_input_tokens", "cache_read_input_tokens"))
(run / "outputs/final-message.md").write_text(result)
(run / "timing.json").write_text(json.dumps({"total_tokens": tokens, "duration_ms": ms, "total_duration_seconds": round(ms / 1000, 1)}, indent=2))
PY

{
  echo "## branch"; git branch --show-current
  echo "## tags"; git tag
  echo "## log since start"; git log --oneline "$head_before"..HEAD 2>/dev/null; git log --oneline --all -8
  echo "## status"; git status --porcelain=v1 --untracked-files=all
  echo "## acceptance evidence"; find .claude/.state/acceptance -type f 2>/dev/null || echo "(none)"
} >"$run/outputs/repo-state.txt"
git diff "$head_before" >"$run/outputs/diff-vs-start.patch" 2>/dev/null
git ls-files -o --exclude-standard | while read -r f; do echo "### $f"; cat "$f"; done >"$run/outputs/new-files.txt" 2>/dev/null
find specs -path '*/directions/*.html' -exec cp --parents {} "$run/outputs/" \; 2>/dev/null
echo "complete" >"$run/outputs/.complete"
