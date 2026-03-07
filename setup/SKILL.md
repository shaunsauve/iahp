---
name: setup
base_skill: baseline
model_tier: standard
description: |
  Bootstrap new projects with standard directory structure and documentation templates based on project archetype.
  TRIGGER when: user wants to start a new project, says "new project", "setup", "scaffold", "bootstrap".
  DO NOT TRIGGER: for adding features to existing projects (use coder) or scaffolding individual skills (use skill-manager).
  CHAIN: after scaffold completes, coder is the natural next skill for implementation.
---

# Setup Project

## Role

Bootstrap new projects with appropriate structure based on project archetype. Can be:
- Invoked directly: `/setup ~/src/flutter_app` or `/setup ~/work/org_analysis`
- Called by other skills when detecting an empty directory needing setup

When run on an existing project, this skill can scan for deviations from the current workflow (missing files, outdated bootstrap pointers) and offer to add or update without overwriting existing content.

The README created by this skill should encode enough project structure context that future sessions need only read README.md to understand the project.

## Identity Announcement
Follow baseline Identity Announcement Standard with name: "Setup"

## Bootstrap File Philosophy

**AGENTS.md is the single source of truth for LLM instructions.** All other pointer files should be minimal and just reference AGENTS.md.

### File Hierarchy

| File | Purpose | Content |
|------|---------|---------|
| **AGENTS.md** | Single source of truth | Full instructions: where to find skills, permissions, rules, quick reference |
| CLAUDE.md | Pointer for Claude | "Read AGENTS.md" |
| GEMINI.md | Pointer for Gemini | "Read AGENTS.md" |
| CODEX.md | Pointer for Codex | "Read AGENTS.md" |
| .cursor/rules/ | Pointer for Cursor | "Read AGENTS.md" |

### Two Skill Location Scenarios

1. **Submodule present** (`iahp/` exists with AGENTS.md inside):
   - AGENTS.md points to `iahp/AGENTS.md`
   - Permissions: read freely from `./iahp/`

2. **Global skills** (no submodule):
   - AGENTS.md points to `~/.claude/skills/AGENTS.md`
   - Permissions: read freely from `~/.claude/skills/`

### Why This Matters

- **No duplication**: Instructions live in one place, preventing drift
- **Easy updates**: Change AGENTS.md, all LLMs get the update
- **Clear authority**: No confusion about which file is correct

## Project Archetypes

Classify projects by the nature of the work, not job titles.

### 1. Tech

**Focus:** Functional production and structural integrity.

**Applicable Roles:** Visionaries, Architects, Developers, QA/Testers, DevOps.

**Workflow:** Discrete phases (Vision → Design → Implementation → Validation).

**Objective:** Transform abstract requirements into a working, testable system.

**Project Rule:** If the goal is to build, fix, or optimize a technical asset, use Tech.

**Structure:**
```
project/
├─ docs/
│  ├─ VISION.md          # Product goals, epics, use cases (creative catalog), user stories (epic→story)
│  ├─ USE_CASES.md       # (optional) Use case tracker; append-only; review to spur ideas
│  ├─ PROJECT.md         # Milestones, MVP scope, current focus
│  ├─ REQUIREMENTS.md    # F001, F002... / N001, N002... (trace to epic/story)
│  ├─ ARCHITECTURE.md    # Components, design decisions
│  ├─ CONCEPTS.md        # Domain knowledge (ELI5)
│  └─ TODO.md            # Current task, previous, backlog (tasks; trace to F001/epic/story)
├─ lib/                  # Source code (or src/, app/ per language)
├─ bin/                  # Entry points
├─ tests/                # All tests, fixtures, test data
├─ README.md             # Source of truth: description, setup, run, test, structure
├─ .gitignore            # Language-specific + project artifacts
├─ .cursor/rules/        # Points Cursor to skills (e.g. skill-library.mdc)
├─ AGENTS.md             # Skill library entry point
├─ CLAUDE.md             # Points to AGENTS.md
├─ GEMINI.md             # Points to AGENTS.md
└─ CODEX.md              # Points to AGENTS.md
```

