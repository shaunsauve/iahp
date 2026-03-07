#!/usr/bin/env bash
set -euo pipefail

# build.sh — Build project artifacts with framework detection, staleness checks, and version bumping
#
# Usage: ./build.sh [OPTIONS]
#
# Options:
#   --dir PATH          Project directory (default: current directory)
#   --mode MODE         Build variant (default: "debug")
#   --dry-run           Show what would happen without executing
#   --bump-only         Bump version and exit (no build)
#   --skip-bump         Build without bumping version
#   --result-file PATH  Write build results to this file (sourceable)
#   --dest-glob PATH    Destination glob for bump-warranted check
#   -h, --help          Show this help
#
# Exit codes: 0 = built, 1 = error, 2 = skipped (up-to-date)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../_shared/lib.sh"

PROJECT_DIR="."
MODE="debug"
DRY_RUN=false
BUMP_ONLY=false
SKIP_BUMP=false
RESULT_FILE=""
DEST_GLOB=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --dir) PROJECT_DIR="$2"; shift 2 ;;
    --mode) MODE="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --bump-only) BUMP_ONLY=true; shift ;;
    --skip-bump) SKIP_BUMP=true; shift ;;
    --result-file) RESULT_FILE="$2"; shift 2 ;;
    --dest-glob) DEST_GLOB="$2"; shift 2 ;;
    -h|--help) head -19 "$0" | grep '^#' | sed 's/^# \?//'; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"
PYTHON_PROJECT_DIR="$(to_python_path "$PROJECT_DIR")"

# --- Load config ---

CONFIG=""
USE_SEND_KEY=false
if [[ -f "$PROJECT_DIR/.send.json" ]]; then
  CONFIG="$PROJECT_DIR/.send.json"
elif [[ -f "$PROJECT_DIR/.claude/user-config.json" ]]; then
  CONFIG="$PROJECT_DIR/.claude/user-config.json"
  USE_SEND_KEY=true
fi

BUILD_CMD="$(get_field "$CONFIG" build "$USE_SEND_KEY")"
ARTIFACT_GLOB="$(get_field "$CONFIG" artifact_glob "$USE_SEND_KEY")"
VERSION_FILE="$(get_field "$CONFIG" version_file "$USE_SEND_KEY")"
VERSION_REGEX="$(get_field "$CONFIG" version_regex "$USE_SEND_KEY")"
BUILD_FILE="$(get_field "$CONFIG" build_file "$USE_SEND_KEY")"
BUILD_REGEX="$(get_field "$CONFIG" build_regex "$USE_SEND_KEY")"

BUILD_CMD="$(sub_mode "$BUILD_CMD" "$MODE")"
ARTIFACT_GLOB="$(sub_mode "$ARTIFACT_GLOB" "$MODE")"

# --- Detect framework ---

detect_framework() {
  (cd "$PROJECT_DIR"
  if [[ -f pubspec.yaml ]]; then echo "flutter"
  elif [[ -f Cargo.toml ]]; then echo "rust"
  elif [[ -f go.mod ]]; then echo "go"
  elif [[ -f build.gradle || -f build.gradle.kts || -f settings.gradle || -f settings.gradle.kts ]]; then echo "gradle"
  elif [[ -f package.json ]]; then echo "node"
  elif [[ -f pyproject.toml || -f setup.py ]]; then echo "python"
  elif [[ -f CMakeLists.txt ]]; then echo "cmake"
  elif [[ -f Makefile || -f makefile || -f GNUmakefile ]]; then echo "make"
  else echo "unknown"
  fi)
}

FRAMEWORK="$(detect_framework)"

# --- Extract version ---

VERSION=""
if [[ -n "$VERSION_FILE" && -n "$VERSION_REGEX" ]]; then
  vf="$PROJECT_DIR/$VERSION_FILE"
  if [[ -f "$vf" ]]; then
    python_vf="$(to_python_path "$vf")"
    VERSION="$(SEND_REGEX="$VERSION_REGEX" python3 - "$python_vf" 2>/dev/null <<'PYEOF'
import re, sys, os
regex = os.environ.get('SEND_REGEX', '')
with open(sys.argv[1]) as f:
    m = re.search(regex, f.read())
    if m and m.lastindex: print(m.group(1), end='')
PYEOF
)" || true
  fi
elif [[ "$FRAMEWORK" == "flutter" && -f "$PROJECT_DIR/pubspec.yaml" ]]; then
  VERSION="$(python3 - "$PROJECT_DIR/pubspec.yaml" 2>/dev/null <<'PYEOF'
