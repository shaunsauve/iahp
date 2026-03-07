---
name: baseline
model_tier: standard
description: Base project context instructions. Read docs/ and README.md for project understanding.
---

# Base Project Context

<!-- Three-layer structure: Startup (what to do on load), Contracts (rules during work), Reference (look up when needed) -->

# LAYER 1: STARTUP

## On Load (Execute Every Step)

1. **Read config:** Check `.claude/user-config.json` for saved user settings
2. **Read CD1 files:** README.md, docs/TODO.md, docs/PROJECT.md, RESUME.md (if exists). If RESUME.md conflicts with TODO.md, trust TODO.md.
3. **Identify yourself:** Output `**===== I am the [Skill Name] =====**` (skip if skill declares `Identity Announcement: skip`)
4. **HUD skill signal:** If `SUMMARY.json` exists in project root, spawn summarize subagent (model: haiku, run_in_background: true, mode: bypassPermissions) with hint: `set skill "<your-skill-name>"`
5. **List commands:** One line: baseline common (?, step, next, quit, commit) plus this skill's commands. No table, no elaboration.
6. **STOP.** Wait for user prompt. Do not proceed with any work until the user tells you what to do.
   - **Exception:** Subagent invocation via Task tool -- proceed with given task.

**Interactive mode:** User loads skill -> identify + wait -> user provides task -> scan + plan + confirm -> execute
**Delegated mode:** Skill loaded with task -> identify -> scan + plan + execute task from invocation

## HUD Protocol (SUMMARY.json)

All SUMMARY.json updates go through the summarize subagent. Spawn with `model: "haiku"`, `run_in_background: true`, `mode: "bypassPermissions"`. Fire and forget -- never block.

| Event | Hint | When |
|-------|------|------|
| Skill loaded | `set skill "<name>"` | Step 4 of On Load |
| Waiting for user input | `set health "blocked"` | Before any pause for user response (plan approval, clarifying question, confirmation) |
| User responded | `set health "clean"` | When work resumes after user input (or let Write/Edit hook clear it) |
| Progress update | `update: tgt="..." did="..." now="..."` | At meaningful transitions -- pass context inline so subagent doesn't read files |

Skills never invoke `summarize.sh` directly -- it is display-only infrastructure. Enable: run `./summarize.sh` (creates SUMMARY.json). Disable: delete SUMMARY.json (hooks exit silently).

Child skills declare **when** they block (in a "HUD Moments" table); this protocol defines **how**.

---

# LAYER 2: BEHAVIORAL CONTRACTS

## Describe Before Doing

**CRITICAL:** Always describe planned actions and get confirmation before executing.

1. Outline the plan (steps, files affected, dependencies)
2. If ambiguous, ask before assuming
3. Wait for explicit "yes" or "proceed"
4. For multi-step work, present full plan and wait for approval

Do NOT: create files immediately, make changes before understanding architecture, start implementing without outlining approach, or assume requirements.

## File Editing Rules

- **Prefer Edit over Write** for existing files. Write replaces entire file and can corrupt encoding.
- **Never Write back a file you just Read if Read showed garbled characters.**
- After any file modification, run `git diff` to confirm no unintended byte changes.

## Code Organization

Code is organized for agent comprehension, not human scanning conventions. **These guidelines are intentionally contrarian to typical human-based coding practices.** Conventional wisdom about file size, separation, and structure optimized for human readers scanning code visually. Agents consume files differently — they read entire files at once and benefit from collocated context. Be lenient when code strays from human-oriented conventions; only flag structural issues that genuinely impede agent comprehension or cause real engineering costs.

- **Don't split files for readability alone.** A single file gives full domain context in one read. Splitting forces multi-file context assembly with no benefit.
- **Only split when:** there's a genuine modularity boundary (independent concerns that change independently), OR the file is demonstrably causing context problems.
- **Avoid splits that cost build time or runtime performance.** If a split introduces measurable overhead, it needs strong justification beyond organization.
- **Consolidate small files.** Many tiny files (30–60 LOC each) with one function apiece are premature decomposition. Group related functions until a group exceeds ~300 LOC.
- **Functions and modules explain the WHY and WHAT.** Names and doc comments convey intent, rationale, and purpose — not mechanical description or human scanability.
- **No cosmetic refactoring.** If the current file structure isn't causing problems, don't reorganize it.

## Permissions

You have permission to:
- Read, search, and explore any file/directory in cwd and subdirectories without confirmation
- Read and write to temp directory (/tmp, %TEMP%) without confirmation
- Perform git read operations without confirmation (git status, diff, log, branch, remote, etc.)
- Use read-only filesystem analysis tools without confirmation (find, wc, du, stat, file, tree, ls)

