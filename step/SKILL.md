---
name: step
base_skill: baseline
model_tier: standard
description: |
  Interactive step-through mode for decisions, action items, or review points. Presents items one at a time, waits for explicit advance. Layers onto the active skill without replacing it.
  TRIGGER when: user says "step", "step through", "walk me through", "one by one", or a skill produces a list of decisions/actions/findings that need individual attention.
  DO NOT TRIGGER: for sequential task execution (use conductor) or automated batch processing.
---

# Step

## Role

Overlay mode that takes a list of items (decisions, action items, audit findings, review points, directions) and presents them one at a time. The active skill stays loaded — step just controls pacing. When step ends, the active skill continues normally.

## Identity Announcement

Skip — this is a mode, not a takeover. Announce entry with: `Stepping through N items. Say next/n to advance, back/b to revisit, skip to skip, stop to exit step mode.`

## Entering Step Mode

Step mode activates when:
1. User says `/step` with items already produced in conversation (use the most recent list)
2. User says `/step` with inline items: `/step "fix A" "fix B" "fix C"`
3. A skill explicitly hands off a list: "Stepping through the findings..."
4. User says "step through these", "one by one", "walk me through"

## Item Presentation

For each item, output:

```
[N/total] ITEM_TITLE_OR_SUMMARY

DETAILS_OR_CONTEXT
(expanded from the source list — show what's needed to make a decision)

> next/n · back/b · skip · do · explore · stop
```

- **Title** comes from the source list item
- **Details** expand on the item enough for the user to decide. If the item references files or code, show the relevant snippet.
- Keep it concise — the user can say `explore` to go deeper

## Commands (Step Mode Only)

| Command | Action |
|---------|--------|
| next, n | Advance to next item |
| back, b, previous, p | Return to previous item |
| repeat, r | Show current item again |
| skip | Mark item as skipped, advance |
| do | Execute/apply the current item now (using the active skill's capabilities), then hold on this item for confirmation before advancing |
| explore | Dive deeper — show more context, read referenced files, explain tradeoffs |
| tweak [instruction] | Modify the proposed action before applying (e.g., "tweak use snake_case instead") |
| stop | Exit step mode, return to active skill. Summarize: done/skipped/remaining |
| status | Show progress: N done, N skipped, N remaining |

## Behavior Rules

1. **One item at a time.** Never present multiple items or batch-apply.
2. **Hold until explicit advance.** Do not proceed on any signal other than `next`, `skip`, `do` (after completion), or `stop`.
3. **Preserve active skill.** Step does not change the loaded skill. Any `do` action executes under the active skill's rules, permissions, and constraints.
4. **Respect exploration.** When user says `explore`, go as deep as needed — read files, show diffs, explain context. Stay on the current item until they advance.
5. **Tweak before doing.** `tweak` modifies the proposed action. Show the revised plan, then wait for `do` or `next`.
6. **Summarize on exit.** When user says `stop` or all items are exhausted, output a summary:
   ```
   Step complete: N applied, N skipped, N remaining.
   ```
   If items remain, note: `Resume with /step to continue from item N.`
7. **No side effects without `do`.** Presenting an item is read-only. Only `do` causes changes.

## Sourcing Items

Step mode works with any ordered list. Common sources:
- Audit findings (from skill-manager, reviewer, sast)
- Decisions pending (from architect, visionary)
- Action items (from gate, conductor)
- Inline user-provided lists
- Any numbered or bulleted list in the conversation

When entering step mode, identify the source list and confirm: `Found N items from [source]. Starting at 1.`

If the source is ambiguous (multiple lists in conversation), ask: `Which list? I see [brief description of each].`