import re, sys
with open(sys.argv[1]) as f:
    m = re.search(r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+', f.read(), re.M)
    if m: print(m.group(1), end='')
PYEOF
)" || true
fi

# --- Extract build number ---

BUILD_NUM=""
if [[ -n "$BUILD_FILE" && -n "$BUILD_REGEX" ]]; then
  bf="$PROJECT_DIR/$BUILD_FILE"
  if [[ -f "$bf" ]]; then
    python_bf="$(to_python_path "$bf")"
    BUILD_NUM="$(SEND_REGEX="$BUILD_REGEX" python3 - "$python_bf" 2>/dev/null <<'PYEOF'
import re, sys, os
regex = os.environ.get('SEND_REGEX', '')
with open(sys.argv[1]) as f:
    m = re.search(regex, f.read())
    if m and m.lastindex: print(m.group(1), end='')
PYEOF
)" || true
  fi
elif [[ "$FRAMEWORK" == "flutter" && -f "$PROJECT_DIR/pubspec.yaml" ]]; then
  BUILD_NUM="$(python3 - "$PROJECT_DIR/pubspec.yaml" 2>/dev/null <<'PYEOF'
import re, sys
with open(sys.argv[1]) as f:
    m = re.search(r'^version:\s*[0-9]+\.[0-9]+\.[0-9]+\+([0-9]+)', f.read(), re.M)
    if m: print(m.group(1), end='')
PYEOF
)" || true
fi

# --- Staleness detection ---

