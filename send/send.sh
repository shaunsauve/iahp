#!/usr/bin/env bash
set -euo pipefail

# send.sh — Distribute project artifacts to a configured destination
#
# Usage: ./send.sh [OPTIONS]
#
# Options:
#   --dir PATH        Project directory (default: current directory)
#   --mode MODE       Build variant (default: "debug")
#   --dry-run         Show what would happen without executing
#   -h, --help        Show this help
#
# Configuration:
#   Primary: <project>/.send.json
#   Fallback: "send" key in <project>/.claude/user-config.json

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../_shared/lib.sh"
BUILD_SKILL="$SCRIPT_DIR/../build/build.sh"

PROJECT_DIR="."
MODE="debug"
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --dir) PROJECT_DIR="$2"; shift 2 ;;
    --mode) MODE="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) head -16 "$0" | grep '^#' | sed 's/^# \?//'; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

# --- Load config ---

CONFIG=""
USE_SEND_KEY=false
if [[ -f "$PROJECT_DIR/.send.json" ]]; then
  CONFIG="$PROJECT_DIR/.send.json"
elif [[ -f "$PROJECT_DIR/.claude/user-config.json" ]]; then
  CONFIG="$PROJECT_DIR/.claude/user-config.json"
  USE_SEND_KEY=true
fi

# --- Platform-native directory picker ---

pick_destination() {
  local picked="" tried_gui=false
  case "$(uname -s)" in
    Darwin)
      tried_gui=true
      picked="$(osascript -e 'POSIX path of (choose folder with prompt "Select send destination folder:")' 2>/dev/null)" || true
      ;;
    Linux)
      if command -v zenity >/dev/null 2>&1; then
        tried_gui=true
        picked="$(zenity --file-selection --directory --title="Select send destination folder" 2>/dev/null)" || true
      elif command -v kdialog >/dev/null 2>&1; then
        tried_gui=true
        picked="$(kdialog --getexistingdirectory "$HOME" --title "Select send destination folder" 2>/dev/null)" || true
      fi
      ;;
    MINGW*|MSYS*|CYGWIN*)
      if command -v powershell.exe >/dev/null 2>&1; then
        tried_gui=true
        picked="$(powershell.exe -NoProfile -Command "
          Add-Type -AssemblyName System.Windows.Forms
          \$d = New-Object System.Windows.Forms.FolderBrowserDialog
          \$d.Description = 'Select send destination folder'
          if (\$d.ShowDialog() -eq 'OK') { \$d.SelectedPath }
        " 2>/dev/null | tr -d '\r')" || true
      fi
      ;;
  esac
  # Fallback: interactive prompt if no GUI picker available or picker failed/cancelled
  if [[ -z "$picked" && -t 0 ]]; then
    if $tried_gui; then
      echo "Folder picker failed or was cancelled — falling back to manual entry." >&2
    else
      echo "No folder picker available on this platform." >&2
    fi
    echo "Enter destination path (or Ctrl-C to cancel):" >&2
    read -r picked
  fi
  echo "$picked"
}

save_destination() {
  local dest="$1"
  local config_file="$PROJECT_DIR/.send.json"
  local python_config_file
  python_config_file="$(to_python_path "$config_file")"
  python3 - "$python_config_file" "$dest" <<'PYEOF'
import json, os, sys
path, dest = sys.argv[1], sys.argv[2]
data = {}
if os.path.isfile(path):
    with open(path) as f:
        data = json.load(f)
data['destination'] = dest
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
PYEOF
}

# --- Platform-aware destination resolver ---

resolve_destination() {
  [[ -z "$CONFIG" ]] && echo "" && return
  local python_config
  python_config="$(to_python_path "$CONFIG")"
  local platform_key
  case "$(uname -s)" in
    Darwin)               platform_key="mac" ;;
    MINGW*|MSYS*|CYGWIN*) platform_key="windows" ;;
    Linux*)               platform_key="linux" ;;
    *)                    platform_key="" ;;
  esac
  python3 - "$python_config" "$platform_key" "$USE_SEND_KEY" 2>/dev/null <<'PYEOF' || true
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
if sys.argv[3] == 'true':
    raw = data.get('send', {}).get('destination', '')
else:
    raw = data.get('destination', '')
if isinstance(raw, dict):
    print(raw.get(sys.argv[2], ''), end='')
else:
    print(raw or '', end='')
PYEOF
}

ARTIFACT_GLOB="$(get_field "$CONFIG" artifact_glob "$USE_SEND_KEY")"
DESTINATION="$(resolve_destination)"
FILENAME_PATTERN="$(get_field "$CONFIG" filename "$USE_SEND_KEY")"
ARTIFACT_GLOB="$(sub_mode "$ARTIFACT_GLOB" "$MODE")"

# --- Validate required fields ---

if [[ -z "$ARTIFACT_GLOB" ]]; then
  echo "ERROR: 'artifact_glob' required in send config" >&2
  exit 1
fi

if [[ -z "$DESTINATION" ]]; then
  DESTINATION="$(pick_destination)"
  if [[ -z "$DESTINATION" ]]; then
    echo "ERROR: 'destination' required — configure in .send.json or select interactively" >&2
    exit 1
  fi
  DESTINATION="${DESTINATION%/}"
  save_destination "$DESTINATION"
  CONFIG="$PROJECT_DIR/.send.json"
  USE_SEND_KEY=false
  echo "Saved destination to .send.json: $DESTINATION"
fi

if [[ ! -d "$DESTINATION" ]]; then
  echo "ERROR: Destination not found: $DESTINATION" >&2
  exit 1
fi

PROJECT_NAME="$(basename "$PROJECT_DIR")"

# --- Compute search glob for pruning and version check ---