**Mapped skills:** coder, architect, visionary

---

### 2. Nexus

**Focus:** Relationship mapping and institutional memory.

**Applicable Roles:** Executives, Team Leads, Career Mentors, Executive Assistants, Strategic Analysts.

**Workflow:** Continuous logging and synthesis (Observation → Pattern Recognition → Decision Support).

**Objective:** Maintain a high-fidelity map of the "human" layer: power structures, cultural nuances, and historical context.

**Project Rule:** If the goal is to track "the who" and "the why" behind organizational shifts, use Nexus.

**Processing Directive:** When the user shares emails, messages, or other excerpts:
- Do NOT archive verbatim (the original exists elsewhere like inbox)
- Extract and record key decisions → `decisions/`
- Capture insights about people/relationships → `people/`
- Note new information about companies/partners → `partners/` or `company/`
- Incorporate strategic insights → `strategy/`
- Update current priorities if relevant → `current/focus.md`
- Log open questions raised → `current/questions.md`

**Key Conventions:**
- **Entity pattern:** Every entity (person, partner, initiative) has two files: `entity.md` (summary) + `entity.timeline.md` (append-only history)
- **Date everything:** Timelines use `## YYYY-MM-DD` headers; decisions named `YYYY-MM-DD-topic.md`; meetings named `YYYY-MM-DD-[type]-subject.md`
- **Append-only:** Never overwrite timeline entries; add dated corrections if understanding changes
- **Context Depth:** CD1 always loaded (NEEDS-TO-KNOW.md, critical-changes.md, org-chart.md, focus.md, TODO.md) → CD2 on mention (entity files) → CD3 on request (meetings, competitors, archives)
- **Meeting flow:** Raw notes in `meetings/` → distill into knowledge base areas (decisions/, people/, strategy/, etc.)

**Structure:**
```
project/
├─ NEEDS-TO-KNOW.md      # CD1: Tier 1 essentials (loaded every session)
├─ company/              # Company info
│  ├─ summary.md         # Key facts, mission, products, strategy
│  ├─ org-chart.md       # Organizational structure (CD1)
│  └─ summary.timeline.md
├─ current/              # Active focus
│  ├─ focus.md           # Active priorities, this week (CD1)
│  ├─ critical-changes.md # Major changes log (CD1)
│  └─ questions.md       # Open questions, parking lot
├─ decisions/            # Major decisions with context (YYYY-MM-DD-topic.md)
│  └─ INDEX.md           # Decision log
├─ meetings/             # Raw meeting notes (YYYY-MM-DD-[type]-subject.md)
│  └─ INDEX.md           # Meeting index
├─ competitors/          # Competitive analysis (CD3)
│  └─ INDEX.md           # Competitor index
├─ partners/             # External companies, vendors
│  └─ INDEX.md           # Partner index
├─ people/               # All people (entity.md + entity.timeline.md)
│  └─ INDEX.md           # People index
├─ personal/             # Role and career context
│  ├─ summary.md         # Role, goals, skills, communication style
│  └─ summary.timeline.md
├─ initiatives/          # Initiatives, workstreams
│  └─ INDEX.md           # Initiative index
├─ strategy/             # Strategy and positioning
│  └─ INDEX.md           # Strategy index
├─ vision/               # Tech vision, roadmap
│  └─ INDEX.md           # Vision index
├─ TODO.md               # Session task tracking (current, done, backlog)
├─ README.md             # Project entry point (universal)
├─ AGENTS.md             # Skill library entry point
├─ CLAUDE.md             # Points to AGENTS.md
├─ GEMINI.md             # Points to AGENTS.md
├─ CODEX.md              # Points to AGENTS.md
└─ .gitignore
```

