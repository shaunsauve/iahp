---
name: ucs
description: |
  User Context Sync: bidirectional sync between repo context and user context targets (Obsidian, future: Slack, email). Reads .ucs.json for target locations.
  TRIGGER when: user says "ucs", "sync context", or wants bidirectional sync with user context targets.
  DO NOT TRIGGER: for compaction/cleanup (use ucc).
base_skill: baseline
model_tier: standard
---

# User Context Sync (UCS)

## Role
Bidirectional synchronization between repository context and user context targets. Push project information outbound; distill unseen changes from user context inbound.

## Core Objective
Keep repo context and user context in lockstep so the user's day-to-day operating environment reflects current project state, and any user-captured notes flow back into the repo knowledge base.

## Related Skill: `/ucc` (User Context Compact)
UCS is the **non-destructive sync** half of the pair. `/ucc` is the **sync + compact** half: it runs UCS first, then performs destructive cleanup (clear completed items, add triage checkboxes, reformat). Use UCS for frequent, safe synchronization. Use UCC for periodic cleanup after sync.

## .ucs.json Configuration

Each project declares sync targets in `.ucs.json` at the project root:

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

**Supported transport types:**
| Type | Status | Description |
|------|--------|-------------|
| `obsidian` | Implemented | Read/write local markdown file in Obsidian vault |
| `slack` | Future | Post to Slack channel |
| `email` | Future | Send digest email |

**On startup:**
1. Look for `.ucs.json` in the project root.
2. If found, use declared targets.
3. If missing, prompt user for target path (backward compatibility).

## Snapshot Directory (`.uc/`)

UCS maintains local snapshots of user context targets for change detection and recovery. The `.uc/` directory lives at the project root and **must be gitignored**.

### Directory Structure

```
.uc/
  snapshots/
    <target-label>/
      last.md            # Last known copy (overwritten every sync)
      pre-compact.md     # Copy before most recent compaction (overwritten every compact; managed by UCC)
```

- **`<target-label>`**: Derived from the target's `label` field in `.ucs.json`, lowercased with spaces replaced by hyphens (e.g., `"apx TODO"` → `apx-todo`).
- **`last.md`**: Snapshot of the target file taken at the **start** of each sync, before any edits. Represents "what the file looked like last time we saw it."
- **`pre-compact.md`**: Snapshot taken by `/ucc` before compaction. See UCC skill for details.

### Snapshot Lifecycle

| Event | `last.md` | `pre-compact.md` |
|-------|-----------|-------------------|
| UCS sync starts | Overwritten with current target content | Untouched |
| UCC compact starts | Already updated by UCS phase | Overwritten with current target content (post-sync, pre-compact) |

### Change Detection

On inbound sync, if `last.md` exists for the target:
1. Read `last.md` (previous snapshot).
2. Read current target file.
3. Diff the two to identify **only what changed** since last sync.
4. Report changes as: new lines added, lines removed, checkbox state changes.
5. Route only the **new/changed** content inbound (not the entire file).

If `last.md` does not exist (first sync), treat the entire target as new input — but still create the snapshot after reading.

### Setup

The `.uc/` directory is created automatically on first sync if it doesn't exist. Ensure `.uc/` is in the project's `.gitignore`.

## Distill-and-Mark (`@dam`)

The `@dam` marker signals: "once this content is routed inbound, check it off in the target file."

### Placement

| Placement | Effect |
|-----------|--------|
| On a checkbox line: `- [ ] fix payment flow @dam` | That single item is checked off after routing |
| On a heading: `# Hani call @dam` | All unchecked items (`[ ]`) under that heading are checked off after routing |

Heading-level `@dam` applies to all items until the next heading of the same or higher level.

### Behavior

1. During **inbound sync**, identify all `@dam`-marked items/sections.
2. Route the content inbound as normal (to repo canonical locations).
3. **After successful routing**, flip `[ ]` → `[x]` for marked items in the target file.
4. The `@dam` marker itself is left in place (stripped later by `/ucc` if desired).
5. Report which items were auto-checked in the sync summary.

### Constraints

- Only applies during inbound sync — never during outbound.
- Only flips unchecked → checked (`[ ]` → `[x]`). Never unchecks.
- If routing fails or is ambiguous (user asked for clarification), do **not** check off — wait until confirmed.
- Items already `[x]` are ignored (no double-processing).

## Safety Rules (Non-Negotiable)

### Shared System Guard (CRITICAL)
- **NEVER write repo content to shared/team-visible systems** (Notion, Slack, email, wikis, shared docs) without explicit user permission per content block.
- Obsidian targets are user-private and exempt from this guard.
- If a `.ucs.json` target points to a shared system, treat every outbound write as gated: present the content, get approval, then write.
- Strip sensitive content (personnel assessments, compensation, private directives) even when permission is granted.
- When in doubt, ask before writing.

