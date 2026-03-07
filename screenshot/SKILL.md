---
name: screenshot
base_skill: none
model_tier: fast
description: |
  Capture and analyze screenshots. Full screen or targeted window/app. Saves to /tmp for analysis.
  TRIGGER when: user wants to capture or analyze a screenshot, says "screenshot", "capture screen".
  DO NOT TRIGGER: for reading existing image files (use Read tool).
---

# Screenshot

Capture a screenshot and respond to an instruction about it.

## Args Format

```
/screenshot [target] [instruction...]
```

- **No args:** Capture full screen, describe what you see.
- **`screen <instruction>`:** Capture full screen, respond to instruction.
- **`<target> <instruction>`:** Capture the named window/app, respond to instruction.

The first word is the target. Everything after it is the instruction.

## Behavior

1. Parse args: first word = target (default: `screen`), remaining words = instruction.
2. Run `scripts/screenshot.sh <target>` from the skill directory (`~/.claude/skills/screenshot/scripts/screenshot.sh`).
3. The script prints the saved image path (e.g., `/tmp/screenshot-abc123.png`).
4. Read the image file immediately.
5. Respond to the instruction. If no instruction was given, describe what you see.
6. Do NOT delete the image — the user may reference it later.

## Examples

| Invocation | Target | Instruction |
|---|---|---|
| `/screenshot` | screen | *(describe what you see)* |
| `/screenshot screen why is it black` | screen | why is it black |
| `/screenshot beau look at top button` | beau | look at top button |
| `/screenshot safari` | safari | *(describe what you see)* |

## Script

- `scripts/screenshot.sh [target]`
- macOS: `screencapture` (window targeting via Python/Quartz, fallback: activate + full screen)
- Linux: `scrot` / `gnome-screenshot` / `import` (window targeting via `xdotool`)
- Output: prints image path to stdout

## Notes

- The image is saved to `/tmp` so it can be read by the agent for analysis.
- Window targeting is best-effort: if the exact window can't be isolated, falls back to full screen with the target app in front.
- Identity Announcement: skip (action skill — capture and respond immediately).