if [[ -n "$FILENAME_PATTERN" ]]; then
  SEARCH_GLOB="$FILENAME_PATTERN"
  SEARCH_GLOB="${SEARCH_GLOB//{project}/$PROJECT_NAME}"
  SEARCH_GLOB="${SEARCH_GLOB//{version}/*}"
  SEARCH_GLOB="${SEARCH_GLOB//{build}/*}"
  SEARCH_GLOB="$(sub_mode "$SEARCH_GLOB" "$MODE")"
  SEARCH_GLOB="${SEARCH_GLOB//{basename}/*}"
else
  SEARCH_GLOB="$(basename "$ARTIFACT_GLOB" | sed -e 's/{version}/*/g' | sed -E 's/v?[0-9]+(\.[0-9]+)*(\+[0-9]+)?(b[0-9]+)?/*/g')"
fi

# --- Delegate to /build skill ---

if [[ ! -x "$BUILD_SKILL" ]]; then
  echo "ERROR: Build skill not found: $BUILD_SKILL" >&2
  exit 1
fi

result_file="${TMPDIR:-/tmp}/build_result_$$"
build_args=(--dir "$PROJECT_DIR" --mode "$MODE" --result-file "$result_file" --dest-glob "$DESTINATION/$SEARCH_GLOB")
$DRY_RUN && build_args+=(--dry-run)

"$BUILD_SKILL" "${build_args[@]}" || {
  build_exit=$?
  # Exit 2 = skipped (up-to-date), which is fine for send
  if [[ $build_exit -ne 2 ]]; then
    rm -f "$result_file"
    exit $build_exit
  fi
}

# Source result file for version/build info
BUILD_VERSION="" BUILD_NUM="" BUILD_STATUS="" BUILD_FRAMEWORK="" BUILD_ARTIFACT=""
if [[ -f "$result_file" ]]; then
  source "$result_file"
  rm -f "$result_file"
fi

VERSION="${BUILD_VERSION:-}"
BUILD_NUM_VAL="${BUILD_NUM:-}"

# --- Dry run (send-specific info) ---

if $DRY_RUN; then
  echo "---"
  echo "Destination:  $DESTINATION"
  [[ -n "$FILENAME_PATTERN" ]] && echo "Filename:     $FILENAME_PATTERN"
  echo "Search glob:  $SEARCH_GLOB"
  exit 0
fi

# Re-read artifact glob after potential version bump
ARTIFACT_GLOB="$(sub_mode "$(get_field "$CONFIG" artifact_glob "$USE_SEND_KEY")" "$MODE")"

# --- Find artifacts ---

shopt -s nullglob
artifacts=("$PROJECT_DIR"/$ARTIFACT_GLOB)
shopt -u nullglob

if [[ ${#artifacts[@]} -eq 0 ]]; then
  echo "ERROR: No artifacts matching: $ARTIFACT_GLOB" >&2
  exit 1
fi

# --- Prune destination artifacts ---
# Keeps exactly one previous version + the new one being sent (Previous + New policy).

shopt -s nullglob
dest_matches=("$DESTINATION"/$SEARCH_GLOB)
shopt -u nullglob

if [[ ${#dest_matches[@]} -gt 1 ]]; then
  sorted_dest_matches="$(ls -1t "${dest_matches[@]}" 2>/dev/null || true)"
  keep_first=true
  while IFS= read -r old; do
    [[ -n "$old" ]] || continue
    if $keep_first; then
      keep_first=false
      continue
    fi
    rm -f "$old"
    echo "Removed old artifact: $old"
  done <<< "$sorted_dest_matches"
fi

# --- Copy with post-copy verification and retry ---

COPY_RETRIES=3
copied=0
skipped=0
for src in "${artifacts[@]}"; do
  [[ -f "$src" ]] || continue
  basename_src="$(basename "$src")"

  if [[ -n "$FILENAME_PATTERN" ]]; then
    dest_name="$FILENAME_PATTERN"
    dest_name="${dest_name//\{project\}/$PROJECT_NAME}"
    dest_name="${dest_name//\{basename\}/$basename_src}"
    dest_name="${dest_name//\{version\}/$VERSION}"
    dest_name="${dest_name//\{build\}/$BUILD_NUM_VAL}"
    dest_name="$(sub_mode "$dest_name" "$MODE")"
  else
    dest_name="$basename_src"
  fi

  dest="$DESTINATION/$dest_name"
  src_sha="$(sha256_file "$src")"

  if [[ -f "$dest" ]]; then
    dest_sha="$(sha256_file "$dest")"
    if [[ "$src_sha" == "$dest_sha" ]]; then
      echo "Skipped (already up-to-date): $dest"
      skipped=$((skipped + 1))
      continue
    fi
  fi

  copy_ok=false
  for attempt in $(seq 1 $COPY_RETRIES); do
    cp "$src" "$dest"
    verify_sha="$(sha256_file "$dest")"
    if [[ "$verify_sha" == "$src_sha" ]]; then
      copy_ok=true
      break
    fi
    echo "WARN: Copy verification failed (attempt $attempt/$COPY_RETRIES): checksum mismatch" >&2
    rm -f "$dest"
  done
  if ! $copy_ok; then
    echo "ERROR: Copy failed after $COPY_RETRIES attempts (checksum mismatch): $dest" >&2
    exit 1
  fi

  echo "$dest"
  copied=$((copied + 1))
done

if [[ $copied -eq 0 && $skipped -eq 0 ]]; then
  echo "ERROR: No files copied" >&2
  exit 1
fi

echo "Sent $copied artifact(s)"
if [[ $skipped -gt 0 ]]; then
  echo "Skipped $skipped artifact(s) already present"
fi
