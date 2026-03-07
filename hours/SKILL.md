---
name: hours
description: |
  Time tracking for client projects. Add hours, submit periods, view summaries.
  TRIGGER when: user says "hours", "log time", "track time", "timesheet"; or "/hours" with args.
  DO NOT TRIGGER: for invoicing, rates, or dollar amounts.
base_skill: none
model_tier: fast
---

# Hours

## Role
Track billable hours across client projects. Add entries, mark submission periods, view summaries. Never shows rates or dollar amounts — that's invoicing.

## Identity Announcement
Skip — this skill is action-only, no preamble.

## Syntax

```
/hours                              # dashboard: all projects with tracked hours
/hours <project>                    # summary for matched project (partial name OK)
/hours <project> add <amount> <desc>
/hours <project> submit [last]
/hours <project> summary [last]
/hours <project> last
```

- No args — scan all `clients/*/timesheets/` and show a one-line-per-project dashboard
- `<project>` alone — equivalent to `summary` (partial match: `stu` matches `studio63`)
- `add` — append a time entry for today
- `submit` — summary + mark current entries as submitted
- `summary` — show current period breakdown
- `last` — shorthand for `summary last` (previous submitted period)
- `last` as modifier on submit/summary — operate on previous period instead of current

## Timesheet Location

`clients/<project>/timesheets/YYYY-MM.md` (current month). Scan all months when computing periods.

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

## Workflow: no args (dashboard)

1. Scan all `clients/*/timesheets/*.md` files
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

Equivalent to `/hours <project> summary`. Partial name matching: find the first `clients/*/` directory whose name contains the input (case-insensitive). If ambiguous (multiple matches), list them and ask.

## Workflow: `add`

1. Resolve today's date from system date
2. Find or create `clients/<project>/timesheets/YYYY-MM.md`
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

## Creating New Month Files

When current month has no timesheet file:

1. Find most recent timesheet in `clients/<project>/timesheets/`
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

## Permissions

**Granted:**
- Read any file in `clients/` directory tree
- Read `memory/MEMORY.md` for date
- Create timesheet files in `clients/<project>/timesheets/`
- Edit timesheet files (append rows, insert markers, update totals)

**Not granted:**
- Modifying any file outside `clients/<project>/timesheets/`
- Showing rates, amounts, or invoice data
