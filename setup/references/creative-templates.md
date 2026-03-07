# Creative docs/ Templates

Use when creating Creative archetype docs (docs/STORY.md, docs/WORLD.md, docs/NARRATIVES.md, docs/CREATIVE_WORK.md).

**Note:** These templates are domain-agnostic and adaptable. Use them for worldcraft, UX/narrative design, product design, visual systems, or any creative project. Adapt terminology and examples to your domain.

**Document hierarchy:**
- **STORY.md (CD1)** — Top-level world context. Read on startup by storyteller. Self-contained orientation.
- **WORLD.md (CD2)** — Detailed universe specifications. Read when task requires deep mechanics.
- **NARRATIVES.md (CD2)** — Narrative craft, prose, discovery arcs. Read when working on story design.
- **CREATIVE_WORK.md** — Living work log. Active items, completed, rejected/deferred ideas.

---

## docs/STORY.md

```md
# Story

**Top-level world context.** Setting, history, cultures, and rules — enough for any reader to orient themselves and make informed decisions. This is the CD1 entry point for creative content.

For detailed universe mechanics, see `docs/WORLD.md`.
For narrative craft, discovery arcs, and prose content, see `docs/NARRATIVES.md`.

---

## Setting

### Geography & Regions

[Major geographic features, regions, biomes — how they shape civilization. Enough to understand the world at a glance.]

### Time & Era

[When does the story take place? What era? What came before?]

---

## History (Overview)

### Origins

[How the world came to be — creation, formation, deep history. Keep concise; detailed cosmology goes in WORLD.md.]

### Major Events

[Critical turning points that shaped the current state. List the key moments; detailed analysis goes in WORLD.md.]

### Current Era

[Present day as of story's time zero. Recent developments, ongoing tensions.]

---

## Cultures & Factions

### [Culture/Faction Name]

- **Region:** Where they live
- **Character:** Core identity and values
- **Tensions:** Current conflicts, rivals, allies
- **Worldview:** How they understand their world

[Add more cultures as needed. Detailed population, technology, ecology → WORLD.md]

---

## Rules of the World

[Core rules that govern how things work. Magic systems, technology constraints, physical laws that differ from reality. Keep to the essentials; detailed specifications → WORLD.md]

---

## Mystery & Unknown

[Things that remain unexplained. Fragments of lost knowledge. Paradoxes. Open questions that drive narrative tension.]

---

## Domain Map

| Document | Contains | Read when |
|----------|----------|-----------|
| **WORLD.md** | Detailed physics, cosmology, geography, ecology, technology, magic systems | Auditing world systems, building mechanics, deep lore work |
| **NARRATIVES.md** | Discovery arcs, lore spectrum, cultural voices, storytelling principles, prose pieces | Working on story structure, narrative design, lore methodology |
| **CREATIVE_WORK.md** | Active work items, completed items, rejected/deferred ideas | Tracking creative progress |

---

## Why This Matters

[Author's note: Explain the purpose of this world, major themes, or why certain truths are foundational to the narrative]
```

---

## docs/WORLD.md

