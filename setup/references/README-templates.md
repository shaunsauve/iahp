# README and Pointer Templates

Use when creating or updating project README and pointer files per archetype.

---

## Tech README

```md
# ProjectName

One-line description.

## Quick Start

    command --flag  # Brief description

## Setup & Installation
[Language-specific install commands]

## How to Run
[Run commands]

## How to Test
[Test commands]

## Project Structure

```
project/
├─ docs/
│  ├─ VISION.md          # Product goals, epics, use cases (creative catalog), user stories (epic→story→task)
│  ├─ USE_CASES.md       # (optional) Use case tracker; append-only; review to spur ideas
│  ├─ PROJECT.md         # Milestones and current focus
│  ├─ REQUIREMENTS.md    # Functional (F001…) and non-functional requirements; trace to epic/story
│  ├─ ARCHITECTURE.md    # System design and decisions
│  ├─ CONCEPTS.md        # Domain terminology and how it works
│  └─ TODO.md            # Current task and backlog; tasks trace to F001/epic/story
├─ lib/                  # Source code (or src/, app/ per language)
├─ bin/                  # Entry points
├─ tests/                # Test files and fixtures
├─ README.md             # Project overview
├─ CLAUDE.md             # Skill pointers
├─ GEMINI.md             # Skill pointers
└─ CODEX.md              # Skill pointers
```

## Current Focus
See docs/TODO.md for active tasks.
```

---

## Nexus README

```md
# [Project Name]

[Role] knowledge repository for **[Company]**. All content is **highly confidential**.

## Quick Start

Invoke `/executive-advisor` for all protocols, formats, and workflows.

## Details

- **Role**: [Your role]
- **Company**: [Company name]
- **Leadership**: [Key leaders] (see `people/`)

## Key Conventions

- **Date everything:** Timelines use `## YYYY-MM-DD` headers; updates get `(YYYY-MM-DD)` annotations
- **Append-only timelines:** Never overwrite historical entries; add dated corrections if understanding changes
- **Entity pattern:** Every entity has `entity.md` (summary) and `entity.timeline.md` (append-only history)
- **Meeting notes flow:** Raw notes in `meetings/` → distill into knowledge base areas (decisions/, people/, strategy/, etc.)
- **Context Depth:** CD1 = always loaded; CD2 = load on mention; CD3 = load on request

## Context Depth Protocol

| Tier | Trigger | Load |
|------|---------|------|
| CD1 | Always | NEEDS-TO-KNOW.md, critical-changes.md, org-chart.md, focus.md, TODO.md |
| CD2 | On mention | Entity summary + timeline for any person/initiative/partner discussed |
| CD3 | On request | Archived meetings, competitor analysis, deep reference |

## Project Structure

```
project/
├─ NEEDS-TO-KNOW.md      # CD1: Essentials loaded every session
├─ company/              # Company info, org chart, timeline
├─ current/              # Active priorities, critical changes, open questions
├─ decisions/            # Major decisions (YYYY-MM-DD-topic.md)
├─ meetings/             # Raw meeting notes (YYYY-MM-DD-[type]-subject.md)
├─ competitors/          # Competitive analysis (CD3)
├─ partners/             # External companies, vendors
├─ people/               # All people (entity.md + entity.timeline.md)
├─ personal/             # Role context and career
├─ initiatives/          # Initiatives, workstreams
├─ strategy/             # Strategy and positioning
├─ vision/               # Tech vision, roadmap
├─ TODO.md               # Session task tracking
├─ README.md             # Project overview
├─ CLAUDE.md             # Skill pointers
├─ GEMINI.md             # Skill pointers
└─ CODEX.md              # Skill pointers
```
```

---

## Nexus Multi-Client README

```md
# [Project Name]

[Role] client portfolio for **[Your Firm]**. All content is **highly confidential**.

## Quick Start

Invoke `/executive-advisor` for all protocols, formats, and workflows.

## Details

- **Role**: [Your role]
- **Firm**: [Your firm name]

## Key Conventions

