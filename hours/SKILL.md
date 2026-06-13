---
name: hours
description: Time tracking for client projects. Add hours, submit periods, view summaries, audit work blocks from Claude session logs.
base_skill: none
model_tier: fast
---

**TRIGGER when:** user says "hours", "log time", "track time", "timesheet", "audit hours"; or "/hours" with args.
**DO NOT TRIGGER:** for invoicing, rates, or dollar amounts.

# Hours

## Role
Track billable hours across client projects. Add entries, mark submission periods, view summaries. Never shows rates or dollar amounts — that's invoicing.

## Identity Announcement
Skip — this skill is action-only, no preamble.

## Syntax

```
/hours                              # dashboard: all projects with tracked hours
/hours <project>                    # summary for matched project (partial name OK)
/hours <project> add <amount> <desc> [--from-audit]
/hours <project> submit [last]
/hours <project> summary [last]
/hours <project> last
/hours <project> audit [period] [--logs-dir <path>]
```

- No args — scan all `clients/*/timesheets/` and show a one-line-per-project dashboard
- `<project>` alone — equivalent to `summary` (partial match: `stu` matches `studio63`)
- `add` — append a time entry for today
- `submit` — summary + mark current entries as submitted
- `summary` — show current period breakdown
- `last` — shorthand for `summary last` (previous submitted period)
- `last` as modifier on submit/summary — operate on previous period instead of current
- `audit` — reconstruct work blocks from Claude Code session logs as evidence of hours worked

## Timesheet Location

`clients/<project>/timesheets/YYYY-MM.md` (current month). Scan all months when computing periods.

A project may instead live at a non-`clients/` root (e.g. `personal/timesheets/` for a solo advisory engagement). Treat any `*/timesheets/*.md` tree as a project; partial-match the directory name.

## Timesheet Format

```markdown
# <ProjectName> Timesheet — YYYY-MM

Project: <project-name>

## Hours

| Date | Hours | Description |
|------|-------|-------------|
| 2026-02-12 | 1.5 | Did something |
<!-- SUBMITTED: 2026-02-15 -->
| 2026-02-16 | 0.5 | Did more |
```

The `<!-- SUBMITTED: YYYY-MM-DD -->` marker separates submitted from pending entries. It sits inline between table rows as an HTML comment (invisible in rendered markdown).

## Per-Project Config

Read `.agents.json` at the project repo root. If a top-level `hours` object is present, it tunes this skill's behavior for the project. Known keys:

| Key | Type | Effect |
|-----|------|--------|
| `extraLogsDirs` | `string[]` | Additional `~/.claude/projects/<dash-path>/` directories to merge into the `audit` workflow. Paths may use `~`. Interactions are deduped across all sources by `uuid`. |
| `logsDir.<project>` | `string` | Override the auto-derived session-log directory for a specific project name. Same role as the legacy `.claude/user-config.json` key, kept for back-compat. |

Future per-project knobs land here under new keys; resist the urge to scatter config across multiple files.

Example:

```json
{
  "sources": [ ... ],
  "hours": {
    "extraLogsDirs": [
      "~/.claude/projects/-Users-user-src-tumble"
    ]
  }
}
```

Read order for each config lookup:
1. CLI flag (e.g. `--logs-dir <path>`)
2. `.agents.json` → `hours.*` (project-local)
3. `.claude/user-config.json` → `hours.*` (legacy / user-global)
4. Built-in heuristic

## Workflow: no args (dashboard)

1. Scan all `*/timesheets/*.md` files under the project root
2. For each project that has timesheet files, compute current period hours (after last `<!-- SUBMITTED: -->` marker)
3. Display one line per project:

```
Hours Dashboard

| Project | Current Period | Last Submitted |
|---------|---------------|----------------|
| studio63 | 0.5h (1 entry) | 7.75h on 2026-03-06 |
| socal | 3.0h (4 entries) | — |
```

## Workflow: `<project>` alone (no subcommand)

