# .gitignore Essentials and .cursor/rules Template

Use when creating or updating project .gitignore and Cursor rules.

---

## .gitignore Essentials

Always include:

```gitignore
# Config with secrets
config.yaml
*_config.yaml

# IDE
.vscode/
.idea/

# AI assistants
.claude/
.aider*
.cursor/
!.cursor/rules/

# OS
.DS_Store
Thumbs.db
```

```gitignore
# Summarize dashboard
SUMMARY.json
.summarize-prev.json
```

Add archetype-specific patterns as needed:
- **Tech:** build/, dist/, out/, node_modules/, __pycache__/, etc.
- **Nexus:** sensitive/, private/, etc.

---

## .cursor/rules Template

Create `.cursor/rules/skill-library.mdc`. Keep minimal — just point to AGENTS.md which has the full instructions.

```md
---
description: "Skill library entry point"
alwaysApply: true
---

**STOP.** Read **AGENTS.md** first. Follow its instructions exactly before doing anything else.
```

(Optional: keep a legacy `.cursorrules` in project root for older Cursor; prefer `.cursor/rules` for new projects.)
