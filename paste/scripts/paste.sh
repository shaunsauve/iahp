#!/usr/bin/env bash
set -euo pipefail

# Default behavior: auto-detect clipboard content type.
# - If image exists: save to /tmp/image<randomid>.png and print full path.
# - Else if text exists: print text.
# - Else: error.

random_id=$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c 10; true)
image_out="/tmp/image${random_id}.png"

if command -v pngpaste >/dev/null 2>&1; then
  if pngpaste "$image_out" >/dev/null 2>&1 && [[ -s "$image_out" ]]; then
    echo "$image_out"
    exit 0
  fi
  rm -f "$image_out"
fi

text="$(pbpaste || true)"
if [[ -n "$text" ]]; then
  printf "%s" "$text"
  exit 0
fi

echo "ERROR: Clipboard is empty or unsupported" >&2
exit 1
