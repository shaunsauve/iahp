#!/usr/bin/env bash
set -euo pipefail

# Capture a screenshot of the full screen or a specific window/app.
# Usage: screenshot.sh [target]
#   No args or "screen": full screen capture
#   Otherwise: attempt to capture the named window/app

TARGET="${1:-}"
RANDOM_ID=$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c 10; true)
OUTFILE="${TMPDIR:-/tmp}/screenshot-${RANDOM_ID}.png"

# ── Windows (MINGW64 / Git Bash) ──────────────────────────────────────────────
is_windows() {
  [[ "$(uname -s)" == MINGW* || "$(uname -s)" == CYGWIN* || "$(uname -s)" == MSYS* ]]
}

capture_screen_windows() {
  local outfile="$1"
  # Convert /tmp/... path to a Windows path PowerShell can use
  local win_path
  win_path=$(cygpath -w "$outfile" 2>/dev/null || powershell -NoProfile -NonInteractive -Command "Join-Path ([System.IO.Path]::GetTempPath()) 'screenshot-${RANDOM_ID}.png'" 2>/dev/null | tr -d '\r')
  powershell -NoProfile -NonInteractive -Command "
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
\$b = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
\$bmp = New-Object System.Drawing.Bitmap(\$b.Width, \$b.Height)
\$g = [System.Drawing.Graphics]::FromImage(\$bmp)
\$g.CopyFromScreen(\$b.Left, \$b.Top, 0, 0, \$bmp.Size)
\$bmp.Save('$win_path')
\$g.Dispose(); \$bmp.Dispose()
" 2>/dev/null
}

capture_window_windows() {
  local target="$1"
  local outfile="$2"
  local win_path
  win_path=$(cygpath -w "$outfile" 2>/dev/null || powershell -NoProfile -NonInteractive -Command "Join-Path ([System.IO.Path]::GetTempPath()) 'screenshot-${RANDOM_ID}.png'" 2>/dev/null | tr -d '\r')
  # Target resolution:
  #   pid:12345        → match by process ID
  #   name:foo.exe     → match by process name (exe filename)
  #   <anything else>  → match by window title substring
  powershell -NoProfile -NonInteractive -Command "
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public class WinApi {
    [DllImport(\"user32.dll\")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport(\"user32.dll\")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left, Top, Right, Bottom; }
}
'@
\$target = '$target'
\$proc = \$null
if (\$target -match '^pid:(\d+)$') {
    \$proc = Get-Process -Id ([int]\$Matches[1]) -ErrorAction SilentlyContinue
} elseif (\$target -match '^name:(.+)$') {
    \$proc = Get-Process -Name \$Matches[1].TrimEnd('.exe') -ErrorAction SilentlyContinue | Select-Object -First 1
} else {
    \$proc = Get-Process | Where-Object { \$_.MainWindowTitle -like \"*\$target*\" } | Select-Object -First 1
}
if (\$proc -and \$proc.MainWindowHandle -ne [IntPtr]::Zero) {
  [WinApi]::SetForegroundWindow(\$proc.MainWindowHandle) | Out-Null
  Start-Sleep -Milliseconds 300
  \$r = New-Object WinApi+RECT
  [WinApi]::GetWindowRect(\$proc.MainWindowHandle, [ref]\$r) | Out-Null
  \$w = \$r.Right - \$r.Left
  \$h = \$r.Bottom - \$r.Top
  if (\$w -gt 0 -and \$h -gt 0) {
    \$bmp = New-Object System.Drawing.Bitmap(\$w, \$h)
    \$g = [System.Drawing.Graphics]::FromImage(\$bmp)
    \$g.CopyFromScreen(\$r.Left, \$r.Top, 0, 0, [System.Drawing.Size]::new(\$w, \$h))
    \$bmp.Save('$win_path')
    \$g.Dispose(); \$bmp.Dispose()
    exit 0
  }
}
# Fallback: full screen
\$b = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
\$bmp = New-Object System.Drawing.Bitmap(\$b.Width, \$b.Height)
\$g = [System.Drawing.Graphics]::FromImage(\$bmp)
\$g.CopyFromScreen(\$b.Left, \$b.Top, 0, 0, \$bmp.Size)
\$bmp.Save('$win_path')
\$g.Dispose(); \$bmp.Dispose()
" 2>/dev/null
}

# ── macOS ─────────────────────────────────────────────────────────────────────
capture_screen_mac() {
  screencapture -x "$OUTFILE"
}

capture_window_mac() {
  local target="$1"
  local wid
  if wid=$(python3 -c "
import sys
try:
    from Quartz import CGWindowListCopyWindowInfo, kCGWindowListOptionOnScreenOnly, kCGNullWindowID
except ImportError:
    sys.exit(1)
target = sys.argv[1].lower()
for w in CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID):
    owner = (w.get('kCGWindowOwnerName', '') or '').lower()
    name = (w.get('kCGWindowName', '') or '').lower()
    if target in owner or target in name:
        if w.get('kCGWindowLayer', 0) == 0:
            print(w['kCGWindowNumber'])
            sys.exit(0)
sys.exit(1)
" "$target" 2>/dev/null); then
    screencapture -x -l "$wid" "$OUTFILE"
    return 0
  fi
  osascript -e "tell application \"$target\" to activate" 2>/dev/null || true
  sleep 0.5
  capture_screen_mac
}

# ── Linux ─────────────────────────────────────────────────────────────────────
capture_screen_linux() {
  if command -v scrot >/dev/null 2>&1; then
    scrot "$OUTFILE"
  elif command -v gnome-screenshot >/dev/null 2>&1; then
    gnome-screenshot -f "$OUTFILE"
  elif command -v import >/dev/null 2>&1; then
    import -window root "$OUTFILE"
  else
    echo "ERROR: No screenshot tool found" >&2; exit 1
  fi
}

capture_window_linux() {
  local target="$1"
  if command -v xdotool >/dev/null 2>&1 && command -v import >/dev/null 2>&1; then
    local wid
    wid=$(xdotool search --name "$target" 2>/dev/null | head -1)
    if [[ -n "$wid" ]]; then
      import -window "$wid" "$OUTFILE"
      return 0
    fi
  fi
  capture_screen_linux
}

# ── Dispatch ──────────────────────────────────────────────────────────────────
# Ensure /tmp exists on Windows (Git Bash may not create it automatically)
mkdir -p "$(dirname "$OUTFILE")" 2>/dev/null || true

if is_windows; then
  if [[ -z "$TARGET" || "$TARGET" == "screen" ]]; then
    capture_screen_windows "$OUTFILE"
  else
    capture_window_windows "$TARGET" "$OUTFILE"
  fi
elif [[ "$(uname)" == "Darwin" ]]; then
  if [[ -z "$TARGET" || "$TARGET" == "screen" ]]; then
    capture_screen_mac
  else
    capture_window_mac "$TARGET"
  fi
else
  if [[ -z "$TARGET" || "$TARGET" == "screen" ]]; then
    capture_screen_linux
  else
    capture_window_linux "$TARGET"
  fi
fi

if [[ -s "$OUTFILE" ]]; then
  echo "$OUTFILE"
else
  echo "ERROR: Screenshot capture failed or file is empty" >&2
  exit 1
fi