build_needed() {
  [[ -z "$ARTIFACT_GLOB" ]] && return 0
  local newest_local
  newest_local="$(newest_match "$PROJECT_DIR/$ARTIFACT_GLOB")"
  [[ -z "$newest_local" ]] && return 0
  local python_newest_local
  python_newest_local="$(to_python_path "$newest_local")"
  python3 - "$python_newest_local" "$PYTHON_PROJECT_DIR" "$BUILD_CMD" 2>/dev/null <<'PYEOF'
import os, subprocess, sys

artifact_mtime = os.path.getmtime(sys.argv[1])
project_dir = sys.argv[2]
build_cmd = sys.argv[3] if len(sys.argv) > 3 else ''
os.chdir(project_dir)

def newest_mtime(paths):
    best = 0
    for p in paths:
        if not os.path.exists(p):
            continue
        if os.path.isfile(p):
            best = max(best, os.path.getmtime(p))
        elif os.path.isdir(p):
            for root, _, files in os.walk(p):
                for f in files:
                    try: best = max(best, os.path.getmtime(os.path.join(root, f)))
                    except OSError: pass
    return best

# --- Tier 1: Build-tool native staleness check ---
if build_cmd.startswith('make') and any(
    os.path.isfile(m) for m in ('Makefile', 'makefile', 'GNUmakefile')):
    parts = build_cmd.split()
    targets = [p for p in parts[1:] if not p.startswith('-')]
    try:
        r = subprocess.run(['make', '-q'] + targets, capture_output=True, timeout=15)
        sys.exit(0 if r.returncode != 0 else 1)
    except Exception:
        pass

# --- Tier 2: Framework-specific source paths ---
src = []
if os.path.isfile('Cargo.toml'):
    src = ['src', 'Cargo.toml', 'Cargo.lock', 'build.rs']
elif os.path.isfile('go.mod'):
    src = ['go.mod', 'go.sum']
    for e in os.listdir('.'):
        if e.endswith('.go'): src.append(e)
        elif os.path.isdir(e) and not e.startswith('.') and e not in ('vendor', 'target'):
            src.append(e)
elif os.path.isfile('pubspec.yaml'):
    src = ['lib', 'assets', 'android', 'ios', 'pubspec.yaml', 'pubspec.lock']
elif any(os.path.isfile(f) for f in
         ('build.gradle', 'build.gradle.kts', 'settings.gradle', 'settings.gradle.kts')):
    src = ['src', 'app/src', 'build.gradle', 'build.gradle.kts',
           'app/build.gradle', 'app/build.gradle.kts', 'settings.gradle']
elif os.path.isfile('package.json'):
    src = ['src', 'lib', 'app', 'pages', 'components',
           'package.json', 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml']
elif os.path.isfile('pyproject.toml') or os.path.isfile('setup.py'):
    src = ['src', 'pyproject.toml', 'setup.py', 'setup.cfg']
elif os.path.isfile('CMakeLists.txt'):
    src = ['src', 'include', 'CMakeLists.txt']

if src:
    n = newest_mtime(src)
    if n > 0:
        sys.exit(0 if n > artifact_mtime else 1)

# --- Tier 3: Git-tracked files ---
try:
    r = subprocess.run(['git', 'ls-files', '-z'], capture_output=True, text=True, timeout=10)
    files = [f for f in r.stdout.split('\0') if f and os.path.isfile(f)]
    if files:
        n = max(os.path.getmtime(f) for f in files)
        sys.exit(0 if n > artifact_mtime else 1)
except Exception:
    pass

# --- Tier 4: Unknown project — assume build needed ---
sys.exit(0)
PYEOF
}

# --- Bump warranted check ---

compute_bump_warranted() {
  [[ -z "$ARTIFACT_GLOB" ]] && echo "true" && return
  local newest_local newest_dest
  newest_local="$(newest_match "$PROJECT_DIR/$ARTIFACT_GLOB")"

  if [[ -n "$DEST_GLOB" ]]; then
    newest_dest="$(newest_match "$DEST_GLOB")"
  else
    newest_dest=""
  fi

  # Missing comparable artifacts on either side => conservative bump.
  if [[ -z "$newest_local" || ( -n "$DEST_GLOB" && -z "$newest_dest" ) ]]; then
    echo "true"
    return
  fi

  # Source newer than newest local artifact?
  local newest_local_mtime
  newest_local_mtime="$(mtime_epoch "$newest_local")"

  local source_paths=()
  case "$FRAMEWORK" in
    flutter)
      for p in "$PROJECT_DIR/lib" "$PROJECT_DIR/assets" "$PROJECT_DIR/android" "$PROJECT_DIR/ios" "$PROJECT_DIR/pubspec.yaml"; do
        [[ -e "$p" ]] && source_paths+=("$p")
      done
      ;;
    rust)
      for p in "$PROJECT_DIR/src" "$PROJECT_DIR/Cargo.toml" "$PROJECT_DIR/Cargo.lock"; do
        [[ -e "$p" ]] && source_paths+=("$p")
      done
      ;;
    go)
      for p in "$PROJECT_DIR/go.mod" "$PROJECT_DIR/go.sum"; do
        [[ -e "$p" ]] && source_paths+=("$p")
      done
      ;;
    gradle)
      for p in "$PROJECT_DIR/src" "$PROJECT_DIR/app/src" "$PROJECT_DIR/build.gradle" "$PROJECT_DIR/build.gradle.kts"; do
        [[ -e "$p" ]] && source_paths+=("$p")
      done
      ;;
    *)
      for p in "$PROJECT_DIR/src" "$PROJECT_DIR/lib"; do
        [[ -e "$p" ]] && source_paths+=("$p")
      done
      ;;
  esac

  if [[ ${#source_paths[@]} -gt 0 ]]; then
    local newest_source_mtime
    newest_source_mtime="$(python3 -c "
import os, sys
best = 0
for p in sys.argv[1:]:
    if os.path.isfile(p):
        best = max(best, os.path.getmtime(p))
    elif os.path.isdir(p):
        for root, _, files in os.walk(p):
            for f in files:
                try: best = max(best, os.path.getmtime(os.path.join(root, f)))
                except OSError: pass
print(int(best))
" "${source_paths[@]}" 2>/dev/null)" || true

    if [[ -n "$newest_source_mtime" && "$newest_source_mtime" -gt "$newest_local_mtime" ]]; then
      echo "true"
      return
    fi
  fi

  # Checksum comparison: local vs destination
  if [[ -n "$newest_dest" ]]; then
    local local_sha dest_sha
    local_sha="$(sha256_file "$newest_local")"
    dest_sha="$(sha256_file "$newest_dest")"
    if [[ "$local_sha" != "$dest_sha" ]]; then
      echo "true"
      return
    fi
  fi

  echo "false"
}

# --- Version bumping ---

bump_flutter_version() {
  local pubspec="$PROJECT_DIR/pubspec.yaml"
  if [[ ! -f "$pubspec" ]]; then
    echo "WARN: pubspec.yaml not found, skipping version bump" >&2
    return
  fi

  local bump_out
  bump_out="$(python3 - "$pubspec" <<'PY'
import re, sys
path = sys.argv[1]
text = open(path, encoding='utf-8').read()
m = re.search(r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$', text, re.M)
if not m:
    print("NO_VERSION")
    sys.exit(0)
base = m.group(1)
build = int(m.group(2)) + 1
new_line = f"version: {base}+{build}"
text = re.sub(r'^version:\s*[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+\s*$', new_line, text, count=1, flags=re.M)
open(path, "w", encoding='utf-8').write(text)
print(f"{base}+{build}")
print(build)
PY
)"
  if [[ "$bump_out" == "NO_VERSION" ]]; then
    echo "WARN: Could not parse pubspec version, skipping version bump" >&2
    return
  fi

  local full_version new_build
  full_version="$(echo "$bump_out" | sed -n '1p')"
  new_build="$(echo "$bump_out" | sed -n '2p')"

  # Update module-level variables for result file
  VERSION="${full_version%%+*}"
  BUILD_NUM="$new_build"
  echo "Bumped pubspec version to $full_version"

  # Sync appBuild constant in main.dart
  local main_dart="$PROJECT_DIR/lib/main.dart"
  if [[ -f "$main_dart" ]]; then
    if grep -q "const int appBuild = " "$main_dart" 2>/dev/null; then
      perl -0pi -e "s/const int appBuild = \\d+;/const int appBuild = $new_build;/" "$main_dart"
      echo "Synced appBuild to $new_build in lib/main.dart"
    fi
  fi
}

bump_version() {
  case "$FRAMEWORK" in
    flutter) bump_flutter_version ;;
    *) echo "WARN: No version bump strategy for framework '$FRAMEWORK'" >&2 ;;
  esac
}

