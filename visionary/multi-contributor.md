# Multi-Contributor Visionary Extensions

Load this file when working with multiple contributors on vision and product direction.

## When to Use

**Auto-detect triggers:**
- Git history shows multiple authors in docs/
- User mentions "we," "team," or specific contributor names
- User explicitly requests collaboration features

**Manual load:** Command `collab`

**Single contributor:** Don't load this file; core workflow remains unchanged.

---

## Contributor Attribution

**Purpose:** Surface recent additions for awareness and visibility in AI-driven collaboration (not approval workflow).

**Git preserves authorship** — attribution here is for awareness, not permanent tracking. Use sparingly to avoid clutter.

### Contributors Legend

On first multi-contributor detection, add a minimal legend at top of VISION.md:

```markdown
# Product Vision
<!-- Contributors: @ss=Shaun, @bh=Bob -->
```

Or visible if helpful:
```markdown
# Product Vision
**Contributors:** @ss, @bh
```

**Auto-generate handles from git:**
- Extract author names: `git log --format="%an" docs/VISION.md | sort -u`
- Derive handles: First initial + last initial → @ss, @bh
- Or first names if preferred: @shaun, @bob
- User can edit legend for different handles

### Attribution Syntax

**Inline suffix:** `@handle` (minimal, short)

**Purpose:** Surface recent additions for awareness, not approval workflow.