```md
# World

**Detailed universe specifications.** How things actually work — physics, cosmology, geography, ecology, technology, magic systems. This is the deep reference for world mechanics.

For top-level world context and orientation, see `docs/STORY.md` (CD1).
For narrative craft and storytelling methodology, see `docs/NARRATIVES.md`.

---

## Physical World

### Geography & Regions (Detail)

[Detailed geographic features, region boundaries, terrain types, resource distribution, trade routes, strategic positions]

### Climate & Environment

[Environmental systems, seasonal patterns, natural hazards, weather phenomena, ecological relationships]

### Celestial Mechanics

[Sky, moons, stars, planets — what's visible and how it moves. Orbital mechanics, tidal effects, navigational significance]

### Ecology

[Flora, fauna, food chains, symbiotic relationships, dangerous species, domesticated organisms]

---

## Systems & Mechanics

### [Magic/Technology/Power System]

[Detailed rules: what's possible, what's not, energy costs, limitations, social implications, historical development]

### Economy & Resources

[Trade systems, currency, valuable resources, scarcity, economic power dynamics]

### Political Structures

[Governance systems, power hierarchies, legal frameworks, diplomatic relationships]

---

## History (Detail)

### Pre-History

[Deep time. Ancient civilizations, technological development, cultural formation, geological/cosmological events]

### [Major Event Name]

[Detailed analysis of a critical turning point. Causes, participants, consequences, lasting effects]

### Chronology

[Timeline of significant events. Dates, eras, epochs as relevant to the world's calendar system]

---

## Cultures & Factions (Detail)

### [Culture/Faction Name]

- **Geography:** Detailed territory, settlements, sacred sites
- **Population:** Scale, distribution, demographics
- **Technology:** Tech level, unique capabilities, innovations
- **Social Structure:** Classes, roles, hierarchies, customs
- **Values & Beliefs:** Core philosophy, religious systems, moral frameworks
- **Language & Communication:** Linguistic features, scripts, oral traditions
- **Conflict History:** Wars, alliances, betrayals, treaties

---

## Unknown / Unresolved

[Detailed tracking of mysteries, paradoxes, and open questions. What evidence exists? What's been ruled out? What remains genuinely unknown?]
```

---

## docs/NARRATIVES.md

```md
# Narratives

**Narrative craft and content.** How lore is crafted, paced, and discovered. Discovery arcs, lore spectrum, cultural voices, storytelling principles, and prose content.

For world context and setting, see `docs/STORY.md` (CD1).
For detailed universe mechanics, see `docs/WORLD.md`.

**This is the natural home for prose.** Colorful examples, illustrative scenarios, and narrative fragments from user discussions belong here. Prose should be polished for brevity without losing meaning — tighten what can be tightened, but never compress to the point of losing the quality that made prose the right choice. Sections marked `<!-- PROSE: do not distill -->` must be preserved as-is.

---

## Core Narrative

### North Star

[One sentence: What is the big truth players/readers discover?]

### Discovery Arc

[Major stages of revelation; how truth unfolds from surface mystery to full convergence]

#### Tier 1: Wonder

[What draws people in? What's strange or intriguing at the start?]

#### Tier 2-3: Pattern Recognition

[What evidence suggests a deeper story? Where do contradictions appear?]

#### Tier 4-5: Assembly

[What connects the pieces? How does the big picture coalesce?]

#### Tier 6: Convergence & Choice

[What's the full truth? What are the implications and open questions?]

---

## Lore Spectrum

Balance truth, observation, mystery, and deception.

| Category | Purpose | Proportion |
|----------|---------|------------|
| **Pure noise** | Flavor, no truth; local color and tangents | ~30-40% |
| **Folk observation** | Accurate but shallow; cultural interpretation of real phenomena | ~30-40% |
| **Wild goose chases** | Wrong but interesting; plausible false beliefs that reward investigation | ~15-20% |
| **Degraded science** | Fossil signals; fragments of lost knowledge preserved in garbled form | ~5-10% |
| **Convergent truth** | Multi-source confirmation; when players recognize the same truth from different angles | ~5-10% |

---

## Cultural Voices

How each culture tells stories.

### [Culture Name]

- **Narrative style:** Formal? Metaphorical? Practical?
- **Cultural values:** What shapes their storytelling?
- **Key metaphors:** How do they describe mysterious phenomena?
- **Lore density:** How much do they talk about [topic]?

---

## Storytelling Principles

### 1. Ground in STORY.md

All narrative proposals must respect STORY.md as world truth. No contradictions.

### 2. Collaborative Creation

Never generate narrative from specs alone. Prose is co-created with creative director and user, always preserving their voice.

### 3. Content Preservation

Never delete creative ideas. Archive rejected concepts with rationale in CREATIVE_WORK.md.

### 4. Signal-to-Noise Balance

Maintain the lore spectrum. Audit regularly to ensure mystery remains mysterious and truth is discoverable but non-obvious.

### 5. Cross-Reference Moments

Design narrative convergences where multiple cultures' lore points to the same truth from different angles.

### 6. Prose Integrity

Some content exists in prose form because the prose IS the meaning. Never distill narrative passages into bullet points or specification language unless the user explicitly directs it.

---

## Discovery Encounters

[List major lore encounters by tier; explain what players learn and what questions remain unanswered]

---

## Prose & Stories

[Standalone narrative content, short stories, vignettes, lore fragments — co-created with user. These sections preserve the author's voice and should not be summarized or restructured without explicit direction.]

<!-- PROSE: do not distill -->

```

