---
name: build
base_skill: none
model_tier: standard
description: |
  Build project artifacts with framework detection, staleness checks, and version bumping.
  TRIGGER when: user wants to build, compile, or bump version; says "build", "compile", "bump version".
  DO NOT TRIGGER: for distribution (use send) or deployment (use devops).
---

# Build

## Role
Build project artifacts with automatic framework detection, tiered staleness checks, and version bumping.

## Identity Announcement
Skip — this skill is action-only, no preamble.

## Trigger
User invokes `/build` or `/build <mode>` (e.g., `/build release`).

## Configuration

Reads build-related fields from `.send.json` (primary) or `"send"` key in `.claude/user-config.json` (fallback):

| Field | Required | Description |
|-------|----------|-------------|
| `build` | No | Build command (`{mode}`, `{mode^}`, `{mode_abbr}` placeholders supported) |
| `artifact_glob` | No | Glob pattern for build output |
| `version_file` | No | File to extract version from |
| `version_regex` | No | Regex with capture group for version string |
| `build_file` | No | File to extract build number from |
| `build_regex` | No | Regex with capture group for build number |

For Flutter projects without explicit config, version and build number are auto-extracted from `pubspec.yaml`.

## Framework Detection
Auto-detects: Flutter, Gradle, Rust, Go, Node, Python, CMake, Make.

## Staleness Detection (4-tier)
1. **Native build tools**: `make -q` (POSIX question mode)
2. **Framework source paths**: Framework-specific directories vs artifact mtime
3. **Git fallback**: `git ls-files` mtime comparison
4. **Conservative fallback**: Assumes build needed

## Version Bumping
- Checks if bump is warranted (source changes, artifact checksum differences)
- Flutter: bumps `version: x.y.z+N` in pubspec.yaml, syncs `appBuild` constant in `lib/main.dart`

## Script

```bash
# Standalone build
./build/build.sh --dir ~/src/myproject --mode release

# Dry run
./build/build.sh --dir ~/src/myproject --mode release --dry-run

# Build without version bump
./build/build.sh --dir ~/src/myproject --mode release --skip-bump

# Bump version only (no build)
./build/build.sh --dir ~/src/myproject --mode release --bump-only
```

Flags: `--dir PATH`, `--mode MODE`, `--dry-run`, `--bump-only`, `--skip-bump`, `--result-file PATH`, `--dest-glob PATH`.

Exit codes: 0 = built, 1 = error, 2 = skipped (up-to-date).

## Result File

When `--result-file` is provided, writes sourceable shell variables:
```bash
BUILD_STATUS=built     # built|skipped|bumped_only
BUILD_VERSION=1.0.0
BUILD_NUM=121
BUILD_FRAMEWORK=flutter
BUILD_ARTIFACT=/path/to/artifact
```

## Constraints
- Idempotent: running twice without source changes produces same result
- Version bump is conservative (bumps only when warranted)
- Exit code 2 is not an error — just means everything is up-to-date
- Uses python3 for JSON parsing and regex (no jq dependency)
