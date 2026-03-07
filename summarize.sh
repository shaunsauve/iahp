#!/usr/bin/env bash
set -euo pipefail

# summarize.sh — Project HUD: renders SUMMARY.json with color, watches for updates
#
# Usage: ./summarize.sh [--dir PROJECT_DIR] [--clear]
#
# Field updates are handled by the summarize subagent (not this script).
# This script only watches SUMMARY.json and renders the display.
# --clear removes SUMMARY.json, prev state, and the PostToolUse hook (zero overhead).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="."
DO_CLEAR=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --dir) PROJECT_DIR="$2"; shift 2 ;;
    --clear) DO_CLEAR=true; shift ;;
    -h|--help) sed -n '2,8s/^# \?//p' "$0"; exit 0 ;;
    *) echo "Unknown: $1" >&2; exit 1 ;;
  esac
done

PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
SUMMARY="$PROJECT_DIR/SUMMARY.json"
PREV_FILE="$PROJECT_DIR/.summarize-prev.json"

# --- Clear mode: remove all summarize artifacts and hook ---
if $DO_CLEAR; then
  rm -f "$SUMMARY" "$PREV_FILE"
  echo "Removed SUMMARY.json and prev state."

  settings_file="$PROJECT_DIR/.claude/settings.local.json"
  if [[ -f "$settings_file" ]] && grep -q "gather-metrics" "$settings_file" 2>/dev/null; then
    python3 -c "
import json, sys
path = sys.argv[1]
d = json.load(open(path))
hooks = d.get('hooks', {})
post = hooks.get('PostToolUse', [])
post = [e for e in post if 'gather-metrics' not in json.dumps(e)]
if post:
    hooks['PostToolUse'] = post
else:
    hooks.pop('PostToolUse', None)
if not hooks:
    d.pop('hooks', None)
with open(path, 'w') as f:
    json.dump(d, f, indent=2)
    f.write('\n')
" "$settings_file"
    echo "Removed PostToolUse hook from $settings_file"
  fi

  echo "Summarize fully deactivated (zero overhead)."
  exit 0
fi

# Resolve the iahp directory relative to the project
# SCRIPT_DIR is the iahp root (where summarize.sh lives)
# SKILLS_REL is the relative path from PROJECT_DIR to iahp
SKILLS_REL=$(python3 -c "import os, sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))" "$SCRIPT_DIR" "$PROJECT_DIR" 2>/dev/null || echo "iahp")

# Auto-install PostToolUse hook if not configured
install_hook() {
  local settings_dir="$PROJECT_DIR/.claude"
  local settings_file="$settings_dir/settings.local.json"
  local hook_cmd="bash $SKILLS_REL/baseline/hooks/gather-metrics.sh"

  # Skip if hook already present
  if [[ -f "$settings_file" ]] && grep -q "gather-metrics" "$settings_file" 2>/dev/null; then
    return 0
  fi

  mkdir -p "$settings_dir"

  if [[ -f "$settings_file" ]]; then
    # Merge hook into existing settings
    python3 -c "
import json, sys
path = sys.argv[1]
cmd = sys.argv[2]
d = json.load(open(path))
hook_entry = {'matcher': 'Write|Edit', 'hooks': [{'type': 'command', 'command': cmd, 'timeout': 10}]}
hooks = d.setdefault('hooks', {})
post = hooks.setdefault('PostToolUse', [])
post.append(hook_entry)
with open(path, 'w') as f:
    json.dump(d, f, indent=2)
    f.write('\n')
" "$settings_file" "$hook_cmd"
  else
    # Create new settings file with hook
    python3 -c "
import json, sys
cmd = sys.argv[2]
d = {'hooks': {'PostToolUse': [{'matcher': 'Write|Edit', 'hooks': [{'type': 'command', 'command': cmd, 'timeout': 10}]}]}}
with open(sys.argv[1], 'w') as f:
    json.dump(d, f, indent=2)
    f.write('\n')
" "$settings_file" "$hook_cmd"
  fi
  echo "Installed PostToolUse hook → $settings_file"
}
install_hook

# Add SUMMARY.json to .gitignore if not already present
if [[ -f "$PROJECT_DIR/.gitignore" ]] && ! grep -q 'SUMMARY.json' "$PROJECT_DIR/.gitignore" 2>/dev/null; then
  printf '\n# Summarize HUD\nSUMMARY.json\n.summarize-prev.json\n' >> "$PROJECT_DIR/.gitignore"
  echo "Added SUMMARY.json to .gitignore"