---

## docs/CREATIVE_WORK.md

```md
# Creative Work Log

**Living document** for lore design, world-building, art direction, and narrative content.

Track active work, completed items (with dates), and rejected/deferred ideas (with context preserved).

This roadmap will eventually become its own project when creative work separates from engine/tech development.

---

## Active Items

### Critical Path (Gates Other Work)

[High-priority decisions that block downstream work]

- [ ] **[Item Name]**
  - Description: [What needs to be decided or created?]
  - Blockers: [What must be completed first?]
  - Impact: [What does this unblock?]

### Narrative & Lore Design

- [ ] **[Lore element name]**
  - What: [Description]
  - Why: [How does this serve the story?]

### World & Geography

- [ ] **[World element name]**

### Art Direction & Visuals

- [ ] **[Visual element name]**

### Experience & Discovery

- [ ] **[Discovery moment name]**

### Asset & Implementation Needs

- [ ] **[Asset or implementation name]**

### Calibration & Audit

- [ ] **Audit lore spectrum balance**
  - Assess current distribution against target percentages
  - Identify gaps or over-concentration in any category

- [ ] **Check discovery arc pacing**
  - Verify each tier has enough material
  - Ensure progression feels natural

---

## Completed

- [x] **[Item Name]** — [Date completed]
  - Result: [Brief summary of what was accomplished]

---

## Rejected / Deferred Ideas

*(Ideas that have been explored, rejected, or deferred with rationale. Preserved for future context.)*

**Note:** Archive rejected ideas here with brief rationale but preserve nuance. Ideas are precious even when not currently used — they inform future decisions and may become relevant under different circumstances.

### Rejected: [Idea Name]

**Rationale:** [Why we're not pursuing this]

**Nuance:** [What was interesting about it, what did it teach us?]

**Context:** [What was the original thinking?]

**Could revisit if:** [Under what conditions might this become relevant?]

### Deferred: [Idea Name]

**Reason:** [Blocked by X, or lower priority than Y]

**Current status:** [What's waiting on what?]

**Resume when:** [What needs to happen first?]

---

## Dependencies & Sequencing

**Must complete before:**
- [Downstream work that depends on these decisions]

**Can proceed in parallel:**
- [Independent workstreams]
```

---

## docs/README.md (Creative projects)

