## Entry Formats

### Summary files (`entity.md`)
Current facts, key info. May be updated when facts change.

```markdown
# [Entity Name]

Type: [Person | Partner | Project]
Status: [Active | Inactive | etc.]

## Key Facts
- Fact 1
- Fact 2

## [Entity-specific sections]
```

### Timeline files (`entity.timeline.md`)
Chronological history. Append-only.

```markdown
# [Entity Name] - Timeline

## YYYY-MM-DD

[What happened, was observed, or changed]

## YYYY-MM-DD

[Earlier entry]
```

### People - Summary
```markdown
# [Full Name]

Company: [Internal | Partner: company-name]
Role: [Current role]
Reports to: [[manager-name]]
Expertise: [Skills, domains]
Personality: [Working style, communication preferences]

## Key Facts
- [Notable accomplishments, history, context]
```

### People - Timeline
```markdown
# [Full Name] - Timeline

## YYYY-MM-DD

[Interactions, observations, role changes, feedback]
```

### Partners - Summary
```markdown
# [Company Name]

Relationship: [Vendor | Partner | Integration | Service provider]
What they do: [Brief description]
How we use them: [Our use case]
Key contacts: [[person-name]], [[person-name]]
Status: [Active | Evaluating | Former]

## Key Facts
- [Contract details, pricing tier, important history]
```

### Partners - Timeline
```markdown
# [Company Name] - Timeline

## YYYY-MM-DD

[Meetings, issues, changes, decisions]
```

### Initiatives - Summary
```markdown
# [Initiative Name]

Status: [Active | Complete | Abandoned]
Owner: [[person-name]]
Team: [[person-name]], [[person-name]]
Tech: [Key technologies]

## Goals
- [What we're trying to achieve]

## Current State
[Brief status]

## Outcome (for complete/abandoned)
[Results, lessons learned, reason for abandonment]
```

### Initiatives - Timeline
```markdown
# [Initiative Name] - Timeline

## YYYY-MM-DD

[Progress, blockers, decisions, milestones]
```

### Decision files
```markdown
# [Decision Topic]

Date: YYYY-MM-DD
Status: [proposed | decided | revisited]

## Context
[What prompted this decision]

## Options Considered
1. [Option A] — [tradeoffs]
2. [Option B] — [tradeoffs]

## Decision
[What was decided and why]

## Outcome
[Results, added later as dated entries]
```

### TODO.md (Session Context)
```markdown
# Session Context

Last session: YYYY-MM-DD

## In Progress
- [What was being worked on]

## Open Threads
- [Unfinished conversations, pending decisions]

## Next Session
- [Suggested starting points]
```

**Note:** This tracks repository-level session state, not entity tasks.


## INDEX.md Protocol

Each INDEX.md contains:
- Brief description of section purpose
- Table of files with one-line summaries
- Last updated date for each entry

Update INDEX.md whenever adding or modifying files in that section.

```markdown
# [Section] Index

[Brief description]

## Files

| File | [Key columns...] | Last Updated |
|------|------------------|--------------|
| name.md | ... | YYYY-MM-DD |
```

### Initiatives INDEX.md
```markdown
# Initiatives Index

All projects and initiatives: active, complete, and abandoned.

## Active

| Initiative | Owner | Brief Status | Last Updated |
|------------|-------|--------------|--------------|
| name.md    | ...   | ...          | YYYY-MM-DD   |

## Complete

| Initiative | Owner | Outcome | Completed |
|------------|-------|---------|-----------|

## Abandoned

| Initiative | Owner | Reason | Abandoned |
|------------|-------|--------|-----------|
```