- **Client-scoped context:** Most depth lives inside `clients/{name}/`; top level is portfolio view
- **Date everything:** Timelines use `## YYYY-MM-DD` headers; updates get `(YYYY-MM-DD)` annotations
- **Append-only timelines:** Never overwrite historical entries
- **Entity pattern:** Every entity has `entity.md` (summary) and `entity.timeline.md` (append-only history)
- **Meeting notes flow:** Raw notes in `clients/{name}/meetings/` → distill into client knowledge areas

## Context Depth Protocol

| Tier | Trigger | Load |
|------|---------|------|
| CD1 | Always | NEEDS-TO-KNOW.md, current/focus.md, current/critical-changes.md, TODO.md |
| CD2 | Client mentioned | `clients/{name}/summary.md` + `clients/{name}/focus.md`, then deeper as needed |
| CD3 | On request | Archived meetings, deep engagement history |

## Project Structure

```
project/
├─ NEEDS-TO-KNOW.md      # CD1: Portfolio dashboard
├─ current/              # Firm-level priorities and changes
├─ clients/              # One directory per client engagement
│  ├─ INDEX.md           # Client roster
│  └─ {client-name}/     # Per-client: summary, focus, people/, decisions/, meetings/, initiatives/
├─ personal/             # Role context and career
├─ TODO.md               # Session task tracking
├─ README.md             # Project overview
├─ CLAUDE.md             # Skill pointers
├─ GEMINI.md             # Skill pointers
└─ CODEX.md              # Skill pointers
```
```

---

## Admin README

```md
# [Project Name]

[One-line description of the initiative]

## Quick Start

Invoke `/administrative-advisor` for all protocols and workflows.

## Goals

See GOALS.md for success criteria and deadlines.

## Current Status

See TODO.md for active tasks.

## Project Structure

```
project/
├─ TODO.md              # Tasks: current, done, backlog
├─ GOALS.md             # Success criteria, deadlines
├─ NOTES.md             # Research, decisions, reference
├─ LOG.md               # Chronological activity log
├─ contacts/            # Project-specific people/vendors
├─ inbox/               # Documents received
├─ outbox/              # Documents sent
├─ reference/           # Supporting docs, templates
├─ README.md            # Project overview
├─ CLAUDE.md            # Skill pointers
├─ GEMINI.md            # Skill pointers
└─ CODEX.md             # Skill pointers
```
```

---

## Philosophy: Single Source of Truth

**AGENTS.md is the single source of truth for LLM instructions.** All other pointer files (CLAUDE.md, GEMINI.md, CODEX.md, .cursor/rules) should be minimal and just point to AGENTS.md. This prevents:
- Duplicated instructions that drift out of sync
- Confusion about which file has the authoritative instructions
- Maintenance burden of updating multiple files

**Two scenarios for skill location:**
1. **Submodule present** (`iahp/` exists with AGENTS.md): Use `iahp/` for all skill references and permissions
2. **Global skills** (no submodule): Use `~/.claude/skills/` for all skill references and permissions

---

## CLAUDE.md (all archetypes)

```md
**STOP.** Read **AGENTS.md** first. Follow its instructions exactly before doing anything else.
```

---

## GEMINI.md (all archetypes)

Same as CLAUDE.md — simple pointer.

```md
Read **AGENTS.md** first. Be terse until a skill is loaded.
```

---

## CODEX.md (all archetypes)

Same as CLAUDE.md — simple pointer.

```md
Read **AGENTS.md** first. Be terse until a skill is loaded.
```

---

## AGENTS.md (submodule version)

Use when `iahp/` submodule exists with AGENTS.md inside.

```md
# Agent Entry Point

Read **iahp/AGENTS.md** for skill library.

**Permissions:** Read freely from `./iahp/`

**Rules:** Be terse until a skill is loaded. Ask which skill to use. Wait after transitions.
```

---

## AGENTS.md (global version)

Use when no submodule exists (uses `~/.claude/skills/`).

```md
# Agent Entry Point

Read **~/.claude/skills/AGENTS.md** for skill library.

**Permissions:** Read freely from `~/.claude/skills/`

**Rules:** Be terse until a skill is loaded. Ask which skill to use. Wait after transitions.
```
