#!/usr/bin/env bash
set -euo pipefail

# gather-metrics.sh — Update metrics/health/branch in SUMMARY.json
# Fast, no LLM. Called by summarize.sh for bootstrap.
# Uses same counting methodology as baseline/hooks/gather-metrics.sh.
#
# Usage: bash gather-metrics.sh [--dir PROJECT_DIR]

PROJECT_DIR="."
while [[ $# -gt 0 ]]; do
  case $1 in
    --dir) PROJECT_DIR="$2"; shift 2 ;;
    *) shift ;;
  esac
done

PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
SUMMARY="$PROJECT_DIR/SUMMARY.json"

# --- Metrics ---

# co: lines in source files (same extensions as baseline hook)
co=$(find "$PROJECT_DIR" -type f \
  \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \
     -o -name "*.py" -o -name "*.rs" -o -name "*.go" -o -name "*.java" \
     -o -name "*.rb" -o -name "*.php" -o -name "*.cs" -o -name "*.dart" \
     -o -name "*.swift" -o -name "*.kt" -o -name "*.c" -o -name "*.cpp" \
     -o -name "*.h" -o -name "*.hpp" -o -name "*.vue" -o -name "*.svelte" \) \
  -not -path "$PROJECT_DIR/.git/*" -not -path "*/node_modules/*" \
  -not -path "*/dist/*" -not -path "*/build/*" -not -path "*/.next/*" \
  -not -path "*/target/*" -not -path "*/__pycache__/*" \
  -not -path "*/vendor/*" -not -path "$PROJECT_DIR/.claude/*" \
  -exec cat {} + 2>/dev/null | wc -l | tr -d ' ')
co=${co:-0}

# do: lines in markdown files (same scope as baseline hook)
do_val=$(find "$PROJECT_DIR" -type f -name "*.md" \
  -not -path "$PROJECT_DIR/.git/*" -not -path "*/node_modules/*" \
  -not -path "*/dist/*" -not -path "$PROJECT_DIR/.claude/*" \
  -exec cat {} + 2>/dev/null | wc -l | tr -d ' ')
do_val=${do_val:-0}

# ch: additions + deletions (git diff)
ch=0
if git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
  ch=$(git -C "$PROJECT_DIR" diff --numstat 2>/dev/null | \
       awk '$1!="-" && $2!="-" {s+=$1+$2} END{print s+0}')
fi

# --- Git state ---

branch=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || true)
branch=${branch:-—}

dirty_count=$(git -C "$PROJECT_DIR" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
dirty_count=${dirty_count:-0}
if [[ $dirty_count -eq 0 ]]; then health="clean"; else health="dirty"; fi

# --- Update SUMMARY.json (merge, preserve text fields) ---

python3 -c "
import json, sys
co, do, ch = int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3])
branch, health, dirty = sys.argv[4], sys.argv[5], int(sys.argv[6])
path = sys.argv[7]
try:
    d = json.load(open(path))
except Exception:
    d = {'prj': None, 'skill': None, 'milestone': None,
         'tgt': None, 'did': None, 'now': None}
d.update({
    'branch': branch, 'health': health, 'dirty_count': dirty,
    'metrics': {'co': co, 'do': do, 'ch': ch}
})
d.pop('health_msg', None)
with open(path, 'w') as f:
    json.dump(d, f, indent=2)
    f.write('\n')
" "$co" "$do_val" "$ch" "$branch" "$health" "$dirty_count" "$SUMMARY"
