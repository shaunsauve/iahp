---
name: ucc
description: |
  User Context Compact: sync + cleanup for user context targets. Runs UCS first, then compacts. Confirmation required before destructive operations.
  TRIGGER when: user says "ucc", "compact", "clean up context", or wants to sync and compact user context targets.
  DO NOT TRIGGER: for sync-only without compaction (use ucs).
base_skill: baseline
model_tier: standard
---

# User Context Compact (UCC)

## Role
Perform bidirectional sync followed by confirm-first cleanup of user context files. UCC = UCS + compaction in a single flow.

## Core Objective
Keep user context files compact, referenceable, and scannable while ensuring nothing is lost before cleanup.

## Related Skill: `/ucs` (User Context Sync)
UCC **always runs UCS first** before compacting — this ensures bidirectional sync is current before any destructive operations. UCS is the **non-destructive sync** half of the pair; UCC is the **sync + compact** half. Use UCS for frequent, safe synchronization. Use UCC for periodic cleanup after sync.

## .ucs.json Configuration

UCC uses the same `.ucs.json` config as UCS. See `/ucs` for the full spec.

```json
{
  "targets": [
    {
      "type": "obsidian",
      "path": "/path/to/vault/Projects/ProjectName TODO.md",
      "label": "ProjectName TODO"
    }
  ]
}
```

**On startup:**
1. Look for `.ucs.json` in the project root.
2. If found, use declared targets.
3. If missing, prompt user for target path (backward compatibility).

## Confirmation Requirement (Mandatory)
Never run cleanup automatically.

Before making edits, show a dry-run summary and ask for confirmation. Include:
- Completed checkbox count to remove
- Minute/note sections considered stale (with triage checkbox preview)
- Sections to compact or archive
- Items that would receive new `[ ]` triage checkboxes

Proceed only after user confirmation.

## Safety Rules
- Preserve top-level flow and recognizable section structure.
- Do not alter active unchecked items unless user requested reorganization.
- Preserve wording of active critical items where possible.
- Keep a clear trail for moved/distilled content.

## Distill-First Rule for Minutes/Notes
If old raw minutes are detected:
1. Check whether already distilled into repo knowledge base.
2. If not distilled, distill first (meeting file + routing to entities/decisions).
3. Only then remove/archive from user context file.

Never delete undistilled meeting content.

## Workflow

### Phase 1: Sync (runs UCS)
1. Execute full bidirectional sync per `/ucs` workflow (includes snapshot update to `last.md`).
2. Report sync results before proceeding to compaction.

### Phase 2: Pre-Compact Snapshot
1. Read target user context file (post-sync state).
2. Save a copy to `.uc/snapshots/<target-label>/pre-compact.md` (overwrites previous pre-compact snapshot).
3. This preserves the full file state before any destructive compaction — recoverable if needed.

### Phase 3: Compact (after sync + snapshot)
1. Produce dry-run plan with counts and candidate operations.
2. Ask for explicit user confirmation.
3. Execute cleanup with minimal structural disruption.
4. **Update `last.md`** snapshot with the post-compact target content (so next sync diffs against the compacted version).
5. Report what changed and what was preserved.

## Cleanup Operations
After confirmation, perform selected operations:

### 1. Clear completed items
Remove completed checklist items (`[x]`).

### 2. Add triage checkboxes
Add `[ ]` in front of minutes, notes, and raw capture items that don't already have checkboxes. This allows the user to mark items for cleanup in the next cycle.

### 3. Distill or archive old minutes
Remove or archive old minutes already distilled into the repo knowledge base.

### 4. Compact long sections
Keep only active, actionable lines. Prefer short bullets over prose blocks.

### 5. Normalize formatting
Stabilize spacing, heading order, and bullet style.

### 6. Optional "Active Now" section
If the file is fragmented, optionally add a short "Active Now" section at top.

## Compaction Heuristics
- Keep newest and highest-leverage items visible.
- Prefer short bullets over prose blocks.
- Keep one canonical location for each active item (avoid duplicates).
- Maintain predictable scanning order used by the user.

## Suggested Command Shapes
- `ucc` -> sync + analyze and propose compaction plan (no destructive edits yet)
- `ucc confirm` -> execute previously proposed compaction
- `ucc [section]` -> compact only specific section after confirmation

## Transport Abstraction

UCC uses the same transport-agnostic vocabulary as UCS:

| Concept | Meaning |
|---------|---------|
| **Target** | A destination/source for sync (declared in `.ucs.json`) |
| **Transport** | The mechanism for reading/writing a target (obsidian, slack, email) |
| **Compact** | Transport-specific cleanup (obsidian: edit file; slack: archive thread; email: digest) |

Currently only the `obsidian` transport is implemented. For future transports, "compact" will have transport-specific meaning:
- **Obsidian:** Edit file in place (clear items, add checkboxes, reformat)
- **Slack:** Archive old threads, summarize channels (future)
- **Email:** Send digest with cleanup summary (future)
