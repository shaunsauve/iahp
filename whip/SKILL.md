---
name: whip
base_skill: none
model_tier: fast
description: |
  Launch a command in the current terminal with auto-retry for known prompts (high demand, y/N confirmations).
  TRIGGER when: user says "whip" or wants to launch a command with auto-retry for prompts.
  DO NOT TRIGGER: for regular shell commands (use Bash tool directly).
---

# Whip

Run a command with automatic prompt handling in the current terminal.

## Command
- `whip <command> [args...]`
- Example: `/whip geminix`, `/whip 'cd myfolder; claude'`

## Dependencies
- **tmux** — required. Install: `brew install tmux`

## Behavior
1. Check tmux is installed. If not, abort with install instructions.
2. Run `whip.sh` with the user's command string.
3. Done. The command runs interactively with auto-retry active.

## Script
- `whip.sh` (repo root) — tmux-based auto-responder, zero output interference