**Mapped skills:** executive-advisor

#### Nexus Sub-Variant: Multi-Client

When the nexus tracks multiple client engagements (consulting, advisory, portfolio management) rather than a single organization, use this leaner structure. Context depth is client-scoped — most depth lives inside `clients/{name}/`.

If firm-level complexity grows (own strategy, vision, competitors, internal org depth), the user should create a separate single-org Nexus for their firm.

**Structure:**
```
project/
├─ NEEDS-TO-KNOW.md      # CD1: Portfolio dashboard (active engagements, key dates, risks)
├─ current/              # Firm-level priorities
│  ├─ focus.md           # Which clients need attention (CD1)
│  ├─ critical-changes.md # Cross-client changes (CD1)
│  └─ questions.md       # Open questions
├─ clients/              # One directory per client engagement
│  ├─ INDEX.md           # Client roster (name, status, type, key contact)
│  └─ {client-name}/
│     ├─ summary.md      # Engagement scope, contract, key contacts, status
│     ├─ summary.timeline.md  # Engagement history (append-only)
│     ├─ focus.md        # Active priorities for THIS client
│     ├─ people/         # Client-side stakeholders
│     │  └─ INDEX.md
│     ├─ decisions/      # Decisions on this engagement
│     │  └─ INDEX.md
│     ├─ meetings/       # Meeting notes with this client
│     │  └─ INDEX.md
│     └─ initiatives/    # Workstreams within the engagement
│        └─ INDEX.md
├─ personal/             # Your career context
│  ├─ summary.md
│  └─ summary.timeline.md
├─ TODO.md               # Session task tracking
├─ README.md
├─ AGENTS.md, CLAUDE.md, GEMINI.md, CODEX.md, .gitignore
```

**CD Protocol (multi-client):**
- **CD1:** NEEDS-TO-KNOW.md, current/focus.md, current/critical-changes.md, TODO.md
- **CD2:** On client mention → `clients/{name}/summary.md` + `clients/{name}/focus.md`, then deeper (people/, decisions/) as needed
- **CD3:** On request → archived meetings, deep engagement history

---

### 3. Admin

**Focus:** Task accomplishment and project completion.

**Applicable Roles:** Anyone managing a finite, non-technical initiative.

**Workflow:** Goal-oriented execution (Define Goals → Execute Tasks → Track Progress → Complete).

**Objective:** Complete a defined project with clear success criteria and document trail.

**Project Rule:** If the goal is to accomplish a specific task or initiative (not build software, not track relationships), use Admin.

**Examples:** Tax preparation, home renovation, event planning, personal initiatives, following up on a business initiative.

**Structure:**
```
project/
├─ TODO.md              # Tasks: current, done, backlog
├─ GOALS.md             # Success criteria, deadlines, constraints
├─ NOTES.md             # Research, decisions, reference info
├─ LOG.md               # Chronological activity log
├─ contacts/
│  └─ INDEX.md          # Project-specific people/vendors
├─ inbox/               # Documents received
│  └─ MANIFEST.md       # What each file is, status
├─ outbox/              # Documents sent
│  └─ MANIFEST.md       # What was sent, to whom, confirmation
├─ reference/           # Supporting docs (instructions, templates)
│  └─ INDEX.md
├─ README.md            # Project overview
├─ AGENTS.md            # Skill library entry point
├─ CLAUDE.md            # Points to AGENTS.md
├─ GEMINI.md            # Points to AGENTS.md
└─ CODEX.md             # Points to AGENTS.md
```

**Mapped skills:** administrative-advisor

---

### 4. Creative

**Focus:** Creating and organizing narrative, design, and creative content.

**Applicable Roles:** Creative Directors, Storytellers, Designers, Narrative Architects, UX Designers, World Builders, Concept Artists.

**Workflow:** Iterative discovery and collaborative creation (Concept → Build → Audit → Refine).