maybe_bump_version() {
  if $SKIP_BUMP; then
    echo "Version bump skipped (--skip-bump)"
    return
  fi
  local warranted
  warranted="$(compute_bump_warranted)"
  if [[ "$warranted" == "true" ]]; then
    bump_version
  else
    echo "Version bump not warranted (no source/artifact change detected)"
  fi
}

# --- Write result file ---

write_result() {
  local status="$1"
  [[ -z "$RESULT_FILE" ]] && return
  local artifact=""
  if [[ -n "$ARTIFACT_GLOB" ]]; then
    artifact="$(newest_match "$PROJECT_DIR/$ARTIFACT_GLOB")"
  fi
  cat > "$RESULT_FILE" <<EOF
BUILD_STATUS=$status
BUILD_VERSION=$VERSION
BUILD_NUM=$BUILD_NUM
BUILD_FRAMEWORK=$FRAMEWORK
BUILD_ARTIFACT=$artifact
EOF
}

# --- Dry run ---

if $DRY_RUN; then
  echo "Project:      $(basename "$PROJECT_DIR")"
  echo "Directory:    $PROJECT_DIR"
  echo "Mode:         $MODE"
  echo "Framework:    $FRAMEWORK"
  echo "Artifact:     ${ARTIFACT_GLOB:-(none)}"
  [[ -n "$DEST_GLOB" ]] && echo "Dest glob:    $DEST_GLOB"
  [[ -n "$VERSION" ]] && echo "Version:      $VERSION" || echo "Version:      (none)"
  [[ -n "$BUILD_NUM" ]] && echo "Build number: $BUILD_NUM"
  if [[ -n "$BUILD_CMD" ]]; then
    echo "Build cmd:    $BUILD_CMD"
    if build_needed; then
      echo "Build needed: yes"
      echo "Bump check:   $(compute_bump_warranted)"
    else
      echo "Build needed: no (artifacts up-to-date)"
    fi
  else
    echo "Build:        (none configured)"
  fi
  write_result "dry_run"
  exit 0
fi

# --- Bump only mode ---

if $BUMP_ONLY; then
  maybe_bump_version
  write_result "bumped_only"
  exit 0
fi

# --- Build ---

if [[ -n "$BUILD_CMD" ]]; then
  if build_needed; then
    maybe_bump_version
    # Re-read artifact glob after potential version bump
    ARTIFACT_GLOB="$(sub_mode "$(get_field "$CONFIG" artifact_glob "$USE_SEND_KEY")" "$MODE")"
    echo "Building: $BUILD_CMD"
    (cd "$PROJECT_DIR" && eval "$BUILD_CMD")
    write_result "built"
    exit 0
  else
    echo "Build skipped (artifacts up-to-date)"
    write_result "skipped"
    exit 2
  fi
else
  echo "No build command configured"
  write_result "skipped"
  exit 2
fi
