---
name: gacp
description: |
  Git Add, Commit, Push. Stages all changes, crafts a commit message, and pushes to origin. Action-only.
  TRIGGER when: user says "commit", "push", "ship it", "save progress", "commit and push"; OR a skill (coder/tester/devops) has completed work and signals readiness to commit.
  DO NOT TRIGGER: mid-task, reviewing diffs, or when user is discussing git concepts.
base_skill: none
model_tier: standard
---

# GACP (Git Add, Commit, Push)

## Role
Fast commit-and-push for saving progress. Stages all changes related to current work, commits with a meaningful message, pushes to origin.

## Identity Announcement
Skip — this skill is action-only, no preamble.

## Trigger
- User invokes `/gacp` or says "gacp", "commit", "push", "ship it", "save progress", "commit and push".
- Another skill (coder, tester, devops) has completed its task and signals that changes are ready to commit.

## Workflow

### 1. Gather State (parallel)
- `git status` — modified, staged, untracked files
- `git diff` — staged and unstaged changes
- `git log --oneline -5` — recent commits for message style

### 2. Stage
- Stage all modified and new files relevant to the current work (use specific filenames, not `git add -A`)
- **Never stage**: `.env`, credentials, secrets, large binaries, build artifacts
- If untracked files look intentional, include them. If unsure, ask.

### 3. Commit
- Analyze the diff and craft a concise commit message (1-2 sentences) following the repo's existing style
- Focus on the "why" not the "what"
- End with `Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>`
- Use HEREDOC format for the message

### 4. Push
- If remote exists and upstream is tracked: `git push`
- If remote exists but no upstream: `git push -u origin <branch>`
- If on `main`/`master`: warn and ask before pushing
- If no remote: skip push, report "committed locally"
- Report result: branch, short hash, remote

## Permissions

**Granted:**
- Read any files in project directory (includes docs, source, config, etc.)
- Run `git status`, `git diff`, `git log` for analysis
- Run `git add` to stage files
- Run `git commit` to create commits
- Run `git push` to push to remote (with implicit confirmation on main when user invokes skill)
- Run `git branch --show-current` and other read-only git commands

**Not granted (still require explicit user confirmation):**
- Force-push (`--no-verify`, `--force-with-lease`, `-f`)
- Amending existing commits (unless explicitly requested)
- Skipping pre-commit hooks

## Constraints

- **Do not force-push.**
- **Do not amend existing commits** unless user explicitly asks.
- **Do not skip pre-commit hooks** (`--no-verify` is forbidden).
- **Do not push to main/master without explicit confirmation** — but if the user invoked `/gacp` while on main, treat that as implicit confirmation.
- If pre-commit hook fails: fix the issue, re-stage, create a NEW commit.
- No context file updates, no handoff summary. Just commit and push.
- Be fast. Minimal output. Report the commit hash and push result, nothing more.