**Objective:** Build and organize creative content across domains (worldcraft, UX/narrative, product design, visual systems, etc.), managing consistency, discovery arcs, and creative frameworks.

**Project Rule:** If the goal is to create and manage creative content (narrative, worldcraft, design systems, visual identity, user experience, discovery arcs), use Creative.

**Structure:**
```
project/
├─ docs/
│  ├─ STORY.md           # World context: setting, history, cultures, rules (CD1)
│  ├─ WORLD.md           # Detailed universe specifications (CD2)
│  ├─ NARRATIVES.md      # Narrative craft, discovery arcs, prose content (CD2)
│  └─ CREATIVE_WORK.md   # Living work log (active, completed, rejected/deferred ideas)
├─ assets/               # Creative assets (organized by type)
│  ├─ stories/           # Standalone narrative content
│  ├─ art/               # Concept art, illustrations, reference
│  ├─ 3d-models/         # 3D models, meshes, sculpts
│  ├─ textures/          # Texture maps, materials, surface details
│  ├─ tiles/             # Tileset assets, sprite sheets
│  ├─ palettes/          # Color palettes, design systems
│  ├─ ui/                # UI designs, mockups, icons
│  └─ audio/             # Sound effects, music, voice recordings
├─ README.md             # Project overview and structure
├─ .gitignore            # Excludes binary assets if managed elsewhere
├─ AGENTS.md             # Skill library entry point
├─ CLAUDE.md             # Points to AGENTS.md
├─ GEMINI.md             # Points to AGENTS.md
└─ CODEX.md              # Points to AGENTS.md
```

**Mapped skills:** storyteller

---

## Skill-to-Archetype Mapping

| Calling Skill | Archetype | Action |
|---------------|-----------|--------|
| coder | Tech | Initialize without prompting |
| architect | Tech | Initialize without prompting |
| visionary | Tech | Initialize without prompting |
| executive-advisor | Nexus | Prompt: single-org or multi-client |
| administrative-advisor | Admin | Initialize without prompting |
| storyteller | Creative | Initialize without prompting |
| (none / direct invocation) | Unknown | Prompt for archetype |

## Classification Rules

When determining archetype:
1. **Tech** if the goal is to build, fix, or optimize a technical asset
2. **Nexus** if the goal is to track "the who" and "the why" behind organizational shifts
3. **Admin** if the goal is to complete a finite, non-technical project or initiative
4. **Creative** if the goal is to create and manage creative content (narrative, design, worldcraft, visual systems, UX/discovery arcs, etc. across any domain)
5. **Prompt** if unclear from context or calling skill

## Workflow

1. **Detect invocation context:**
   - Direct: `/setup [path]` → prompt for archetype
   - From skill: check mapping table above

2. **Determine target directory:**
   - If path provided: use that path
   - If no path AND current directory is empty: use current directory
   - If no path AND current directory is NOT empty: prompt user for target path
     - "The current directory is not empty. Where should the project be created?"
     - Accept absolute or relative path

3. **Check skill library availability:**

   Check for skill library in this order:
   1. `iahp/` directory exists with AGENTS.md inside → use submodule paths
   2. `~/.claude/skills/` exists with AGENTS.md inside → use global paths
   3. Neither exists → prompt user:

   ```
   No skill library found. How would you like to set it up?

   1. Symlink (recommended for most users)
      Links ~/.claude/skills/ to a shared repo you maintain
      Pro: One copy, all projects use it
      Con: Requires manual repo clone first

   2. Submodule (recommended for sandboxed environments)
      Adds iahp/ as git submodule in this project
      Pro: Self-contained, works with workspace restrictions
      Con: Each project has its own copy
   ```

   **If user chooses symlink:**
   - Check if `~/src/iahp` exists (common clone location)
   - If exists: `ln -s ~/src/iahp ~/.claude/skills`
   - If not: prompt for path or offer to clone:
     ```
     Where is your iahp repo? (or 'clone' to clone it now)
     ```
   - If 'clone': `git clone git@github.com:<your-username>/iahp.git ~/src/iahp && ln -s ~/src/iahp ~/.claude/skills`

   **If user chooses submodule:**
   - Run: `git submodule add git@github.com:<your-username>/iahp.git iahp`
   - Use `iahp/` paths in AGENTS.md