fi

# First run: create skeleton SUMMARY.json with metrics, then invoke subagent to bootstrap text fields
bootstrap() {
  local dir="$1" summary="$2"

  # 1. Gather metrics (fast, no LLM)
  bash "$SCRIPT_DIR/summarize/gather-metrics.sh" --dir "$dir"

  # 2. Create skeleton with null text fields if gather-metrics didn't create it
  [[ -f "$summary" ]] || python3 -c "
import json, sys
d = {'prj': None, 'skill': None, 'milestone': None, 'tgt': None, 'did': None, 'now': None,
     'branch': None, 'health': 'clean', 'health_msg': None, 'dirty_count': 0,
     'metrics': {'co': 0, 'do': 0, 'ch': 0}}
with open(sys.argv[1], 'w') as f:
    json.dump(d, f, indent=2); f.write('\n')
" "$summary"

  # 3. Fire subagent in background to populate text fields — display will pick up the change
  # WHY: Prompt piped via stdin because --allowedTools is variadic (<tools...>)
  # and consumes all subsequent positional args, including the prompt.
  if command -v claude &>/dev/null; then
    ( unset CLAUDECODE
      cd "$dir"
      claude -p --model claude-haiku-4-5-20251001 --output-format text \
        --allowedTools "Read,Write,Edit,Bash(git log*)" \
        <<EOF
You are the summarize subagent. SUMMARY.json exists at $summary with null text fields. Bootstrap: read README.md (head 50), docs/PROJECT.md (head 50), docs/TODO.md (head 50), git log --oneline -5. Populate prj, milestone, tgt, did, now in SUMMARY.json. Wrap 1-3 key phrases per field in {curly braces}. Under 90 chars each. Use null for unknowns. Do NOT read ARCHITECTURE.md, REQUIREMENTS.md, VISION.md, or source code.
EOF
    ) &
    echo "Bootstrapping text fields in background..."
  else
    echo "Created SUMMARY.json skeleton. Install claude CLI or load a skill to bootstrap text fields."
  fi
}

# Bootstrap if SUMMARY.json missing OR text fields are unpopulated (stale from failed bootstrap)
needs_bootstrap() {
  [[ ! -f "$1" ]] && return 0
  python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
prj = d.get('prj')
sys.exit(0 if not prj or prj == '\u2014' or prj == 'null' else 1)
" "$1" 2>/dev/null
}
needs_bootstrap "$SUMMARY" && bootstrap "$PROJECT_DIR" "$SUMMARY"

# Establish baseline for change detection (no highlights on first display)
cp "$SUMMARY" "$PREV_FILE" 2>/dev/null || true

# Clear screen, hide cursor; restore on exit
clear
tput civis 2>/dev/null || true
trap 'tput cnorm 2>/dev/null; rm -f "$PREV_FILE"' EXIT INT TERM

# Render SUMMARY.json as colored 4-line HUD
# All formatting, truncation, coloring, and change highlighting handled in Python
term_width() {
  local w
  w=$(stty size </dev/tty 2>/dev/null | awk '{print $2}')
  [[ -n "$w" && "$w" -gt 0 ]] 2>/dev/null && { echo "$w"; return; }
  w=$(tput cols </dev/tty 2>/dev/null)
  [[ -n "$w" && "$w" -gt 0 ]] 2>/dev/null && { echo "$w"; return; }
  w=${COLUMNS:-0}
  [[ "$w" -gt 0 ]] 2>/dev/null && { echo "$w"; return; }
  w=$(tput cols 2>/dev/null)
  [[ -n "$w" && "$w" -gt 0 ]] 2>/dev/null && { echo "$w"; return; }
  echo 100
} 2>/dev/null

