#!/bin/bash
# gather-metrics.sh — SUMMARY.json metrics & health hook
# Runs as PostToolUse hook on Write/Edit/MultiEdit.
# Standalone: no framework dependencies. Lives in skills infrastructure.
#
# Updates: metrics (co/do/ch), branch, dirty_count, health
# Auto-clears: blocked/warn state + health_msg (if agent is writing, it's not blocked)

set -o pipefail

# --- Hook interface: read stdin, filter tools ---
INPUT=$(cat)
[ -z "$INPUT" ] && exit 0

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name' 2>/dev/null)
case "$TOOL_NAME" in
  Write|Edit|MultiEdit|write|edit|multiedit) ;;
  *) exit 0 ;;
esac

CWD=$(echo "$INPUT" | jq -r '.cwd' 2>/dev/null)
[ -z "$CWD" ] || [ "$CWD" = "null" ] && exit 0

# SUMMARY.json must exist (opt-in: presence = enabled)
SUMMARY="$CWD/SUMMARY.json"
[ -f "$SUMMARY" ] || exit 0

# Require jq
command -v jq &>/dev/null || exit 0

# --- Calculate metrics ---

# co: lines in source files (exclude build artifacts, deps, hidden dirs)
CO=$(find "$CWD" -type f \
  \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \
     -o -name "*.py" -o -name "*.rs" -o -name "*.go" -o -name "*.java" \
     -o -name "*.rb" -o -name "*.php" -o -name "*.cs" -o -name "*.dart" \
     -o -name "*.swift" -o -name "*.kt" -o -name "*.c" -o -name "*.cpp" \
     -o -name "*.h" -o -name "*.hpp" -o -name "*.vue" -o -name "*.svelte" \
     -o -name "*.sh" -o -name "*.css" -o -name "*.scss" -o -name "*.html" \) \
  -not -path "$CWD/.git/*" -not -path "*/node_modules/*" \
  -not -path "*/dist/*" -not -path "*/build/*" -not -path "*/.next/*" \
  -not -path "*/target/*" -not -path "*/__pycache__/*" \
  -not -path "*/vendor/*" -not -path "$CWD/.claude/*" \
  -exec cat {} + 2>/dev/null | wc -l | tr -d ' ')
CO=${CO:-0}

# do: lines in markdown files
DO=$(find "$CWD" -type f -name "*.md" \
  -not -path "$CWD/.git/*" -not -path "*/node_modules/*" \
  -not -path "*/dist/*" -not -path "$CWD/.claude/*" \
  -exec cat {} + 2>/dev/null | wc -l | tr -d ' ')
DO=${DO:-0}

# ch: additions + deletions (unstaged changes)
CH=0
if git -C "$CWD" rev-parse --is-inside-work-tree &>/dev/null; then
  CH=$(git -C "$CWD" diff --numstat 2>/dev/null | \
       awk '$1!="-" && $2!="-" {s+=$1+$2} END{print s+0}')
fi

# branch
BRANCH=$(git -C "$CWD" branch --show-current 2>/dev/null || echo "")
[ -z "$BRANCH" ] && BRANCH="—"

# dirty_count: unstaged + untracked files
DIRTY=$(git -C "$CWD" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
DIRTY=${DIRTY:-0}

# --- Health state machine ---
# blocked/warn → auto-clear to clean (agent is writing, not blocked)
# else → dirty if dirty_count > 0, clean if 0
CURRENT=$(jq -r '.health // "clean"' "$SUMMARY")

if [ "$CURRENT" = "blocked" ] || [ "$CURRENT" = "warn" ]; then
  HEALTH="clean"
elif [ "$DIRTY" -gt 0 ]; then
  HEALTH="dirty"
else
  HEALTH="clean"
fi

# --- Atomic write: tmp + mv ---
TMP=$(mktemp "${SUMMARY}.tmp.XXXXXX")
if jq \
  --argjson co "$CO" \
  --argjson do_lines "$DO" \
  --argjson ch "$CH" \
  --arg branch "$BRANCH" \
  --arg health "$HEALTH" \
  --argjson dirty "$DIRTY" \
  '
    .metrics.co = $co |
    .metrics.do = $do_lines |
    .metrics.ch = $ch |
    .branch = $branch |
    .health = $health |
    .dirty_count = $dirty |
    .health_msg = null
  ' "$SUMMARY" > "$TMP" 2>/dev/null; then
  mv "$TMP" "$SUMMARY"
else
  rm -f "$TMP"
fi

exit 0