## Cross-Cutting Guards

**Narrative content guard:** Do NOT casually introduce race names, culture names, NPC backstories, place names with lore significance, creation myths, or any world-building content. Introducing narrative content is as serious as an architectural pivot -- it propagates and becomes load-bearing. Use placeholders marked "PLACEHOLDER -- needs storyteller review." Suggest `/storyteller` for narrative work.

**Vision implications:** When work reveals interesting use cases or product insights, make a brief non-blocking suggestion: "Note: [insight]. Consider `/visionary` to evaluate."

---

# LAYER 3: REFERENCE PROTOCOLS

## Common Commands

| Command | Action |
|---------|--------|
| ? | List all available commands verbosely (baseline + skill-specific) |
| step | Walk through a list one by one; advance with next/n, back with previous/p, repeat with repeat/r |
| next, n | Advance (in step mode) or suggest/proceed with next action |
| quit, exit | Delegate to `/handoff` if available; otherwise: update RESUME.md + TODO.md, commit |
| commit | Commit (and push where applicable) changes |

## Project Documentation

### CD1 -- Always Read on Startup

| File | Purpose |
|------|---------|
| README.md | Source of truth: description, quick start, setup, run, test |
| docs/TODO.md | Current task, previous task, backlog |
| docs/PROJECT.md | Milestones, MVP scope, current focus |
| RESUME.md | (temporary, if exists) Session snapshot for continuity |

### CD2 -- Read When Current Task Requires

| File | Purpose |
|------|---------|
| docs/VISION.md | Product goals, epics, use cases, user stories |
| docs/USE_CASES.md | (optional) Use case tracker; append-only |
| docs/REQUIREMENTS.md | Functional (F001...) and non-functional (N001...) requirements |
| docs/ARCHITECTURE.md | Components, data model, design decisions |
| docs/CONCEPTS.md | Domain knowledge, terminology |

Skills promote CD2 files to CD1 in their own Canonical Context section when central to that skill's domain.

## Context Depth Protocol

Top-level docs (ARCHITECTURE.md, CONCEPTS.md, VISION.md, etc.) are the **index layer** -- enough to decide whether a secondary file is relevant to your current task. Secondary files hold implementation-level detail.

### As a Reader
1. Read CD1 on startup for orientation.
2. Read CD2 only when current task touches that domain. Scan summaries to decide relevance.
3. Trust the summary for peripheral topics.

### As a Writer
When breaking a subsection into its own file:
1. **Leave a working summary** in the parent -- not a one-liner. Answer: What is this? Key concepts? When to know more?
2. **Link to the secondary file** with a read directive.
3. **State when to deep-read.**

**Anti-pattern:** `See docs/FOO.md for details.` -- tells reader nothing.
**Correct:** > **Foo System** handles X, Y, Z using [mechanism]. Core concepts: [terms]. Full specification: `docs/FOO.md` -- read before modifying [subsystems].

### CD Conventions
- CD1 is finite and explicitly defined; do not infer extra files from naming.
- Respect existing project naming conventions before introducing baseline labels.
- Prefer unfragmented CD1 until too large; then migrate to CD2 with summaries.

## Session Resume (RESUME.md)

**Purpose:** Temporary session snapshot for continuity. Complements (does not replace) canonical docs.

**Lifecycle:** Created/updated on `quit` or session end. Version-controlled (committed with code). If conflicts with TODO.md, trust TODO.md.

**On session start:** Check if exists; read for context alongside TODO.md.
**On session end:** Update with current snapshot. The `/handoff` skill owns the template and full procedure. Minimal skeleton if writing directly: `## Last Activity` / `## Next Up` / `## Notes for Next Session`.

## Archive Protocol

Files that grow by appending (TODO.md, TOT.md, LOG.md) can exceed useful size. Move resolved content to `{FILENAME}.archive.md`.

| File | Threshold | Archive Candidates |
|------|-----------|-------------------|
| docs/TODO.md | ~80 lines | Completed tasks with no active relevance |
| TOT.md | ~30 lines | Older thinking notes (keep recent/impactful) |
| LOG.md | ~100 lines | Older dated entries |

**Rules:** Never archive open/in-progress items or completed items that provide context for open ones. Newest-archived at top. Add reference line in live file. Check on `commit` or `quit`. Read archive only on demand.

## AI Working Files

**docs/internal/** -- AI working context: planning, review notes, decision artifacts.

Create before/during major work. Version-control for team context. Document why, not just what. Keep until work completes or insights move to canonical docs.

## User Configuration

Check `.claude/user-config.json` for saved user settings. Create this file when storing settings that should persist across sessions.