### Outbound (repo -> target)
- Treat user context as user-owned.
- Keep existing section order unchanged.
- Keep existing checkbox order unchanged.
- Never flip checkbox state (`[x]` stays `[x]`, `[ ]` stays `[ ]`).
- Never remove content during sync.
- Make minimal edits; prefer appending within an existing relevant section.
- Preserve heading names and visual structure.

### Inbound (target -> repo)
- Do not overwrite existing repo content.
- Route new information to canonical locations (see Inbound Routing below).
- Report what was routed and where after sync.
- When in doubt about routing, ask the user.
- **Exception — `@dam` marking:** After successful inbound routing, `@dam`-marked items may be checked off in the target file. See `@dam` section above.

## Inputs
- **Outbound source:** Project knowledge from repo files (`current/`, `initiatives/`, `decisions/`, `meetings/`, TODO.md, etc.)
- **Inbound source:** User context target file(s) as declared in `.ucs.json`
- **Optional scope:** User-provided filter (e.g., "stakeholder talking points", "this week", "only open blockers")

## Workflow

### 1. Load Configuration
- Read `.ucs.json` for targets.
- If missing, prompt user for target path.
- Ensure `.uc/snapshots/<target-label>/` directory exists (create if needed).

### 2. Snapshot & Diff (before sync)
For each target:
1. Read the current target file fully.
2. Check for existing snapshot at `.uc/snapshots/<target-label>/last.md`.
3. **If snapshot exists:** Diff current file against snapshot. Identify:
   - New lines / sections added
   - Lines removed or edited
   - Checkbox state changes (`[ ]` → `[x]` or vice versa)
   - Report the diff summary to the user before routing.
4. **If no snapshot (first sync):** Treat entire file as new input; note this in the report.
5. **Save snapshot:** Overwrite `.uc/snapshots/<target-label>/last.md` with the current target file content.

### 3. Inbound Sync (target -> repo)
Scan user context target for items/changes not yet reflected in repo:
1. Use the diff from Step 2 to identify **only new/changed content** since last sync.
2. If no previous snapshot, fall back to full-file analysis (flag as first-time sync).
3. Auto-route new/changed content to canonical repo files (see Inbound Routing).
4. **`@dam` pass:** After routing, scan for `@dam`-marked items/headings. For each successfully routed item, flip `[ ]` → `[x]` in the target file. Skip any item whose routing was ambiguous or deferred.
5. Report what was found, what changed, where it was routed, and which items were auto-checked.

### 4. Outbound Sync (repo -> target)
Push repo-derived information to the user context target:
1. Read the target file fully before editing.
2. Build a minimal export patch:
   - Prefer existing sections over creating new ones.
   - If section missing, add one compact section without disturbing surrounding order.
3. Validate patch safety:
   - No reordered existing lines
   - No deleted lines
   - No changed checkbox states
4. Apply patch.
5. **Update snapshot:** Overwrite `.uc/snapshots/<target-label>/last.md` with the post-edit target content (so next sync diffs against the outbound-updated version).
6. Report exactly what was added and where.

## Inbound Routing

Content analysis determines destination:
| Content Type | Destination |
|-------------|-------------|
| Action items, tasks | `TODO.md` |
| Decisions made | `decisions/` (new file or append) |
| Status updates, priorities | `current/focus.md` |
| People observations | `people/<name>.timeline.md` |
| Initiative updates | `initiatives/<name>.timeline.md` |
| General notes, context | `TODO.md` (open threads section) |

When routing is ambiguous, present the item and ask the user where it belongs.

## Formatting Rules
- Keep updates concise and scannable.
- Match existing style (heading depth, bullet/number style, spacing).
- Add new items in-place under the most relevant existing heading.
- If dates are included, use `YYYY-MM-DD`.

## Suggested Command Shapes
- `ucs` -> full bidirectional sync (inbound + outbound) with all configured targets
- `ucs [topic]` -> sync only that scope
- `ucs [person] talking points` -> sync prep list for a person
- `ucs inbound` -> inbound only (target -> repo)
- `ucs outbound` -> outbound only (repo -> target)

## Out-of-Scope
- Do not perform cleanup/compaction here.
- Do not remove checked items.
- Do not reorganize existing sections.
- Do not add triage checkboxes to notes/minutes.

Use `/ucc` for cleanup, compaction, and triage operations.

## Transport Abstraction

UCS is designed around a transport-agnostic vocabulary:

| Concept | Meaning |
|---------|---------|
| **Target** | A destination/source for sync (declared in `.ucs.json`) |
| **Transport** | The mechanism for reading/writing a target (obsidian, slack, email) |
| **Inbound** | Information flowing from user context into the repo |
| **Outbound** | Information flowing from the repo to user context |
| **Sync direction** | `inbound`, `outbound`, or `both` (default) |

Currently only the `obsidian` transport is implemented (read/write local markdown file). Future transports will differ in what "sync" means operationally (file edit vs message post vs email send) but follow the same directional model.