```md
# [Project Name]

[One-line description of the creative project]

---

## Quick Start

1. **World context:** Read `docs/STORY.md` for setting, history, cultures, and rules (CD1 — always read first)
2. **Deep mechanics:** Read `docs/WORLD.md` for detailed universe specifications (CD2 — read when needed)
3. **Narrative craft:** Read `docs/NARRATIVES.md` for discovery arcs, lore spectrum, storytelling principles (CD2 — read when needed)
4. **Roadmap:** Read `docs/CREATIVE_WORK.md` for active work and progress
5. **Assets:** Explore `assets/` for organized creative outputs (art, design, stories, etc.)

---

## Project Structure

```
[project]/
├─ docs/
│  ├─ STORY.md               # World context: setting, history, cultures, rules (CD1)
│  ├─ WORLD.md               # Detailed universe specifications (CD2)
│  ├─ NARRATIVES.md           # Narrative craft, discovery arcs, prose content (CD2)
│  └─ CREATIVE_WORK.md       # Living work log (active, completed, rejected ideas)
├─ assets/                   # Creative assets (organized by type)
│  ├─ stories/               # Standalone narrative content
│  ├─ art/                   # Concept art, illustrations, reference
│  ├─ 3d-models/             # 3D models, meshes, sculpts
│  ├─ textures/              # Texture maps, materials, surface details
│  ├─ tiles/                 # Tileset assets, sprite sheets
│  ├─ palettes/              # Color palettes, design systems
│  ├─ ui/                    # UI designs, mockups, icons
│  └─ audio/                 # Sound effects, music, voice recordings
├─ README.md                 # This file
├─ .gitignore                # Excludes binary assets if managed elsewhere
├─ AGENTS.md                 # Skill library entry point
├─ CLAUDE.md                 # Points to AGENTS.md
├─ GEMINI.md                 # Points to AGENTS.md
└─ CODEX.md                  # Points to AGENTS.md
```

---

## Asset Organization

**Adapt directories and naming to your domain.** Examples below work for worldcraft, games, apps, or design projects.

### assets/stories/
Standalone narrative content, lore fragments, character backstories, UX flows, interaction scripts, user journeys, copy/dialogue.

### assets/art/
Concept art, illustrations, visual references, mood boards, character designs, environment sketches, UI mockups.

### assets/3d-models/
3D models, meshes, sculpts, architectural assets, spatial designs, interactive prototypes.

### assets/textures/
Texture maps, material definitions, surface details, procedural textures, material libraries, surface finishes.

### assets/tiles/
Tileset definitions, sprite sheets, grid-based assets, component libraries, modular design pieces.

### assets/palettes/
Color palettes, design systems, brand guidelines, theme definitions, accessibility guidelines.

### assets/ui/
UI designs, mockups, icon sets, interface layouts, design specifications, interaction patterns, wireframes.

### assets/audio/
Sound effects, music, voice recordings, audio cues, sonic identity elements.

---

## Workflow

1. **Start here:** Read STORY.md for world context and orientation
2. **Go deeper:** Read WORLD.md for universe mechanics or NARRATIVES.md for story craft — only when needed
3. **Track progress:** Update CREATIVE_WORK.md as you complete items
4. **Create assets:** Organize outputs in `assets/` by type (stories, art, models, etc.)
5. **Preserve ideas:** Archive rejected concepts in CREATIVE_WORK.md with rationale
6. **Audit regularly:** Check consistency, pacing, and alignment across docs

---

## Using Storyteller Skill

This project uses the **Storyteller** skill for creative direction and consistency. Storyteller adapts to your domain (worldcraft, UX, design, etc.) and can help with:

- **Audit consistency:** Use `/storyteller` to check STORY.md, WORLD.md, and NARRATIVES.md alignment
- **Find structural issues:** Storyteller identifies contradictions, gaps, or unclear concepts
- **Propose frameworks:** Storyteller suggests architectures and structures (never generates content from specs)
- **Organize content:** Storyteller helps cross-file organization and reference mapping

Type `/storyteller` to begin.

---

## Key Files & Reference

- `docs/STORY.md` — World context: setting, history, cultures, rules (CD1 — read first)
- `docs/WORLD.md` — Detailed universe specifications (CD2 — deep mechanics)
- `docs/NARRATIVES.md` — Narrative craft, discovery arcs, prose content (CD2 — story design)
- `docs/CREATIVE_WORK.md` — Roadmap: active work, completed items, archived ideas
- `assets/` — Creative outputs organized by type (modular, reusable, domain-agnostic)

---

## Notes on .gitignore

If binary assets (models, textures, audio) are stored in this repository:
- Include them in git with `.gitignore` exceptions
- Consider LFS (Large File Storage) for large binary files

If binary assets are managed externally (cloud storage, separate repository, CDN):
- Add standard patterns to `.gitignore` to exclude them
- Reference external location in CREATIVE_WORK.md or README
```
