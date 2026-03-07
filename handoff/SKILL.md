---
name: handoff
base_skill: baseline
model_tier: standard
description: |
  End-of-session wrap-up. Updates RESUME.md and TOT.md for continuity, then delegates to /gacp for commit and push.
  TRIGGER when: user says "quit", "exit", "done for now", "wrap up", "handoff"; end of session.
  DO NOT TRIGGER: mid-task or when user just wants to commit (use gacp).
  CHAIN: delegates to gacp for final commit and push.
---

# Handoff

## Role
End-of-session wrap-up. Ensures continuity files are current so the **same person can resume later** or a **different skill/agent can pick up seamlessly**.

Use for either:
- **Session close** — user is done, closing Claude
- **Skill handoff** — another skill continues the work (e.g., architect → coder)

Both need the same thing: RESUME.md current, TOT.md current, code committed and pushed.

## Identity Announcement
Follow baseline Identity Announcement Standard with name: "Handoff"

## Trigger
User invokes `/handoff` — typically at the end of a work session.

## Workflow

### 1. Assess State

Gather current state (run in parallel):
- `git status` — staged, unstaged, untracked files
- `git diff --stat` — scope of changes
- Read `docs/TODO.md` — current task, backlog
- Read `TOT.md` (if exists) — recent thinking

Summarize what you see before proceeding:
- Files changed (count and key files)
- Current task from TODO.md
- Any untracked files that may need attention

### 2. Update RESUME.md

**RESUME.md** is the session continuity file. A cold reader should be able to open it and know exactly what's happening, what just happened, and what to do next.

Write/update RESUME.md at project root:

```markdown
# Session Resume

## Last Activity
- Working on [current task from TODO.md]
- Current focus: [specific work in progress]

## Done This Session
- [Bullet summary of work completed]

## Next Up
- [Next task from TODO.md backlog]
- [Follow-up items identified during session]

## Notes for Next Session
- [Context not captured elsewhere but helpful for resuming]
- [Warnings, blockers, things to watch out for]
- [Files or areas to look at first]

## Related
- TODO: [item references]
- See: [relevant doc files]
```

Guidelines:
- Keep concise (< 500 words)
- Focus on: what we were doing, why, what's next
- Reference TODO items and recent decisions
- Note any blockers or open questions

### 3. Update TOT.md (Train of Thought)

Update if any of the following occurred this session:
- Explored multiple approaches before choosing one
- Made a non-obvious decision or tradeoff
- Discovered something surprising about the codebase or domain
- Changed direction mid-session
- Identified a concern, risk, or open question

If the session was purely mechanical (e.g., fixing a typo), skip the update.

Guidelines:
- Recent entries at top
- Keep under ~30 lines total; archive older entries if exceeded (see baseline Archive Protocol)

### 4. Commit and Push (delegate to /gacp)

Invoke `/gacp` to handle the git operations:
- Stages all modified/new files including RESUME.md and TOT.md updates
- Crafts commit message
- Pushes to origin

If not a git repo, skip this step.

### 5. Handoff Summary

Print a clean summary:

```
## Handoff Summary

**Branch:** <branch-name>
**Commit:** <short-hash> <message>
**Pushed:** yes/no (to <remote>/<branch>)

### Done This Session
- <bullet summary>

### Next Up
- <next task>

### Continuity
- RESUME.md: updated
- TOT.md: updated / no changes needed
```

## Constraints

- **Do not update TODO.md or PROJECT.md** — the active skill maintains those during the session, not handoff.
- **Do not create new documentation files** — only update RESUME.md and TOT.md.
- If there are no changes at all (clean tree, continuity files current), skip step 4 and still produce the handoff summary.

## Edge Cases

- **Not a git repo**: Skip step 4 entirely. Still update continuity files and print summary.
- **No remote**: gacp handles this (commits locally, reports no remote).
- **Merge conflicts**: Do not attempt to resolve. Report and let the user handle it.
- **Dirty submodules**: Report but do not modify.
- **Nothing to do**: If working tree is clean and continuity files are current, just print the handoff summary with "No changes this session."
