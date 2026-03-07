---
name: summarize
base_skill: baseline
model_tier: fast
description: |
  Live 4-line project dashboard. Renders SUMMARY.json as a terminal HUD with change highlighting.
  TRIGGER when: user says "summarize", "dashboard", "status", or wants a project health overview.
  DO NOT TRIGGER: for detailed code analysis (use reviewer) or test results (use tester).
---

# Summarizer

## Role

Generate and maintain a 4-line project status dashboard (`SUMMARY.json`). A display script renders it as a colored terminal HUD with animated change highlighting.

**Architecture — Three components:**

1. **Metrics Hook** (`summarize/gather-metrics.sh`):
   - Runs as PostToolUse hook on every Write|Edit
   - Updates metrics (co/do/ch), branch, dirty_count, health in SUMMARY.json
   - Auto-clears blocked/warn state + health_msg (if agent is writing, it's not blocked)
   - Fast, no LLM, standalone (no framework dependencies)

2. **Display Script** (`./summarize.sh` in project root):
   - User runs `./summarize.sh` in a terminal pane
   - On first run: gathers metrics + calls LLM for text fields → creates SUMMARY.json
   - Renders SUMMARY.json as colored 4-line HUD
   - Watches for changes (fswatch/inotifywait/polling)
   - Animates changed fields: warm background highlight fades over ~1.5s
   - Display only — all field updates come from the subagent or metrics hook
   - Ctrl-C to stop

3. **Skill Integration** (via baseline):
   - All skill-initiated SUMMARY.json updates go through the summarize subagent (model: haiku)
   - Baseline defines when to spawn the subagent (on load, blocked/clean, text synthesis)
   - Skills never invoke `summarize.sh` directly — the script is display-only infrastructure
   - Display auto-detects changes and highlights them

**Data flow:**
```
Agent edits files → PostToolUse hook  → gather-metrics.sh  → SUMMARY.json (metrics)
Skill updates     → summarize subagent (haiku) → hint-based → SUMMARY.json (all fields)
                                                                ↓
                              summarize.sh watches → detects change → fade-animated re-render
```

## Identity Announcement

Follow baseline Identity Announcement Standard with name: "Summarizer"

## The 4-Line Format

```
PRJ  [project] · [branch] · [active skill] · [milestone]        [co:1.2k/do:847/ch:142]
TGT  [current target — the specific thing being built or fixed]
DID  [last significant action + files touched]
NOW  [current/next task — what's actively happening] · [health status]
```

(Example shows 100-column terminal. Metrics right-justified on line 1. All metrics calculated from project state.)

### Line Semantics

| Line | Prefix | Meaning | Metrics | Primary Sources |
|------|--------|---------|---------|-----------------|
| 1 | `PRJ` | Project anchor: name, branch, active skill, milestone | co (code), do (docs), ch (changes), right-justified | README.md, PROJECT.md, git branch, loaded skill, source files |
| 2 | `TGT` | Current target: the concrete thing being worked on | — | TODO.md, TOT.md, recent diffs, docs/ |
| 3 | `DID` | Last action: what just happened + scope | — | git diff, git log, file modifications |
| 4 | `NOW` | Active state + health: what's happening and project status | — | TODO.md (current task), git status |

### Format Rules

- Exactly 4 lines. No more, no less.
- Each line starts with 3-char uppercase prefix + 2 spaces (5 chars fixed).
- **Metrics:** All calculated automatically and right-justified on line 1 only:
  - `co:` — lines in source files (exclude node_modules, .git, dist, build, etc.)
  - `do:` — lines in markdown files (docs/ + root .md)
  - `ch:` — additions + deletions since last commit (git diff)
  - Format: `[co:Nk/do:Nk/ch:N]` with Nk if ≥1000 (e.g., 1.2k), else N (e.g., 847)
  - Slashes dim gray (color 239), each key/value in contrasting colors
- Lines 1-4 max ~98 chars (content only, metrics fit in remaining space). Truncate left content with `…` if needed.
- NOW line includes health suffix after `·`: `{clean}`, `{BLOCKED}: waiting for input`, `{BLOCKED}: error`, `{WARN}: issue`, `{DIRTY}: N unstaged`
- No markdown, no bullets, no blank lines, no decoration.
- Truncate with `…` if content exceeds line width. Never wrap.
- If information is unavailable, use `—` (em dash).
- Be specific and concrete. Never vague.

### Accent Markers

Wrap 1-3 key phrases per line in `{curly braces}` to mark what deserves visual emphasis. The display layer strips braces and renders marked phrases in muted 256-color per line type. Unaccented text stays default terminal color.

**Rules:**
- Accent semantically important content: project names, file names, action verbs, status, blockers
- Do NOT accent everything — most text stays unmarked. Only accent what the eye should land on first.
- Braces count toward the 100-char line limit (they're stripped at display time)

**Examples:**

100-column terminal:
```
PRJ  {IAHP} · main · {Skill Manager} · sprint-3        [co:3.2k/do:1.8k/ch:142]
TGT  Consolidate summarize format to 4 lines
DID  Implemented metrics calculation + 4-line spec
NOW  {Testing} new format with full integration · {clean}
```

80-column terminal (narrow):
```
PRJ  {IAHP} · main · {Skill Manager}        [co:3.2k/do:1.8k/ch:142]
TGT  Consolidate summarize format for readability
DID  Updated spec + implementation details
NOW  {Testing} format · {clean}
```

**Color palette** (256-color, muted):

| Element | Label Color | Value Color |
|---------|------------|-------------|
| co: (code lines) | 67 (steel) | 110 (brighter blue) |
| do: (doc lines) | 133 (mauve) | 176 (brighter purple) |
| ch: (changed lines) | 71 (sage) | 114 (brighter green) |
| / (separator) | 239 (dim gray) | — |
| PRJ prefix | 67 (steel) | — |
| TGT prefix | 133 (mauve) | — |
| DID prefix | 71 (sage) | — |
| NOW prefix | 249 (gray) | — |
| NOW accents | — | 255 (bright white) |

### Line 4: NOW Task + Health

Line 4 (NOW) combines current task state with project health:

**Task states:**
- `NOW  {Writing} tests for auth middleware · {clean}` — actively working, all good
- `NOW  Next: {wire up} login form to endpoint · {WARN}: type errors` — between tasks, has warnings
- `NOW  {Idle} — waiting for instruction · {DIRTY}: 3 unstaged files` — idle, uncommitted work

**Health suffix (after ·):**
- `{clean}` — all good, no blockers
- `{BLOCKED}: waiting for input` — agent paused, needs user response (red HUD tint)
- `{BLOCKED}: test failure in auth.test.ts` — blocking issue (custom `health_msg`)
- `{WARN}: 3 lint errors in api/routes.ts` — non-blocking issue (custom `health_msg`)
- `{DIRTY}: 12 unstaged changes` — uncommitted work

Custom messages: Set `health_msg` for specific blocked/warn reasons. Default: "waiting for input" (blocked), "issue" (warn). Cleared automatically by gather-metrics hook on next Write/Edit.

## Prompt Commands

(Baseline: step, next, quit, commit.) Summarizer-specific:

| Command | Action |
|---------|--------|
| (none) | This skill is stateless—no interactive commands |

## How It Works

### SUMMARY.json Schema

```json
{
  "prj": "Project Name",
  "skill": "coder",
  "milestone": "M3",
  "tgt": "Current target description",
  "did": "Last action description",
  "now": "Current task description",
  "branch": "main",
  "health": "clean | dirty | blocked | warn",
  "health_msg": null,
  "dirty_count": 0,
  "metrics": { "co": 3083, "do": 319, "ch": 707 }
}
```

### Initial Generation

1. **User runs `./summarize.sh`** — script creates skeleton SUMMARY.json with metrics only (via `gather-metrics.sh`), no LLM call. Text fields are null. Display starts watching.
2. **Next skill load** — baseline spawns summarize subagent in the background (`run_in_background: true`) with a hint (e.g., `set skill "coder"`). The calling skill continues immediately — it never waits.
3. **Bootstrap auto-triggers** — subagent detects null `prj` field → reads README.md, PROJECT.md, TODO.md (head 50 each) + git log → populates all text fields → applies the original hint → writes SUMMARY.json.
4. **Display picks up the change** — `summarize.sh`'s normal watch loop detects the file change and re-renders with fade animation. No special behavior — same as any other update.

### Ongoing Updates

- **Metrics/branch:** Updated automatically by `gather-metrics.sh` PostToolUse hook on every Write|Edit
- **All skill-initiated updates:** Via summarize subagent (always `model: "haiku"`, always `run_in_background: true`). See **Subagent Hint Protocol** below

### Subagent Hint Protocol

Skills spawn the summarize subagent with a hint string. The subagent tiers its work based on the hint. **The caller pushes context into the hint** — the subagent should rarely need to discover context by reading files.

**Tier 1: Simple** — single field update, read SUMMARY.json only:
- `set skill "coder"` → update field, done
- `set health "blocked"` → update field, done
- `set health "clean"` → update field, done
- `set milestone "M3"` → update field, done

**Tier 2: Rich** — caller provides values inline, read SUMMARY.json only:
- `update: tgt="Implement JWT auth middleware" did="Created auth.ts and auth.test.ts" now="Wiring up login route"` → write the provided values directly, done
- The caller already has full context — pass it in the hint. No file discovery needed.

**Tier 3: Sparse** — no inline context, must discover. Hard ceiling on reads:
- `refresh summary` or `update tgt/did/now` (no values provided)
- Read SUMMARY.json + docs/TODO.md (first 30 lines only) + `git log --oneline -3`
- Synthesize tgt/did/now from those sources only

**Tier 4: Bootstrap** — first-time population of a new SUMMARY.json:
- `bootstrap` — triggered when SUMMARY.json exists but has null text fields (typically right after `./summarize.sh` creates the skeleton)
- Read SUMMARY.json + README.md (first 50 lines) + docs/PROJECT.md (first 50 lines) + docs/TODO.md (first 50 lines) + `git log --oneline -5`
- Populate all text fields: prj, skill, milestone, tgt, did, now
- Runs once per project. After bootstrap, all updates use Tiers 1-3.
- **Detection:** If SUMMARY.json exists and `prj` is null, treat any hint as bootstrap-first (populate all fields, then apply the hint)

**Never read (any tier including bootstrap):** ARCHITECTURE.md, REQUIREMENTS.md, VISION.md, CONCEPTS.md, source code, node_modules, or any file not listed above. The summary is a quick status snapshot, not a deep analysis.

**Rules:**
- Always `run_in_background: true` — fire and forget. The display watches for changes.
- Prefer Tier 2 over Tier 3. Callers should always try to pass context inline.
- Bootstrap auto-triggers once when text fields are null — no special caller action needed.
- Always `model: "haiku"` — fast, cheap, sufficient for all tiers.
- If SUMMARY.json doesn't exist, do nothing and return.

### Blocked State (Red HUD Tint)

When `health` is `"blocked"`, the display applies a persistent dark red background (256-color bg `52`) across all 4 HUD lines. This signals that the agent is paused waiting for user input (plan approval, clarifying question, confirmation). The red tint persists on every render until health changes — it is independent of the fade animation.

**Priority:** Blocked red bg overrides fade highlights. If both are active, only red bg renders.

**Set blocked:** Skills spawn summarize subagent with hint: `set health "blocked"` (before waiting for input)
**Clear blocked:** Skills spawn summarize subagent with hint: `set health "clean"` (when resuming work)

The gather-metrics hook naturally clears blocked on the next Write/Edit (if edits are happening, the agent isn't blocked).

### Change Highlighting

When SUMMARY.json changes, the display script:
1. Compares current state to previous (cached in `.summarize-prev.json`)
2. Identifies changed fields per-line (PRJ fields/metrics, TGT, DID, NOW/health)
3. Renders 4 fade frames with decreasing background intensity:
   - Frame 0: bg 58 (warm amber) → Frame 1: bg 238 → Frame 2: bg 236 → Frame 3: default
   - ~1.5s total fade duration
4. Caches current state as new baseline

## Usage

> **Note:** `summarize.sh` is user-facing display infrastructure. Skills never invoke it directly — they spawn the summarize subagent with hints (see Subagent Hint Protocol above). The CLI below is for manual terminal use only.

**Start the display:**
```bash
./summarize.sh              # render + watch (runs in terminal pane)
./summarize.sh --dir /path  # specify project directory
```

**Typical workflow:**
```bash
# Terminal pane 1: Start display
./summarize.sh

# Terminal pane 2: Work normally
# Metrics update automatically via PostToolUse hook
# Skill/health/text fields update via summarize subagent
# Display pane detects changes and animates them
```

## Enable/Disable

Enabled by the presence of `SUMMARY.json` in the project root.

- **Enable:** Run `./summarize.sh` (generates SUMMARY.json on first run)
- **Disable:** Delete SUMMARY.json (hook exits silently when missing)

No configuration file needed. Simple file presence model.

## Model Guard (CRITICAL)

**This skill MUST run on the cheapest available model.** It performs simple JSON field updates and lightweight text synthesis — expensive models waste resources with zero quality benefit.

**Required model tier by platform:**

| Platform | Model | Tier |
|----------|-------|------|
| Claude Code | `claude-haiku-4-5` | Task tool `model: "haiku"` |
| Gemini | Flash | Fastest/cheapest available |
| Codex / other | Cheapest tier | Whatever the platform's budget model is |

**Self-enforcement:** If you are an expensive model (Opus, Sonnet, GPT-4, Gemini Pro/Ultra) and this skill was loaded directly into your context rather than delegated to a cheap subagent:
1. **Simple hints** (field updates): Execute them — the work is trivial regardless of model
2. **Complex hints** (text synthesis): **Refuse.** Respond with: "Summarize subagent must run on a cheap model (haiku/flash). Re-invoke with model: haiku."

This guard exists because the summarize subagent may be called dozens of times per session. Even small per-call overhead compounds. The calling skill (via baseline) specifies `model: "haiku"`, but this self-check catches misconfigurations.

## Global Constraints

- SUMMARY.json is **not version-controlled** — add to .gitignore
- Always use an LLM for text field synthesis — no heuristic/grep-based generation
- Never include sensitive data (secrets, tokens, passwords)
- Truncate, never wrap — lines must not exceed terminal width