render() {
  local tw summary prev intensity
  summary="$1"
  prev="${2:-none}"
  intensity="${3:-0}"
  tw=$(term_width)
  python3 - "$summary" "$tw" "$prev" "$intensity" << 'PYRENDER'
import json, sys, re

DASH = '\u2014'
ELLIP = '\u2026'
SEP = '\u00b7'
ESC = '\033'
R = ESC + '[0m'
CLR_EOL = ESC + '[K'
CLR_BELOW = ESC + '[J'

def vlen(s):
    return len(re.sub(r'[{}]', '', s))

def truncate(s, max_w):
    if vlen(s) <= max_w:
        return s
    out, n, inside = [], 0, False
    for ch in s:
        if ch == '{':
            inside = True; out.append(ch)
        elif ch == '}':
            inside = False; out.append(ch)
        else:
            if n >= max_w - 1:
                break
            out.append(ch); n += 1
    if inside:
        out.append('}')
    return ''.join(out) + ELLIP

def accent(text, color):
    return re.sub(r'\{([^}]+)\}',
                  lambda m: '%s[38;5;%dm%s%s[0m' % (ESC, color, m.group(1), ESC), text)

def fmt(v):
    if v >= 1000:
        h = (v * 10 + 500) // 1000
        w, d = divmod(h, 10)
        return '%dk' % w if d == 0 else '%d.%dk' % (w, d)
    return str(v)

def c(n):
    return '%s[38;5;%dm' % (ESC, n)

def bgc(n):
    return '%s[48;5;%dm' % (ESC, n)

# Highlight helpers
BG_LEVELS = {3: 136, 2: 94, 1: 58}

def apply_line_bg(line, bg_col):
    """Full-line bg (blocked state). Pads with spaces to fill terminal width."""
    bg = bgc(bg_col)
    line = line.replace(R, R + bg)
    vis = len(re.sub(r'\033\[[0-9;]*[A-Za-z]', '', line))
    pad = max(0, tw - vis)
    return bg + line + ' ' * pad + R

# --- Args ---
d = json.load(open(sys.argv[1]))
tw = int(sys.argv[2])
prev_path = sys.argv[3] if len(sys.argv) > 3 else 'none'
intensity = int(sys.argv[4]) if len(sys.argv) > 4 else 0
m = d.get('metrics', {})

# --- Load previous state ---
prev, prev_m = {}, {}
if prev_path != 'none':
    try:
        prev = json.load(open(prev_path))
        prev_m = prev.get('metrics', {})
    except:
        pass

# --- Change detection ---
def fchg(*keys):
    return any(d.get(k) != prev.get(k) for k in keys)

def mchg(k):
    return m.get(k) != prev_m.get(k)

hl_active = intensity > 0 and intensity in BG_LEVELS
_bg = BG_LEVELS.get(intensity)

def hl(text, changed):
    """Wrap a single segment in fade-bg if changed. Localized highlight."""
    if not changed or not hl_active:
        return text
    bg = bgc(_bg)
    return bg + text.replace(R, R + bg) + R

# --- Metrics (per-value highlights) ---
co_s = fmt(m.get('co', 0))
do_s = fmt(m.get('do', 0))
ch_s = fmt(m.get('ch', 0))
mp = '[co:%s/do:%s/ch:%s]' % (co_s, do_s, ch_s)

co_v = hl(c(110) + co_s + R, mchg('co'))
do_v = hl(c(176) + do_s + R, mchg('do'))
ch_v = hl(c(114) + ch_s + R, mchg('ch'))
mc = '[%sco%s:%s%s/%sdo%s:%s%s/%sch%s:%s]' % (
    c(67), R, co_v,
    c(239), c(133), R, do_v,
    c(239), c(71), R, ch_v)
mcol = tw - len(mp) + 1

# --- Health ---
health = d.get('health', 'unknown')
health_msg = d.get('health_msg')
dirty = d.get('dirty_count', 0)
if health == 'clean':
    hs = '{clean}'
elif health == 'dirty':
    hs = '{DIRTY}: %d unstaged' % dirty
elif health == 'blocked':
    hs = '{BLOCKED}: %s' % (health_msg or 'waiting for input')
elif health == 'warn':
    hs = '{WARN}: %s' % (health_msg or 'issue')
else:
    hs = DASH

# --- Build PRJ line with per-field highlights ---
s = ' %s ' % SEP
prj_fields = [
    (d.get('prj') or DASH, fchg('prj')),
    (d.get('branch') or DASH, fchg('branch')),
    (d.get('skill') or DASH, fchg('skill')),
    (d.get('milestone') or DASH, fchg('milestone')),
]
max_prj_w = tw - len(mp) - 6
raw_prj = s.join(v for v, _ in prj_fields)
if vlen(raw_prj) <= max_prj_w:
    prj_content = s.join(hl(accent(v, 110), chg) for v, chg in prj_fields)
else:
    raw_prj = truncate(raw_prj, max_prj_w)
    any_chg = any(chg for _, chg in prj_fields)
    prj_content = hl(accent(raw_prj, 110), any_chg)

# --- Build TGT/DID with content-level highlight (not prefix) ---
tgt_raw = truncate(d.get('tgt') or DASH, tw - 5)
did_raw = truncate(d.get('did') or DASH, tw - 5)
tgt_content = hl(accent(tgt_raw, 176), fchg('tgt'))
did_content = hl(accent(did_raw, 114), fchg('did'))

# --- Build NOW with split highlights: task text vs health ---
now_raw = d.get('now') or DASH
health_chg = fchg('health', 'dirty_count') or d.get('health_msg') != prev.get('health_msg')
now_combined = '%s %s %s' % (now_raw, SEP, hs)
now_combined = truncate(now_combined, tw - 5)
sep_pos = now_combined.rfind(SEP)
if sep_pos > 0:
    now_task = now_combined[:sep_pos].rstrip()
    now_health = now_combined[sep_pos + len(SEP):].lstrip()
    now_content = '%s %s %s' % (
        hl(accent(now_task, 255), fchg('now')),
        SEP,
        hl(accent(now_health, 255), health_chg))
else:
    now_content = hl(accent(now_combined, 255), fchg('now') or health_chg)

# --- Format lines ---
l2 = '%sTGT%s  %s' % (c(133), R, tgt_content)
l3 = '%sDID%s  %s' % (c(71), R, did_content)
l4 = '%sNOW%s  %s' % (c(249), R, now_content)

# --- Apply blocked bg or CLR_EOL ---
if health == 'blocked':
    # l1: space-pad gap instead of cursor-move (cursor-move skips bg)
    gap = max(1, mcol - vlen(raw_prj) - 6)
    l1 = '%sPRJ%s  %s%s%s' % (c(67), R, prj_content, ' ' * gap, mc)
    l1 = apply_line_bg(l1, 52)
    l2 = apply_line_bg(l2, 52)
    l3 = apply_line_bg(l3, 52)
    l4 = apply_line_bg(l4, 52)
else:
    l1 = '%sPRJ%s  %s%s[%dG%s' % (c(67), R, prj_content, ESC, mcol, mc)
    l1 += CLR_EOL
    l2 += CLR_EOL
    l3 += CLR_EOL
    l4 += CLR_EOL

# --- Output (single write — no stray newlines) ---
sys.stdout.write(ESC + '[H' + l1 + '\n' + l2 + '\n' + l3 + '\n' + CLR_BELOW + l4)
sys.stdout.flush()
PYRENDER
}

