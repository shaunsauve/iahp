---
name: gccp
description: |
  Git Collapse, Commit, Push. Squash-merges a feature branch into the target branch as a single commit, then pushes.
  TRIGGER when: user wants to squash-merge a branch, says "squash", "collapse", "gccp".
  DO NOT TRIGGER: for regular commits (use gacp) or when user wants to preserve individual commit history.
base_skill: none
model_tier: standard
---

# GCCP (Git Collapse, Commit, Push)

## Role
Squash-merge a feature/worktree branch into the target branch as a single clean commit. The inverse of branching — collapses all work back into one commit on the target.

## Identity Announcement
Skip — this skill is action-only, no preamble.

## Trigger
User invokes `/gccp` or says "gccp".

## Workflow

### 1. Gather State (parallel)
- `git branch --show-current` — current branch
- `git status` — ensure working tree is clean (abort if dirty)
- `git log --oneline main..HEAD` — commits to be collapsed (adjust base branch as needed)
- `git log --oneline -5 main` — recent main commits for message style

### 2. Identify Branches
- **Source branch**: the current branch (the one being collapsed)
- **Target branch**: `main` by default. If the user specifies a different target, use that.
- If already on `main`/`master`: abort with error — nothing to collapse.
- If the source branch has no commits ahead of target: abort — nothing to collapse.

### 3. Confirm
Before proceeding, show the user:
- Source branch name
- Target branch name
- Number of commits being collapsed
- Summary of changes (`git diff --stat target..source`)

Ask for confirmation. This is a destructive operation (branch history is lost).

### 4. Squash-Merge
```
git checkout <target>
git merge --squash <source>
```

### 5. Commit
- Analyze the full diff and craft a concise commit message (1-3 sentences) summarizing ALL changes
- Focus on the "why" not the "what"
- If the source branch commits have a clear theme, reflect it in the message
- End with `Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>`
- Use HEREDOC format for the message

### 6. Push
- If remote exists and upstream is tracked: `git push`
- If remote exists but no upstream: `git push -u origin <target>`
- If on `main`/`master`: push (implicit confirmation since user invoked the skill)
- If no remote: skip push, report "committed locally"

### 7. Sync Worktree Branch
After pushing the squashed commit to target, reset the source branch to match the target so there are no divergent commits. This allows Claude Code's worktree exit prompt to show a clean state (no "you have N commits" warning).

```
git checkout <source>
git reset --hard <target>
git push --force-with-lease origin <source>
```

Then clear `ORIG_HEAD` so Claude Code's worktree exit doesn't count commits between pre-reset state and current HEAD:
```
git update-ref -d ORIG_HEAD
```

**Why all three steps are needed:**
- `reset --hard` syncs local branch to target (0 ahead of main)
- `push --force-with-lease` syncs remote tracking branch (0 ahead of origin)
- `update-ref -d ORIG_HEAD` clears the pre-reset ref that Claude Code uses for its "you have N commits" check

The reset is safe because all changes are already on target via the squash commit. The force-push is the one permitted use in this skill (overwriting a branch with its own squashed content).

### 8. Cleanup (ask first)
Offer to delete the source branch and remote:
- `git branch -d <source>` — local delete
- `git push origin --delete <source>` — remote delete

Only proceed with deletion after explicit user confirmation. If the user declines, the branch stays but is clean (synced with target).

### 9. Report
- Target branch, short hash, commit message
- Push result
- Worktree branch sync status
- **Note to user**: Claude Code's worktree exit may still show "You have N commits" because it compares HEAD against the commit stored in memory at worktree creation time. This is expected after gccp — all changes are safely on the target branch. Select "Remove worktree" to clean up.
- Whether source branch was cleaned up

## Permissions

**Granted:**
- Read any files in project directory
- Run `git status`, `git diff`, `git log`, `git branch` for analysis
- Run `git checkout` to switch branches
- Run `git merge --squash` to squash-merge
- Run `git commit` to create the collapsed commit
- Run `git push` to push to remote
- Run `git reset --hard <target>` on source branch to sync it after squash (all changes already on target)
- Run `git push --force-with-lease origin <source>` to sync remote tracking branch after reset
- Run `git branch -d` to delete local branches (after confirmation)
- Run `git push origin --delete` to delete remote branches (after confirmation)

**Not granted (still require explicit user confirmation):**
- Force-push (`--force`, `--force-with-lease`)
- Deleting branches (always ask first)
- Skipping pre-commit hooks

## Constraints

- **Do not force-push** — except the one permitted case: `git push --force-with-lease origin <source>` after resetting the source branch to target (step 7).
- **Do not skip pre-commit hooks** (`--no-verify` is forbidden).
- **Do not delete branches without explicit confirmation.**
- **Abort if working tree is dirty** — user must commit or stash first.
- **Abort if merge conflicts occur** — report the conflict and let the user resolve manually.
- If pre-commit hook fails: fix the issue, re-stage, create a NEW commit.
- No context file updates, no handoff summary. Just collapse, commit, and push.
- Be fast. Minimal output.
