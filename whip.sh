#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
  echo "Usage: whip <command> [args...]"
  echo "Example: whip geminix"
  echo "         whip 'cd myproject; claude'"
  exit 1
fi

if ! command -v tmux &>/dev/null; then
  echo "whip requires tmux: brew install tmux"
  exit 1
fi

CMD="$*"
SESSION="whip-$$"
SOCKET="whip"
COLS=$(tput cols)
ROWS=$(tput lines)

# --- Patterns: "match string|keys to send" ---
# Keys: ENTER = bare enter, anything else = type then enter
PATTERNS=(
  "Keep trying|ENTER"
  "[y/N]|y"
  "[Y/n]|y"
)

# Start command in a detached tmux session (separate socket avoids nesting issues)
tmux -L "$SOCKET" new-session -d -s "$SESSION" -x "$COLS" -y "$ROWS" \
  "bash -lic $(printf '%q' "$CMD"); echo '[whip] exited'; sleep 3"

# Background watcher: polls pane content, injects responses
(
  while tmux -L "$SOCKET" has-session -t "$SESSION" 2>/dev/null; do
    content=$(tmux -L "$SOCKET" capture-pane -t "$SESSION" -p 2>/dev/null || true)

    for entry in "${PATTERNS[@]}"; do
      pattern="${entry%%|*}"
      response="${entry##*|}"

      if [[ "$content" == *"$pattern"* ]]; then
        if [[ "$response" == "ENTER" ]]; then
          tmux -L "$SOCKET" send-keys -t "$SESSION" Enter
        else
          tmux -L "$SOCKET" send-keys -t "$SESSION" "$response" Enter
        fi
        sleep 2
        break
      fi
    done

    sleep 0.5
  done
) &
WATCHER=$!

cleanup() {
  kill "$WATCHER" 2>/dev/null
  wait "$WATCHER" 2>/dev/null
  tmux -L "$SOCKET" kill-session -t "$SESSION" 2>/dev/null
  true
}
trap cleanup EXIT

# Attach — user interacts normally
tmux -L "$SOCKET" attach-session -t "$SESSION"
