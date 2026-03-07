---
name: send
base_skill: none
model_tier: standard
description: |
  Distribute project artifacts to a configured destination. Delegates building to /build.
  TRIGGER when: user wants to build and distribute artifacts, says "send", "distribute", "package".
  DO NOT TRIGGER: for git push (use gacp) or deployment (use devops).
---

# Send

## Role
Distribute project artifacts using per-project configuration. Delegates build management (staleness detection, version bumping, build execution) to the `/build` skill, then copies artifacts to the destination.

## Identity Announcement
Skip — this skill is action-only, no preamble.

## Trigger
User invokes `/send` or `/send <mode>` (e.g., `/send release`).

## Configuration

Read from `.send.json` in the project root (or fall back to `"send"` key in `.claude/user-config.json`):

**`.send.json` (per-project, primary):**
```json
{
  "build": "./gradlew :app:assemble{mode^}",
  "artifact_glob": "app/build/outputs/apk/{mode}/*.apk",
  "destination": "/path/to/cloud-storage",
  "filename": "{project}-v{version}b{build}-{mode_abbr}.apk",
  "version_file": "app/build.gradle.kts",
  "version_regex": "versionName\\s*=\\s*\"([^\"]+)\"",
  "build_file": "app/build.gradle.kts",
  "build_regex": "versionCode\\s*=\\s*([0-9]+)"
}
```

`destination` also accepts a platform-keyed object so one config works on both Windows and macOS:

```json
{
  "destination": {
    "windows": "C:\\Users\\user\\Dropbox\\my-project",
    "mac": "/Users/user/Library/CloudStorage/Dropbox/my-project",
    "linux": "/home/user/Dropbox/my-project"
  }
}
```

Keys: `"windows"` (MINGW/MSYS/Cygwin), `"mac"` (Darwin), `"linux"`. Missing keys resolve to empty (interactive picker fallback).

**Fallback: `.claude/user-config.json`** (if `.send.json` doesn't exist):

| Field | Required | Description |
|-------|----------|-------------|
| `artifact_glob` | Yes | Glob pattern for build output |
| `destination` | No* | Directory to copy artifacts to — string or platform object (*prompted interactively if missing) |
| `build` | No | Build command to run before copying |
| `filename` | No | Rename pattern for destination file (default: original name) |
| `version_file` | No | File to extract version from |
| `version_regex` | No | Regex with capture group for version string |
| `build_file` | No | File to extract build number from |
| `build_regex` | No | Regex with capture group for build number |

### Placeholders

| Placeholder | Expands to |
|-------------|------------|
| `{mode}` | Build mode (e.g., `debug`, `release`) |
| `{mode^}` | Capitalized mode (e.g., `Debug`, `Release`) |
| `{mode_abbr}` | Abbreviated mode (e.g., `dbg`, `rel`; others -> first 3 chars) |
| `{project}` | Project directory name |
| `{basename}` | Original artifact filename |
| `{version}` | Extracted version string |
| `{build}` | Extracted build number |

## Workflow

### 1. Read Config
- Check for `.send.json` in the project root (primary)
- If missing, fall back to `"send"` block in `.claude/user-config.json`
- If no config exists, fields default to empty (destination picker will create `.send.json`)
- Validate `artifact_glob` exists

### 1b. Resolve Destination
- If `destination` is empty or missing, open a platform-native folder picker:
  - **macOS**: AppleScript folder chooser (`osascript`)
  - **Linux**: `zenity --file-selection --directory` (fallback: `kdialog`)
  - **Windows** (MINGW/MSYS/Cygwin): PowerShell `FolderBrowserDialog`
  - **Fallback**: Interactive `read` prompt if no GUI picker is available
- Selected path is saved to `.send.json` for future invocations
- Validate destination directory exists

### 2. Determine Mode
- Default: `debug`
- User can specify: `/send release`, `/send debug`
- Substitute `{mode}` and `{mode^}` placeholders in artifact glob

### 3. Delegate to /build
- Calls `build.sh` with `--dir`, `--mode`, `--result-file`, and `--dest-glob`
- Build skill handles: framework detection, staleness checks, version bumping, build execution
- Sources result file for `BUILD_VERSION`, `BUILD_NUM`, `BUILD_FRAMEWORK`, `BUILD_ARTIFACT`
- Exit code 2 (up-to-date) is treated as success for distribution purposes

### 4. Find Artifacts
- Expand `artifact_glob` relative to the project root
- Error if no files match

### 5. Prune Destination
- Prune the destination so that only the latest version of the artifact remains BEFORE the new copy.
- Identifies the artifact series by wildcarding version/build numbers.
- Keeps exactly one previous version + the new one being sent (Previous + New policy).

### 6. Copy to Destination
- For each matching artifact:
  - Apply `filename` pattern if set (substitute placeholders)
  - Compute source checksum
  - If destination file exists and checksum matches source, skip copy (no resend)
  - Otherwise copy to `destination`

### 7. Verify Copy
- After each copy, compare destination checksum against source checksum
- If mismatch: log warning, delete partial destination file, retry copy
- Retry up to 3 attempts total; fail with error if all retries exhausted
- Verification is always performed — never silently accept a bad copy

### 8. Report
- Print copied/skipped counts and destination paths
- Exit 0 on success, 1 on error

## Script

The `send.sh` script implements this workflow:

```bash
./send/send.sh --dir ~/src/myproject --mode release
./send/send.sh --dir ~/src/myproject --dry-run
```

Flags: `--dir PATH`, `--mode MODE` (default: debug), `--dry-run`.

## Constraints
- Validate destination exists before building (fail fast)
- Build management (version bumps, staleness, compilation) is delegated to `/build`
- Before copy, prune destination matches (Previous + New policy)
- Never silently overwrite or resend — always report copied/skipped paths
- Verify each copy by comparing source and destination checksums; retry up to 3 times on mismatch before failing
- Uses python3 for JSON parsing (no jq dependency)
- Exit codes: 0 success, 1 error with message
