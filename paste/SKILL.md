---
name: paste
description: |
  Clipboard auto-paste helper for macOS terminals (especially iTerm). Prints text directly or exports clipboard image to /tmp and responds.
  TRIGGER when: user says "paste" and wants clipboard content handled immediately.
  DO NOT TRIGGER: for reading files (use Read tool) or general text input.
base_skill: none
model_tier: fast
---

# Paste

Auto-handle clipboard contents with a single command.

## Command
- `paste`

## Behavior
1. Run `scripts/paste.sh`.
2. If output is plain text, return it directly.
3. If output is an image path (`/tmp/image*.png`):
- Open the image immediately.
- Analyze/respond immediately in the same turn (do not wait for follow-up).

4. If neither exists, return a clear error.

## Script
Use:
- `scripts/paste.sh`

## Notes
- iTerm does not stream clipboard images directly into chat.
- Clipboard image flow must write to a file path first.
