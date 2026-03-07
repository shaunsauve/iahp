#!/usr/bin/env bash
# _shared/lib.sh — Shared utilities for iahp scripts
# Source this file: source "$(dirname "$0")/../_shared/lib.sh"

# --- Cygpath helpers ---
# On MINGW/Git Bash, convert POSIX paths to native Windows paths for Python3.

to_python_path() {
  local p="$1"
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -w "$p"
  else
    echo "$p"
  fi
}

# --- JSON field extraction (python3, no jq) ---
# Usage: get_field CONFIG_PATH FIELD [USE_SEND_KEY]

get_field() {
  local config="$1" field="$2" use_send_key="${3:-false}"
  [[ -z "$config" ]] && return
  local python_config
  python_config="$(to_python_path "$config")"
  python3 - "$python_config" "$field" "$use_send_key" 2>/dev/null <<'PYEOF' || true
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
    if sys.argv[3] == 'true':
        print(data.get('send', {}).get(sys.argv[2], ''), end='')
    else:
        print(data.get(sys.argv[2], ''), end='')
PYEOF
}

# --- Mode substitution ---
# {mode} -> lowercase, {mode^} -> capitalized, {mode_abbr} -> abbreviated
# Usage: sub_mode STRING MODE

sub_mode() {
  local s="$1" mode="$2"
  local mode_cap mode_abbr
  mode_cap="$(echo "${mode:0:1}" | tr '[:lower:]' '[:upper:]')${mode:1}"
  case "$mode" in
    debug)   mode_abbr="dbg" ;;
    release) mode_abbr="rel" ;;
    *)       mode_abbr="${mode:0:3}" ;;
  esac
  s="${s//\{mode\}/$mode}"
  s="${s//\{mode^\}/$mode_cap}"
  s="${s//\{mode_abbr\}/$mode_abbr}"
  echo "$s"
}

# --- File utilities ---

mtime_epoch() {
  local p="$1"
  if stat -f %m "$p" >/dev/null 2>&1; then
    stat -f %m "$p"
  else
    stat -c %Y "$p"
  fi
}

sha256_file() {
  local p="$1"
  if command -v cygpath >/dev/null 2>&1; then
    p="$(cygpath "$p" 2>/dev/null || echo "$p")"
  fi
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$p" | awk '{print $1}'
  else
    sha256sum "$p" | awk '{print $1}'
  fi
}

newest_match() {
  local pattern="$1"
  shopt -s nullglob
  local matches=($pattern)
  shopt -u nullglob
  if [[ ${#matches[@]} -eq 0 ]]; then
    echo ""
    return
  fi
  ls -1t "${matches[@]}" 2>/dev/null | head -n1
}