4. **Check existing structure:** Look for README.md, CLAUDE.md, docs/, etc.
   - **If empty or only bootstrap files:** proceed to create structure (step 6).
   - **If structure exists:** run Scan and update (below); then offer to enhance or skip.

   **Scan and update (existing projects):** When the project already has archetype structure (e.g. docs/, company/, GOALS.md), infer archetype from what's present. Compare to the current workflow in this skill:
   - **Submodule update:** If `iahp/` directory exists and is a git submodule, pull the latest version:
     - Run `git -C <project> submodule update --remote iahp`
     - Report: "Updated iahp submodule to latest"
     - If submodule has AGENTS.md after update, use submodule paths in pointers; otherwise use global `~/.claude/skills/` paths
   - **Bootstrap pointers:** Missing CODEX.md or GEMINI.md; .cursor/rules (or CLAUDE.md) not pointing correctly. Add missing files only; update pointer content if clearly outdated:
     - CLAUDE.md: lacks AGENTS.md reference
     - GEMINI.md: lacks AGENTS.md reference (should be identical to CLAUDE.md)
     - CODEX.md: lacks AGENTS.md reference (should be identical to CLAUDE.md)
     - Pointer path selection: Use `iahp/` if submodule exists AND contains AGENTS.md; otherwise use `~/.claude/skills/`
   - **Archetype structure:** Missing dirs or files from the archetype's Structure (e.g. missing docs/CONCEPTS.md, current/questions.md). Add missing files using templates from [references/](references/) (see Templates section below); do not overwrite existing files or user content.
   - **Context Depth compliance (Tech archetype):** Check that existing docs follow the Context Depth Protocol defined in baseline/SKILL.md:
     - Top-level docs (ARCHITECTURE.md, VISION.md, etc.) should contain working summaries when referencing secondary files — not bare `See docs/FOO.md` links
     - If secondary files exist (e.g., `docs/UNIFIED_DISPATCH.md`, `docs/internal/*.md`) without summaries in their parent doc, flag as a CD protocol gap
     - Do not rewrite docs; report gaps and offer to add summary stubs the user can fill in
   - **Gitignore check:** Ensure `.gitignore` includes `SUMMARY.json` and `.summarize-prev.json` (summarizer outputs, not version-controlled).
   - **README:** If README lacks a "Project Structure" section or doesn't match current templates, offer to add a structure table or merge in missing sections; do not replace existing narrative.
   - Report: "Deviations: [list]. I can add [missing] and update [outdated]. Proceed?" Apply only what the user confirms.

5. **Prompt if uncertain:** When archetype unclear, ask:
   - "What type of project is this? Tech (build/fix/optimize systems) or Nexus (track relationships/organizational dynamics)?"

6. **Nexus sub-variant prompt:** When archetype is Nexus, ask:
   - "Is this for a single organization or multi-client (consulting, advisory, portfolio management)?"
   - **Single organization** → use Nexus structure
   - **Multi-client** → use Nexus Multi-Client structure
   - Use multi-client templates from `references/nexus-multi-client-templates.md`

7. **Create structure:** Based on selected archetype
   - Create archetype-specific directories and files
   - Create AGENTS.md pointing to skill library (submodule or global path from step 3)
   - Create CLAUDE.md, GEMINI.md, and CODEX.md pointing to AGENTS.md
   - Create .cursor/rules pointing to AGENTS.md