Equivalent to `/hours <project> summary`. Partial name matching: find the first timesheet-bearing directory whose name contains the input (case-insensitive). If ambiguous (multiple matches), list them and ask.

## Workflow: `add`

1. Resolve today's date from system date
2. Find or create `<project-root>/timesheets/YYYY-MM.md`
   - If creating: carry forward project name from most recent existing timesheet
3. Append row: `| YYYY-MM-DD | <amount> | <desc> |` before the closing `---` line
4. Recalculate and update the `**Total: X.X hours**` line
5. Output: `Logged <amount>h on <project>: <desc>`

## Workflow: `summary`

1. Scan all timesheet files for `<project>` (all months)
2. Find the last `<!-- SUBMITTED: -->` marker across all files
3. Collect all entries AFTER that marker (or all entries if no marker exists)
4. Display compact line-per-entry breakdown:

```
<project> — current period (2026.02.12 – 2026.02.13)

2026.02.12  1.5h - Project scaffold, Flutter setup
2026.02.13  0.5h - Late-night fix, scan button bug

Period total: 2.0 hours
Last submitted period: 7.75 hours (2026-03-06)
```

The period range is first entry date – last entry date (or today if current period).

5. If `last` flag: show entries from the previous submitted period instead (between second-to-last and last marker, or from start to last marker if only one)
6. The "Last submitted period" context line shows total hours only — no dates breakdown

## Workflow: `submit`

1. Run `summary` workflow first (display the breakdown)
2. Check: is the last line before `---` already a `<!-- SUBMITTED: -->` marker for today with no entries after it? If so, output "Already submitted today, no new entries" and stop
3. Insert `<!-- SUBMITTED: YYYY-MM-DD -->` after the last table row in the current month's timesheet
4. Output: `Submitted. <X.X> hours in this period.`

## Workflow: `audit`

Reconstruct billable work blocks from Claude Code session logs as evidence of hours actually worked. The skill never executes code — the invoking Claude runs the algorithm below deterministically.

### Period argument

`period` (optional, default `today`):

| Period | Meaning |
|--------|---------|
| `today` | System date (default) |
| `yesterday` | System date − 1 |
| `last` | Synonym for `yesterday` |
| `current` | All entries since the last `<!-- SUBMITTED: -->` marker for this project |
| `YYYY-MM` | Full calendar month |
| `YYYY-MM-DD` | A single day |
| `YYYY-MM-DD..YYYY-MM-DD` | Inclusive date range |

All timestamps in the JSONL are UTC ISO8601 (e.g. `2026-05-27T18:05:45.987Z`). Convert to the user's local date (system timezone) before bucketing by day.

### Project → logs-dir mapping

Claude Code stores session JSONL under `~/.claude/projects/<dash-encoded-path>/`, where each `/` in the absolute project path becomes `-`.

```
Project path  /Users/user/src/<project>
Logs dir      ~/.claude/projects/-Users-user-src-<project>/
Files         *.jsonl (one per session)
```

Resolution order (per the Per-Project Config section):
1. `--logs-dir <path>` argument (explicit override)
2. `.agents.json` → `hours.logsDir.<project>` if set
3. `.claude/user-config.json` → `hours.logsDir.<project>` if set
4. Dash-encode `/Users/<user>/src/<project>` → `-Users-<user>-src-<project>`.
5. If the heuristic directory is missing, list candidate directories in `~/.claude/projects/` whose name contains `<project>` and ask the user to disambiguate.

**Merge `extraLogsDirs`.** After resolving the primary logs-dir, append every entry from `.agents.json` → `hours.extraLogsDirs` (and the legacy `.claude/user-config.json` equivalent if present). Read JSONL from all of them. De-duplicate interactions by `uuid` across the union.

### Interaction extraction

For every `.jsonl` file in the resolved logs-dir set, scan each line and keep only entries where ALL of:

