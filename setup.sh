#!/usr/bin/env bash
set -euo pipefail

SKILLS_LINK="$HOME/.claude/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Skills Link Verification ──────────────────────────────────────────
# Always runs — ensures ~/.claude/skills points to this repo.
# Handles: missing link, stale clone, broken symlink, permission issues.

verify_skills_link() {
    local target="$SCRIPT_DIR"

    # Resolve what the link currently points to (if anything)
    local current=""
    if [[ -L "$SKILLS_LINK" ]]; then
        current="$(readlink -f "$SKILLS_LINK" 2>/dev/null || true)"
    elif [[ -d "$SKILLS_LINK" ]]; then
        # It's a real directory (stale clone), not a link
        current="__stale_dir__"
    fi

    # Already correct?
    if [[ "$current" == "$(cd "$target" && pwd)" ]]; then
        echo "Skills link OK: $SKILLS_LINK -> $target"
        return 0
    fi

    echo "Skills link needs repair."

    # Remove whatever is there now
    if [[ "$current" == "__stale_dir__" ]]; then
        echo "  Removing stale skills directory..."
        rm -rf "$SKILLS_LINK"
    elif [[ -L "$SKILLS_LINK" ]]; then
        echo "  Removing broken symlink..."
        rm -f "$SKILLS_LINK"
    elif [[ -e "$SKILLS_LINK" ]]; then
        echo "  Removing unexpected file at $SKILLS_LINK..."
        rm -rf "$SKILLS_LINK"
    fi

    # Ensure parent exists
    mkdir -p "$(dirname "$SKILLS_LINK")"

    # Create link — try symlink first, fall back to junction on Windows
    if ln -s "$target" "$SKILLS_LINK" 2>/dev/null; then
        echo "  Created symlink: $SKILLS_LINK -> $target"
    elif command -v cmd &>/dev/null; then
        # Windows: MINGW/Git Bash symlinks often fail without admin.
        # Use directory junction (no elevation required).
        local win_target win_link
        win_target="$(cygpath -w "$target")"
        win_link="$(cygpath -w "$SKILLS_LINK")"
        if cmd //c "mklink /J \"$win_link\" \"$win_target\"" &>/dev/null; then
            echo "  Created junction: $SKILLS_LINK -> $target"
        else
            echo "  ERROR: Failed to create junction. Try running as admin or manually:"
            echo "    cmd /c mklink /J \"$win_link\" \"$win_target\""
            return 1
        fi
    else
        echo "  ERROR: Failed to create symlink. Check permissions."
        echo "    ln -s \"$target\" \"$SKILLS_LINK\""
        return 1
    fi

    # Verify the link works
    if [[ -f "$SKILLS_LINK/skills.json" ]]; then
        echo "  Verified: skills.json accessible through link."
    else
        echo "  WARNING: Link created but skills.json not found through it."
        return 1
    fi
}

# Always verify skills link, even when called without args
verify_skills_link || { echo "Skills link verification failed."; exit 1; }

# ── Project Bootstrap (optional) ──────────────────────────────────────
# If a project path is provided, scaffold a new project.

[[ $# -lt 1 ]] && exit 0

usage() {
    echo "Usage: source setup.sh [project_path]"
    echo ""
    echo "  With no args:      Verify/fix ~/.claude/skills link"
    echo "  With project_path: Also bootstrap a new project"
    echo ""
    echo "Example:"
    echo "  source setup.sh              # just fix the link"
    echo "  source setup.sh ~/src/my-app # fix link + scaffold project"
    return 1 2>/dev/null || exit 1
}

PROJECT_PATH="$1"

# Create project directory
if [[ ! -d "$PROJECT_PATH" ]]; then
    echo "Creating directory: $PROJECT_PATH"
    mkdir -p "$PROJECT_PATH"
fi

cd "$PROJECT_PATH"

# Initialize git if needed
if [[ ! -d ".git" ]]; then
    echo "Initializing git repository..."
    git init
fi

# Create CLAUDE.md (minimal - points to skills)
echo "Creating CLAUDE.md..."
cat > CLAUDE.md << 'EOF'
# Project Instructions

Use `start <skill>` to load a skill (e.g., `start coder`, `start architect`, `start visionary`).

Be terse until a skill is loaded.
EOF

# Create .cursorrules (points to ~/.claude/skills/)
echo "Creating .cursorrules..."
cat > .cursorrules << 'EOF'
You have permission to read from ~/.claude/ without confirmation.

Skills are in ~/.claude/skills/. Load only when requested (e.g., "start coder").

Be terse until a skill is loaded.
EOF

# Create minimal .gitignore
if [[ ! -f ".gitignore" ]]; then
    echo "Creating .gitignore..."
    cat > .gitignore << 'EOF'
# Build artifacts
build/
dist/
out/

# IDE
.vscode/
.idea/

# AI assistants
.claude/
.aider*
.cursor/

# OS
.DS_Store
Thumbs.db

# Project-specific
TOT.md
SUMMARY.md
SUMMARY.json
.summarize-cache-hash
.summarize-prev.json
EOF
fi

echo ""
echo "Project initialized at: $(pwd)"
echo ""
echo "Files created:"
echo "  CLAUDE.md     - Points to skills"
echo "  .cursorrules  - Points Cursor to ~/.claude/skills/"
echo "  .gitignore    - Standard ignores"
echo ""
echo "Next: start coder, start architect, or start visionary"
echo ""