8. **Encode in README:** Include a "Project Structure" section explaining:
   - What each directory contains
   - Where to find current tasks/focus
   - Any project-specific conventions
   - For Nexus: include Key Conventions and Context Depth Protocol sections

9. **Check and configure git remote:** After creating structure, if the project is a git repository:
   - Run `git remote -v` to check if a remote origin exists
   - If no remote exists:
     - Detect GitHub username using this priority order:
       1. Extract from existing remote URL: `git config --get remote.origin.url | sed -E 's#.*github\.com[:/]([^/]+)/.*#\1#'`
       2. Check git config: `git config --get github.user`
       3. If neither works: skip automatic remote configuration silently
     - If username detected:
       - Extract the project directory name from the current path
       - Check if `git@github.com:<username>/<project_directory_name>.git` exists on GitHub using `gh repo view <username>/<project_directory_name>` (requires gh CLI)
       - If the GitHub repo exists:
         - Add it as remote: `git remote add origin git@github.com:<username>/<project_directory_name>.git`
         - Report: "Added remote origin: git@github.com:<username>/<project_directory_name>.git"
       - If the GitHub repo does not exist:
         - Report: "No remote configured. GitHub repo git@github.com:<username>/<project_directory_name>.git does not exist."
     - If username not detected: skip silently (no error message needed)
   - If remote already exists: skip silently

10. **Note on summary dashboard:** Explain that projects can use the live 4-line dashboard:
    - Run `./summarize.sh` in a terminal pane to enable the live dashboard
    - Delete SUMMARY.json to disable
    - See `summarize/SKILL.md` for details

11. **Suggest transition:** "Structure complete. Which skill should we start?"

---

## Permissions

This skill has explicit permission to:

**Read:**
- Any file in `setup/references/` and `iahp/` directories (no prompts required)
- Any other skill files or templates needed for project setup
- Git repository state (git remote -v, git status)

**Write:**
- Create all context files and directories in the target project (README.md, AGENTS.md, CLAUDE.md, GEMINI.md, CODEX.md, docs/, company/, etc.)
- Create bootstrap pointer files (.cursor/rules/, .gitignore)
- Create all archetype-specific structure files as defined in the Project Archetypes section

**Git operations:**
- Check remote configuration (git remote -v)
- Check if GitHub repo exists (gh repo view)
- Add remote origin (git remote add origin)
- Update submodules (git submodule update --remote)
- Add submodule (git submodule add)
- Clone repo (git clone)

**Filesystem operations:**
- Create symlinks (ln -s)

No prompts are required for these operations.

---

## Templates (load on demand)

Templates for README, CLAUDE.md, CODEX.md, docs/, and archetype-specific files live in **references/** in this skill directory. Load only when creating or updating project files.

| Reference | Use when |
|-----------|---------|
| [references/README-templates.md](references/README-templates.md) | Creating README.md, CLAUDE.md, or CODEX.md (Tech, Nexus, Admin, Creative) |
| [references/gitignore-cursor.md](references/gitignore-cursor.md) | Creating .gitignore or .cursor/rules/skill-library.mdc |
| [references/tech-docs-templates.md](references/tech-docs-templates.md) | Creating Tech docs/ (VISION, PROJECT, REQUIREMENTS, ARCHITECTURE, TODO, CONCEPTS) |
| [references/nexus-templates.md](references/nexus-templates.md) | Creating Nexus (single-org) files (company/, current/, people/, initiatives/, INDEX patterns, etc.) |
| [references/nexus-multi-client-templates.md](references/nexus-multi-client-templates.md) | Creating Nexus (multi-client) files (clients/, current/, portfolio dashboard, etc.) |
| [references/admin-templates.md](references/admin-templates.md) | Creating Admin files (TODO, GOALS, NOTES, LOG, inbox/, outbox/, contacts/, reference/) |
| [references/creative-templates.md](references/creative-templates.md) | Creating Creative docs/ (WORLD, STORY, CREATIVE_WORK) |
