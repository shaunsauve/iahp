# Nexus Templates

Use when creating Nexus archetype files (company/, current/, people/, initiatives/, etc.).

## Conventions

These conventions apply to all Nexus content. Encode them into the README and follow them when creating or updating files.

### Date Everything
- All information stamped with date recorded
- Timelines use `## YYYY-MM-DD` section headers
- Inline updates get `(YYYY-MM-DD)` annotations
- Decision files named `YYYY-MM-DD-topic.md`
- Meeting notes named `YYYY-MM-DD-[type]-subject.md`

### Entity Pattern (Dual-File)
Every tracked entity (person, partner, initiative, company) has **two files**:
- **`entity.md`** — Summary: small, quick-lookup, current state
- **`entity.timeline.md`** — History: append-only, full context, dated entries

### Append-Only Timelines
Never overwrite or delete historical entries. If understanding changes, add a new dated entry explaining the revision. This preserves decision context and reasoning.

### Context Depth (CD) Protocol
Not all information is equal priority. Organize by loading tier:
- **CD1 (always loaded):** NEEDS-TO-KNOW.md, current/critical-changes.md, company/org-chart.md, current/focus.md, TODO.md
- **CD2 (load on mention):** Entity summaries + timelines when a person, initiative, or partner is discussed
- **CD3 (on request):** Archived meetings, competitor deep-dives, historical reference

### Meeting Notes Flow
1. Raw notes captured in `meetings/` with dated filename
2. `distill` processes raw notes into knowledge base areas (decisions/, people/, partners/, strategy/, etc.)
3. Raw notes preserved; distilled insights distributed to appropriate files

---

## NEEDS-TO-KNOW.md (project root, CD1)

The single most important file — loaded every session. Contains the essential context needed to be effective without reading the full knowledge base.

```md
# Need to Know

Tier 1 essentials. This file is loaded every session — keep it concise and current.

---
Last updated: [date]

## Context Depth Protocol

| Tier | Trigger | What to Load |
|------|---------|--------------|
| CD1 | Always | This file, critical-changes.md, org-chart.md, focus.md, TODO.md |
| CD2 | On mention | Entity summary + timeline for any person/initiative/partner discussed |
| CD3 | On request | Archived meetings, competitor analysis, deep reference |

## Company Essentials

- **Name:** [Company name]
- **Founded:** [year]
- **Stage:** [e.g., Pre-Series A, Series B, Public]
- **Team size:** [approximate]
- **Mission:** [one line]

## Core Products / Services

(list key products with current status)

## Key People

(3-5 most important people with role and one-line context)

## Critical Blockers

(numbered list of things currently blocking progress)

## Key Opportunities

(numbered list of current opportunities)

## Technical Stack (Overview)

(brief list of key technologies)

## Decision Framework

(how decisions are evaluated — e.g., key questions, criteria)
```

---

## company/summary.md

```md
# [Company Name]

## Key Facts

- **Founded:** [year]
- **Stage:** [funding stage]
- **Headquarters:** [location]
- **Team size:** [approximate]
- **Industry:** [sector]

## Mission

(one paragraph)

## Products / Services

(list with brief descriptions and current status)

## Strategy (Current Year)

(key strategic priorities)

## Structure

See org-chart.md for current organizational structure.
```

---

## company/org-chart.md

```md
# Organizational Structure

Last updated: [date]

## Leadership

(key leaders with title and responsibilities)

## Teams

(team structure, reporting lines)

## Recent Changes

(significant org changes with dates)
```

---

## current/focus.md

```md
# Current Focus

Active priorities and what's top of mind.

---
Last updated: [date]

## Active Priorities

(none yet)

## This Week

(none yet)
```

---

## current/critical-changes.md

```md
# Critical Changes

Major changes that affect context. Loaded every session (CD1).

Log significant shifts: personnel changes, leadership decisions, partnership changes, strategic pivots. Most recent first.

---
Last updated: [date]

## [date] — [Change summary]

**What changed:** (description)
**Impact:** (what this affects)
**Action needed:** (if any)
```

---

## current/questions.md

```md
# Open Questions

Questions being explored, uncertainties to resolve.

---
Last updated: [date]

## Active Questions

(none yet)

## Parking Lot

(none yet)
```

---

## INDEX.md Template (all index files)

Use this pattern for: `decisions/`, `people/`, `partners/`, `initiatives/`, `strategy/`, `vision/`, `competitors/`, `meetings/`

```md
# [Category] Index

[One-line description]

## Files

| [Key Column] | [Context Columns...] | Last Updated |
|--------------|----------------------|--------------|
| (none yet) | | |

---
Last updated: [date]
```

**Column suggestions by category:**
- **decisions:** Date, File, Topic, Status
- **people:** Name, Company, Role
- **partners:** Company, Relationship, Key Contacts
- **initiatives:** Initiative, Status, Owner
- **strategy/vision:** File, Topic, Summary
- **competitors:** Company, Industry, Key Differentiator
- **meetings:** Date, File, Participants, Key Outcomes

**Naming conventions for files:**
- **decisions:** `YYYY-MM-DD-topic.md` (e.g., `2026-02-11-project-management-tool.md`)
- **meetings:** `YYYY-MM-DD-[type]-subject.md` (e.g., `2026-02-24-team-standup.md`)
- **people:** `firstname-lastname.md` + `firstname-lastname.timeline.md`
- **partners:** `company-name.md` + `company-name.timeline.md`
- **initiatives:** `initiative-name.md` + `initiative-name.timeline.md`

---

## personal/summary.md

```md
# [Your Name] — [Role]

## Role & Expectations

- **Title:** [title]
- **Reports to:** [name, title]
- **Key responsibilities:** (list)

## Goals

(current goals and success criteria)

## Skills & Strengths

(key competencies relevant to the role)

## Communication Style

(how you prefer to communicate; how to adapt for different stakeholders)

## Development Areas

(areas for growth)
```

---

## Entity summary.md Template (people/, partners/, initiatives/)

Use the entity pattern: every tracked entity gets a summary + timeline pair.

```md
# [Entity Name]

[One-line description or role]

## Key Facts

(structured facts appropriate to entity type)

## Current Status

(what's happening now)

## Notes

(additional context, relationship notes, open items)
```

---

## Entity timeline.md Template (all entity types)

Append-only. Never delete entries. Use `## YYYY-MM-DD` section headers.

```md
# [Entity Name] Timeline

Chronological log. Append new entries at the top. Never overwrite or remove past entries.

## [date]

(What happened, decisions made, context captured)
```

---

## company/summary.timeline.md

```md
# [Company Name] Timeline

Chronological log of key company events. Append new entries at the top.

## [date]

(founding, funding, product launches, org changes, strategic shifts)
```

---

## personal/summary.timeline.md

```md
# [Your Name] Timeline

Career and role events. Append new entries at the top.

## [date]

(role changes, key decisions, accomplishments, lessons learned)
```

---

## TODO.md (project root, Nexus)

```md
# Session Tasks

Project-level task tracking for AI-assisted sessions.

---
Last updated: [date]

## Current

- [IN_PROGRESS] Initial setup

## Done

(none yet)

## Backlog

(none yet)
```