# Animated fade: highlight changes then gradually return to normal
render_with_fade() {
  local summary="$1"
  render "$summary" "$PREV_FILE" 3
  sleep 0.4
  render "$summary" "$PREV_FILE" 2
  sleep 0.4
  render "$summary" "$PREV_FILE" 1
  sleep 0.3
  render "$summary" "$PREV_FILE" 0
  cp "$summary" "$PREV_FILE" 2>/dev/null || true
}

# Initial render (no fade — establish baseline)
render "$SUMMARY" "none" 0

# Watch for changes — silent, re-renders with fade animation
if command -v fswatch &>/dev/null; then
  fswatch --batch-marker=EOF -o "$SUMMARY" 2>/dev/null | while read -r line; do
    [[ "$line" == "EOF" ]] && render_with_fade "$SUMMARY"
  done
elif command -v inotifywait &>/dev/null; then
  while true; do
    inotifywait -qq -e modify "$SUMMARY" 2>/dev/null || sleep 2
    sleep 0.2
    render_with_fade "$SUMMARY"
  done
else
  last_mtime=0
  while true; do
    sleep 1
    if [[ -f "$SUMMARY" ]]; then
      current_mtime=$(stat -f%m "$SUMMARY" 2>/dev/null || stat -c%Y "$SUMMARY" 2>/dev/null || echo 0)
      if [[ $current_mtime -gt $last_mtime ]]; then
        last_mtime=$current_mtime
        render_with_fade "$SUMMARY"
      fi
    fi
  done
fi