✓ **Attribute when:**
- New additions to bring to other contributors' attention
- Surfacing changes in AI-driven flow (instead of "git pull")
- Conflicting ideas requiring discussion
- Context helpful (who's driving what)

✗ **Omit when:**
- Everyone already aware (discussed or integrated)
- Obvious from context (e.g., all items in "Bob's Epic")
- Attribution no longer provides useful context
- Can be removed naturally over time as items integrate

**Examples (elegant, minimal):**
```markdown
## Use Cases
- Upload CSV and visualize instantly      ← agreed, no attribution
- Connect to SQL databases @ss            ← new proposal from Shaun
- Export reports to PDF @bh               ← Bob's proposal
- Natural language queries [NEEDS DISCUSSION] ← both involved, status sufficient

## Epics
- **Data Import** @ss                     ← Shaun owns this epic
  - CSV upload                            ← implicit: under Shaun's epic
  - Google Sheets sync                    ← implicit
  - Database connectors @bh               ← exception: Bob owns this story
```

**Single contributor:** Attribution optional (use only if helpful for memory/tracking)

### Status Markers

Use brackets before or after item text:

- `[PROPOSED by @user]` — New idea, not yet reviewed by others
- `[NEEDS DISCUSSION]` — Requires team input or decision
- `[AGREED]` — Consensus reached, ready to proceed
- `[CONFLICTING]` — Competing proposals; see Pending Reconciliation

Examples:
```markdown
- [PROPOSED by @alice] Add AI-powered recommendations
- Enable dark mode [AGREED]
- [NEEDS DISCUSSION] Freemium vs paid-only approach
```

---

## Smart Contribution Handling

When loading VISION.md with attributed items from other contributors, **assess and intelligently present** them.

### Assessment Framework

For each attributed item from another contributor, evaluate:

**Assessment dimensions:**
- **Alignment**: Compare to user's North Star, stated priorities, existing epics
- **Scope**: Minor feature vs new epic vs direction pivot
- **Conflict**: Contradicts/competes with user's ideas or existing items?
- **Impact**: How much does this change the overall vision?
- **Quality**: Well-articulated? Impressive? Novel?

### Presentation Strategies

**1. Auto-integrate** (remove attribution, silent incorporation):
- **Criteria**: High alignment + low scope + no conflict + clearly fits existing structure
- **Action**: Integrate silently, briefly mention in summary
- **Example**: "CSV import improvements" added to existing Data Import epic

**2. Brief acknowledgment** (keep attribution, mention in passing):
- **Criteria**: Medium alignment + moderate scope + no conflict
- **Action**: FYI mention, leave attribution for context
- **Example**: "FYI: Bob added export features @bh and database connectors @bh"

**3. Highlight for review** (proactive summary and recommendation):
- **Criteria**: High impact OR significant scope OR impressive innovation
- **Action**: Summarize, explain implications, recommend next steps
- **Example**:
  > "Bob proposed a **Real-time Collaboration** epic @bh - significant new direction. This could expand scope considerably. Should we discuss priority vs existing milestones?"

**4. Flag for discussion** (explicit attention required):
- **Criteria**: Conflict detected OR major direction change OR requires decision
- **Action**: Clearly present conflict/issue, offer options, seek input
- **Example**:
  > "Bob proposed visual query builder @bh, but you've emphasized natural language queries. These approaches may conflict. Move to Pending Reconciliation for discussion?"

### Example Interactions

**Scenario 1: Aligned, minor additions**
```
User: "/visionary - let's review the vision"

Agent: "I've reviewed VISION.md. Bob added several items since your last session:
- Export to PDF (fits Data Export epic)
- CSV upload improvements (aligns with your data import focus)

These integrate well with existing direction. I've folded them into the vision.
The current focus remains [...]"
```

**Scenario 2: Significant addition**
```
Agent: "I've loaded VISION.md. Notable addition from Bob:

**Real-time Collaboration epic @bh** - enabling multi-user editing and live updates.

This is ambitious and impressive, but may impact your MVP timeline. Should we:
1. Integrate and adjust milestones
2. Mark as [FUTURE] for post-MVP
3. Discuss trade-offs with Bob"
```

**Scenario 3: Conflict detected**
```
Agent: "I've detected a potential conflict in VISION.md:

Bob proposed **Visual Query Builder** @bh (drag-and-drop interface)
You've emphasized **Natural Language Queries** (plain English)

These are different approaches to the same problem. Options:
1. Move to Pending Reconciliation for discussion
2. Support both (increases complexity)
3. Choose one direction

Your preference?"
```

**Key principle:** Don't just list attributed items. **Synthesize, assess, recommend.**

---

## VISION.md Structure Addition

When conflicts or pending decisions exist, add this section:

```markdown
## Pending Reconciliation

Items requiring agreement or conflict resolution:

### [Topic/Feature Name]
- **Status:** Needs discussion / In progress / Resolved
- **Contributors:** @alice, @bob
- **Conflict:**
  - @alice proposes: [description]
    - Rationale: [why]
  - @bob proposes: [alternative]
    - Rationale: [why]
- **Resolution:** [Once agreed, document decision and remove from this section]

---
```

**Workflow:**
1. When conflicting ideas emerge, move to this section
2. Facilitate discussion, document perspectives
3. Seek consensus or decision
4. Once resolved, update main sections and remove from Pending Reconciliation

---

## Collaboration Commands

In addition to baseline and visionary commands:

| Command | Action |
|---------|--------|
| sync | Review VISION.md for attribution gaps, unresolved conflicts, and items needing sign-off; prepare summary for contributors |
| reconcile [topic] | Facilitate discussion of conflicting ideas; document perspectives; track toward resolution |
| sign-off [item] | Mark item as [AGREED]; note which contributors confirmed; move out of Pending Reconciliation if applicable |
| attribute | Add `— @username` tags to unattributed recent additions based on context/git history |

---

## Collaborative Workflow

### Adding New Ideas

1. **Attribute:** Add `— @username` to proposals
2. **Mark status:** Use `[PROPOSED by @user]` for new, unreviewed ideas
3. **Surface to team:** In handoffs or sync, highlight new proposals needing input

### Handling Conflicts

1. **Detect:** When two contributors propose different directions for same feature/epic
2. **Document:** Add to Pending Reconciliation section with both perspectives
3. **Facilitate:** Use `reconcile [topic]` to structure discussion
4. **Resolve:** Seek consensus, document decision, mark `[AGREED]`
5. **Preserve:** If conflict unresolved, mark `[PENDING]` and revisit later

**Note:** Conflicting ideas can coexist temporarily. Not all conflicts need immediate resolution; some benefit from time and exploration.

### Seeking Alignment

**Regular syncs:**
- Use `sync` command to review vision state
- Identify items needing sign-off: `[PROPOSED]`, `[NEEDS DISCUSSION]`
- Prepare summary: "New from @alice: X, Y. Needs @bob input on Z."
- Ensure all contributors aware of changes

**Sign-off process:**
- Major epics/direction changes: Seek explicit `[AGREED]` from all key contributors
- Minor additions: Attribution sufficient, implicit agreement unless flagged
- Use `sign-off [item]` to formalize agreement

### Maintaining Sync

**Challenges in multi-contributor projects:**
- Vision drift (contributors work on different areas, diverge)
- Silent disagreements (not surfaced early)
- Stale proposals (no follow-up or decision)

**Solutions:**
1. **Attribute everything** — Ownership clear, easier to loop in right people
2. **Explicit status** — No ambiguity about what's decided vs proposed
3. **Pending Reconciliation section** — Conflicts visible, not buried
4. **Regular sync** — Periodic review prevents drift
5. **Sign-off discipline** — Major changes get explicit agreement

---

## Interaction Contract (Multi-Contributor Mode)

When this file is loaded:

- **Intelligent facilitation:** Assess other contributors' additions; auto-integrate aligned items, highlight significant ones, flag conflicts
- **Proactive synthesis:** Don't just present changes; interpret impact, suggest actions, recommend decisions
- **Neutral facilitator:** Present all perspectives fairly; seek consensus, not personal preference
- **Sparse attribution:** Attribute purposefully (awareness, conflicts, proposals), not everything; avoid clutter
- **Explicit over implicit:** Don't assume agreement; use status markers and sign-off when needed
- **Document decisions:** When conflicts resolve, capture rationale (helps future contributors understand "why")
- **Preserve disagreement:** If no consensus, document both views; revisit later

---

## Example: Multi-Contributor VISION.md Excerpt

```markdown
# Product Vision
<!-- Contributors: @ss=Shaun, @bh=Bob -->

## North Star
Build the fastest, most intuitive data analysis platform for non-technical users.

## Target Users
- Primary: Business analysts without SQL experience
- Secondary: Data scientists wanting rapid prototyping

## Use Cases

**Active/Prioritized:**
- Upload CSV and get instant visualizations
- Connect to live databases (SQL, MongoDB) @bh
- Natural language queries [NEEDS DISCUSSION]
- Share dashboards with team

## Epics

- **Data Import** @ss
  - *As an analyst, I want to upload CSV files so that I can visualize my data.*
  - *As an analyst, I want to connect to Google Sheets so that data stays in sync.*

- **Query Interface** [NEEDS DISCUSSION]
  - *As a non-technical user, I want to ask questions in plain English.* @ss
  - *As a business user, I want a drag-and-drop query builder.* @bh

## Pending Reconciliation

### Query Interface Approach

- **Status:** Needs discussion
- **Contributors:** @alice, @bob
- **Conflict:**
  - @alice proposes: Natural language (NL) query interface
    - Rationale: Non-technical users intimidated by visual builders; NL is most intuitive
  - @bob proposes: Visual query builder (drag-and-drop)
    - Rationale: NL is hard to get right; visual builder gives more control and predictability
- **Resolution:** TBD — schedule discussion; consider hybrid (both modes)?

---
```

## Tips

- **Don't overuse:** Not every bullet needs attribution if context is clear
- **Focus on conflicts:** Attribution most valuable when ideas might conflict or need alignment
- **Lightweight by default:** Start simple; add detail (status markers, reconciliation) only when needed
- **Trust the process:** Conflicts are normal; documenting them prevents silent divergence

---

## Returning to Single-Contributor Mode

If project returns to single contributor:
- Attribution and status markers optional (remove if cluttering)
- Keep Pending Reconciliation history for context (shows decision evolution)
- Core visionary workflow unchanged