- `type == "user"` (or `.message.role == "user"` if `type` is absent)
- `isMeta` is not `true` (excludes system-injected meta messages like `<command-name>` blocks)
- `isSidechain` is not `true` (excludes subagent traffic; the parent session already counts)
- `.message.content` is a string OR an array whose first element's `type` is NOT `tool_result` (excludes tool-result echoes that Claude Code records as synthetic user messages)

Each surviving entry is an "interaction." Collect its `timestamp` (parsed to a UTC instant), its `uuid`, and the text content of `.message.content` (string form, or concatenated text-typed array elements). De-duplicate across sessions by `uuid` if multiple sessions overlap.

### Block detection algorithm

1. Sort all interaction timestamps ascending.
2. Filter to those whose local date falls within the requested period.
3. Walk the sorted list. Start a new block at the first interaction. Continue the current block while the gap from the previous interaction is `<= 10 minutes`. When a gap `> 10 minutes` is encountered, close the current block and start a new one.
4. Block raw duration: `(last_interaction - first_interaction) + 10 minutes` (5 min context before first + 5 min context after last). Even a single-interaction block has 10 min of duration.
5. Round each block independently to the nearest `0.25h` (15-minute increments), with a minimum of `0.25h` (any block counts as at least 15 minutes).
6. Sum rounded block durations for the period total.

### Token tracking (intensity sanity check)

For each block, also sum `.message.usage.input_tokens + .message.usage.output_tokens` across all `type == "assistant"` entries whose timestamp falls between the block's first and last interaction (inclusive). Use `cache_creation_input_tokens` and `cache_read_input_tokens` if present — sum all four. This is informational only; it never adjusts the hours.

### Per-day work-focus summary

For every day in the output, the invoking Claude writes a **one-line, very terse summary** (≤120 chars) of what was approximately worked on that day. Sources, in priority order:

1. The first 1–3 substantive user-interaction texts of the day (skip trivial pings like "yes", "no", "ok").
2. Distinctive file paths, repo names, or feature/ticket IDs mentioned in user prompts.
3. The source mix (hampr-only vs tumble-only vs mixed) — useful framing if the prompts are too sparse to summarize.

Style: comma-separated phrases, sentence-fragment, lowercase except proper nouns/IDs. No marketing voice. Match the diary-line style of existing timesheet `Description` columns.

Examples:
- `Tumble events-store unification kickoff, ADR-0006 smell-test, 6-sidecar collapse design`
- `Hampr nexus housekeeping, /handoff, light tumble check-in`
- `Tumble F015 customer prefs wiring, e2e walkin_pos scenario, HDS theme port`

If a day has fewer than 3 interactions total, emit just the source mix (e.g. `~tumble only, light touch`).

### Output format

```
<project> — audit (2026-05-27)

Focus: Tumble events-store unification kickoff, ADR-0006 smell-test, 6-sidecar collapse design

Block 1  09:14 — 11:42   2.5h    47 interactions (~85k tokens)
Block 2  14:03 — 14:56   0.9h    12 interactions (~22k tokens)
Block 3  19:30 — 22:15   2.8h    63 interactions (~140k tokens)

Audited total: 6.2h  (rounded to 0.25h: 6.25h)

Source: ~/.claude/projects/-Users-user-src-hampr/*.jsonl (3 sessions, 122 interactions)
```

- Times shown in the user's local timezone, `HH:MM` 24-hour.
- The `Focus:` line is the per-day summary (≤120 chars).
- Per-block hours column shows the rounded value (already at 0.25h granularity).
- The "Audited total" line shows the un-rounded sum first, then the sum of rounded blocks in parentheses. The rounded value is what gets written if the user opts in.
- Token counts: format as `~Nk` (round to nearest thousand). Omit the token column if all blocks have zero recorded tokens.
- If the period spans multiple days, group blocks under per-day headings, each with its own `Focus:` line:

```
<project> — audit (2026-05-20..2026-05-22)

2026-05-20
  Focus: Tumble Track A boot, identity-adapter wiring fix, endpoint surface probe
  Block 1  09:14 — 11:42   2.5h    47 interactions (~85k tokens)
2026-05-22
  Focus: Phase 1 gap audit, nexus reframing pass, TODO + NEEDS-TO-KNOW housekeeping
  Block 1  14:03 — 14:56   0.9h    12 interactions (~22k tokens)

Audited total: 3.4h  (rounded to 0.25h: 3.5h)
```

