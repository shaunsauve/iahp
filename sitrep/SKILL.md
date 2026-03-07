---
name: sitrep
description: |
  Situation report: compact summary of what was just done and the next few steps.
  TRIGGER when: user says "sitrep", "situation report", "where are we", "status check".
  DO NOT TRIGGER: for detailed project dashboards (use summarize), code review (use reviewer).
base_skill: none
model_tier: fast
---

# Sitrep

## Role
Deliver a military-style situation report in 5 seconds flat. No preamble. No padding.
Two blocks: what was just done, what's next.

## Identity Announcement
Skip — action-only. Output the sitrep immediately.

## Workflow

### 1. Read (parallel, head only)
- `RESUME.md` — Done This Session + Next Up (primary source)
- `docs/TODO.md` — first 40 lines (current task, backlog)
- `git log --oneline -5` — recent commits for "done" confirmation

If RESUME.md is absent, use TODO.md + git log only.

### 2. Synthesize
Extract:
- **DONE**: what was completed in the current session / most recent work (1–3 items, compact)
- **NEXT**: the next 2–4 tasks in priority order

### 3. Output

Print exactly this format — no markdown, no headers, no extra lines:

```
DONE  <item 1>
      <item 2, if any>
      <item 3, if any>

NEXT  <task 1>
      <task 2>
      <task 3, if any>
      <task 4, if any>
```

**Rules:**
- Each line of content starts with 6 chars of indentation after the first line of each block (`DONE  ` / `NEXT  ` = 6 chars; continuation lines = 6 spaces)
- Max 80 chars per line. Truncate with `…` if needed.
- One blank line between DONE and NEXT blocks only.
- No role annotation, no skill name, no "here is your sitrep", no trailing commentary.
- Concrete and specific. Not "continued work" — say what the work actually was.
- If something is truly unknown, use `—` (em dash).

**Example output:**
```
DONE  T1/T2 test tier system (justfile + cargo aliases + TESTING.md)
      Editor Phase 2: grid overlay, cursor preview, G-key dispatch

NEXT  Editor Phase 3 — inference engine + axis display
      NPC Phase 1 — NpcIdentity/NpcSimState/NpcGroup in beau-core
      Crystal Field Phase 1 — geological base
```

## Constraints
- No file writes. Read-only.
- No follow-up questions. Output and stop.
- Never exceed 12 lines total.
- Haiku model only — this is a cheap synthesis task.
