# Nexus Multi-Client Templates

Use when creating Nexus multi-client archetype (consulting, advisory, portfolio management).

Context is **client-scoped** — most depth lives inside `clients/{name}/`. Top level is a lightweight portfolio view. If firm-level complexity grows, create a separate single-org Nexus for the firm.

## Conventions

Inherits all conventions from nexus-templates.md (date everything, entity pattern, append-only timelines, meeting flow). Additional multi-client conventions:

### Client-Scoped Context
- Each client is a self-contained subdirectory under `clients/`
- People, decisions, meetings, and initiatives are per-client
- Top-level files track cross-client concerns only

### CD Protocol (Multi-Client)
- **CD1 (always):** NEEDS-TO-KNOW.md, current/focus.md, current/critical-changes.md, TODO.md
- **CD2 (on client mention):** `clients/{name}/summary.md` + `clients/{name}/focus.md`, then deeper into people/, decisions/, meetings/ as needed
- **CD3 (on request):** Archived meetings, deep engagement history

---

## NEEDS-TO-KNOW.md (project root, CD1)

Portfolio dashboard — lighter than single-org variant. Focused on cross-client status.

```md
# Need to Know

Portfolio dashboard. Loaded every session — keep it concise and current.

---
Last updated: [date]

## Context Depth Protocol

| Tier | Trigger | What to Load |
|------|---------|--------------|
| CD1 | Always | This file, current/focus.md, current/critical-changes.md, TODO.md |
| CD2 | Client mentioned | clients/{name}/summary.md + clients/{name}/focus.md, then deeper as needed |
| CD3 | On request | Archived meetings, deep engagement history |

## Active Engagements

| Client | Status | Engagement Type | Key Contact | Next Action |
|--------|--------|-----------------|-------------|-------------|
| (none yet) | | | | |

## Key Dates

(cross-client deadlines, renewals, milestones)

## Portfolio Risks

(numbered list of risks across the portfolio)
```

---

## current/focus.md

```md
# Current Focus

Which clients need attention and firm-level priorities.

---
Last updated: [date]

## Client Priorities

(which clients need attention this week and why)

## Internal Priorities

(firm-level items: hiring, tools, processes)

## This Week

(none yet)
```

---

## current/critical-changes.md

```md
# Critical Changes

Major changes across the portfolio. Loaded every session (CD1). Most recent first.

---
Last updated: [date]

## [date] — [Change summary]

**Client:** [client name or "Firm-level"]
**What changed:** (description)
**Impact:** (what this affects)
**Action needed:** (if any)
```

---

## current/questions.md

```md
# Open Questions

Cross-client and firm-level questions.

---
Last updated: [date]

## Active Questions

(none yet)

## Parking Lot

(none yet)
```

---

## clients/INDEX.md

```md
# Client Index

All client engagements.

## Active

| Client | Engagement Type | Status | Key Contact | Started | Last Updated |
|--------|-----------------|--------|-------------|---------|--------------|
| (none yet) | | | | | |

## Completed

| Client | Engagement Type | Completed | Notes |
|--------|-----------------|-----------|-------|
| (none yet) | | | |

---
Last updated: [date]
```

---

## clients/{client-name}/summary.md

```md
# [Client Name]

[One-line engagement description]

## Engagement

- **Type:** [consulting, advisory, implementation, etc.]
- **Status:** [active, onboarding, winding down, completed]
- **Started:** [date]
- **Contract end:** [date or ongoing]

## Key Contacts

| Name | Role | Notes |
|------|------|-------|
| (none yet) | | |

## Scope

(what we're doing for this client)

## Current Status

(what's happening now)
```

---

## clients/{client-name}/summary.timeline.md

```md
# [Client Name] Timeline

Engagement history. Append new entries at the top. Never overwrite or remove past entries.

## [date]

(engagement start, key milestones, decisions, status changes)
```

---

## clients/{client-name}/focus.md

```md
# [Client Name] — Current Focus

Active priorities for this engagement.

---
Last updated: [date]

## Active Priorities

(none yet)

## This Week

(none yet)
```

---

## clients/{client-name}/people/INDEX.md

```md
# [Client Name] People

Client-side stakeholders and contacts.

| Name | Role | Notes | Last Updated |
|------|------|-------|--------------|
| (none yet) | | | |

---
Last updated: [date]
```

---

## clients/{client-name}/decisions/INDEX.md

```md
# [Client Name] Decisions

Decisions made on this engagement. Files named `YYYY-MM-DD-topic.md`.

| Date | File | Topic | Status |
|------|------|-------|--------|
| (none yet) | | | |

---
Last updated: [date]
```

---

## clients/{client-name}/meetings/INDEX.md

```md
# [Client Name] Meetings

Meeting notes. Files named `YYYY-MM-DD-[type]-subject.md`.

| Date | File | Participants | Key Outcomes |
|------|------|--------------|--------------|
| (none yet) | | | |

---
Last updated: [date]
```

---

## clients/{client-name}/initiatives/INDEX.md

```md
# [Client Name] Initiatives

Workstreams within this engagement.

| Initiative | Status | Owner | Last Updated |
|------------|--------|-------|--------------|
| (none yet) | | | |

---
Last updated: [date]
```

---

## personal/summary.md

Same as single-org variant — see nexus-templates.md.

---

## personal/summary.timeline.md

Same as single-org variant — see nexus-templates.md.

---

## TODO.md (project root)

```md
# Session Tasks

Portfolio-level task tracking for AI-assisted sessions.

---
Last updated: [date]

## Current

- [IN_PROGRESS] Initial setup

## Done

(none yet)

## Backlog

(none yet)
```