### Prompt and timesheet write

After printing the audit, prompt:

```
Add these as separate entries, one rolled-up entry, or just show the audit?
  1. Separate (N entries)
  2. Rolled-up (1 entry per day)
  3. Show only (no timesheet write)
```

- **Option 1 (Separate):** For each block, append a row to `<project-root>/timesheets/YYYY-MM.md` (one file per month — split across months if the period crosses a boundary). Description: `Claude session work block (audit) — HH:MM–HH:MM — <per-day Focus line>`. Hours: the rounded block duration.
- **Option 2 (Rolled-up):** One row per day with summed rounded hours. Description: `Claude session work blocks (audit) — N blocks, HH:MM–HH:MM total span — <per-day Focus line>`.
- **Option 3 (Show only):** Print the audit and exit without writing.

In all write cases, follow the existing `add` workflow rules (find/create month file, update `**Total:**` line, preserve existing content). Never overwrite an existing entry — append only.

### Idempotency guard

Before writing, scan the target month timesheet for any existing row whose description contains `(audit)` for the same date(s). If present, prompt:

```
This date already has an audit entry. Replace, append, or skip?
  1. Replace (delete existing audit rows for this date, write new)
  2. Append (add new rows alongside existing)
  3. Skip (no write)
```

Default to "Skip" if the user does not respond. This prevents accidental double-billing when the audit is re-run.

### `--from-audit` flag on `add`

`/hours <project> add <amount> <desc> --from-audit` is a convenience. It validates that `<amount>` matches (within 0.25h) the audited total for today. If it does not match, print the audited total and ask whether to proceed with `<amount>` as given or substitute the audited value. The description is taken from the user verbatim; the flag only affects the hours-validation step.

## Creating New Month Files

When current month has no timesheet file:

1. Find most recent timesheet in `<project-root>/timesheets/`
2. Extract project name from its header
3. Create new file:

```markdown
# <ProjectName> Timesheet — YYYY-MM

Project: <project-name>

## Hours

| Date | Hours | Description |
|------|-------|-------------|

---
**Total: 0 hours**
```

## Key Rules

- **Never show rates or dollar amounts.** This tracks hours, not money.
- **Submission markers are HTML comments** — invisible in rendered markdown, parseable by this skill
- **Multiple submits same day = no-op** if no new entries since last submit
- **Cross-month periods are valid** — a submit marker in Feb means March entries before the next marker are "current period"
- **`last` flag** refers to the previous submission period, not the previous calendar month
- **Preserve existing content** — never overwrite or restructure existing timesheet files beyond appending rows and markers
- **Audit is evidence, not authority** — block durations are *suggested* hours grounded in Claude session activity. The user reviews and chooses whether to write them. Never write audit rows without explicit user selection of option 1 or 2.
- **Audit rows are tagged** — every audit-written row's description starts with `Claude session work block(s) (audit)` so it is parseable and de-duplicatable on re-run.
- **Per-project config is one file** — `.agents.json` → `hours.*`. Don't fragment config into multiple files.

## Permissions

**Granted:**
- Read any file in `clients/`, `personal/`, and other `*/timesheets/` trees
- Read `memory/MEMORY.md` for date
- Read `.agents.json` and `.claude/user-config.json` for `hours.*` config
- Read session JSONL under `~/.claude/projects/*/` for `audit` only (no writes there)
- Create timesheet files in `<project-root>/timesheets/`
- Edit timesheet files (append rows, insert markers, update totals)

**Not granted:**
- Modifying any file outside `<project-root>/timesheets/`
- Writing or deleting anything under `~/.claude/projects/`
- Writing `.agents.json` or `.claude/user-config.json` (read-only — the user owns config)
- Showing rates, amounts, or invoice data

- End with `/hours done.`
