# Tech docs/ Templates

Use when creating Tech archetype docs (docs/VISION.md, PROJECT.md, REQUIREMENTS.md, etc.).

---

## docs/VISION.md

```md
# Product Vision
<!-- What users want to accomplish; epic→story live here; use cases = creative catalog -->

## North Star
[Ultimate goal in one sentence]

## Target Users
[Primary and secondary personas]

## Use Cases
[High-level scenarios users want to accomplish; also a catalog to review to spur creative thought]

**Active/Prioritized:** Use cases currently informing epics and stories
- [Use case 1]
- [Use case 2]
- [Use case 3] — **PARKED** [date]: [reason]
- [Use case 4] — **OUT OF SCOPE** [date]: [reason]
- [Use case 5] — **FUTURE**: [note]

**Status annotations:**
- No annotation = active/prioritized
- **PARKED** = not currently prioritized, may revisit
- **OUT OF SCOPE** = rejected or explicitly excluded, preserve for future review
- **FUTURE** = for later consideration
- **EXPLORED** = addressed by existing epic/feature

**Note:** When this section grows large (>15-20 items) or you want to preserve historical/parked use cases, create `docs/USE_CASES.md` for the complete catalog and organize by status sections. Keep active/prioritized ones here for visibility.

## Epics
[Large initiatives; each groups related user stories]
- **[Epic name]:** One-line summary.
  - *As a [persona], I want [goal] so that [benefit].*
  - …

## User Stories
[Same format; prefer listing under Epics above; tag with [Epic: name] if separate]

## Success Metrics
[How we know we're winning]

## Future Possibilities
[Parking lot for ideas not yet prioritized]

## Non-Goals
[What we're NOT building]
```

---

## docs/USE_CASES.md

```md
# Use Cases
<!-- Complete catalog of user scenarios; SEMI-IMMUTABLE, APPEND-ONLY; review to spur creative thought -->

**Purpose:** This file is the **complete catalog** of all use cases—active, parked, future, rejected, out-of-scope, and historical. It serves as a creative resource to review and re-interpret over time, not just as input for current epics.

**CRITICAL - Semi-Immutable Rule:**
- **NEVER delete use cases**, even if rejected, out-of-scope, or superseded
- Move between sections (Active → Parked, Future → Explored, etc.) but ALWAYS preserve
- Rejected/out-of-scope ideas often spark future innovation when reviewed later
- This is a creative catalog for re-reading, not just a planning input

**When to use this file:**
- VISION.md Use Cases section has grown large (>15-20 items)
- You want to preserve historical/parked/rejected use cases for future review
- You need a comprehensive catalog separate from active planning

**Note:** Active/prioritized use cases should remain visible in VISION.md for quick reference. This file captures the **full history** for creative exploration.

---

## Active
Use cases currently informing epics and stories:
- [Use case 1]
- [Use case 2]

## Future
Use cases for later consideration:
- [Use case 3]
- [Use case 4]

## Parked
Previously considered, not currently prioritized (never delete; may revisit):
- [Use case 5] — parked [date]: [reason]

## Out of Scope
Rejected or explicitly out-of-scope (preserve for future re-evaluation):
- [Use case 6] — out of scope [date]: [reason]

## Explored
Historical use cases that informed past decisions (preserve for context):
- [Use case 7] — addressed by [Epic/Feature]: [brief note]

---
**Last reviewed:** [date]
```

---

## docs/PROJECT.md

```md
# Project Status
<!-- What's in scope and when -->

## Milestones
<!-- Convention: E# (Epics) > S# (Stories) > M# (Milestones) + D# (Demos) + F#/N# (Requirements). See docs/CONCEPTS.md Project Taxonomy. -->
| # | Milestone | Status |
|---|-----------|--------|
| M1 | Setup | Pending |

## MVP Scope
[First release scope]

## Current Focus
**Status:** Project initialized
```

---

## docs/REQUIREMENTS.md

```md
# Requirements
<!-- What the system must do -->

## Functional
* F001: [System shall...]

## Non-Functional
* N001: [Performance/security/etc]
```

---

## docs/ARCHITECTURE.md

```md
# Architecture
<!-- How the system is built -->

## Components
* [Component]

## Data Model
[Key entities]

## Design Decisions
* Language/Framework: [Choice and rationale]
```

---

## docs/TODO.md

```md
# Tasks

## Current
* [IN_PROGRESS] Initial setup

## Previous
* None

## Backlog
* [TODO] Future tasks
```

---

## docs/CONCEPTS.md

```md
# Domain Concepts
<!-- Knowledge needed by any contributor -->

## Core Concepts
[Foundational ideas]

## Terminology
[Domain-specific terms]

## How It Works
[Key mechanics]
```
