# It's a Human Problem. Stupid

Reusable session instructions for AI-assisted development. **Universal skill library for any model** (Claude, Gemini, etc.). Licensed under the [IAHP License](LICENSE).

**For AI agents:** Start with **AGENTS.md** in this repo. Projects point their model-specific file (e.g. `claude.md`, `gemini.md`) to AGENTS.md so the model learns purpose, which skills to use, and avoids reading full skills until work begins.

## Setup

This repository can be used as a global skills repository or as a submodule in a project-specific repository. Once linked, run `/setup` in a new project to bootstrap its structure and wire up the skill library automatically.

### Global Skills Repo

**1. Clone the repo:**
```bash
git clone git@github.com:<your-username>/iahp.git ~/src/iahp
```

**2. Link to your agent's skills directory:**

*macOS/Linux:*
```bash
ln -s ~/src/iahp ~/.claude/skills
```

*Windows (run in cmd):*
```cmd
mklink /J %USERPROFILE%\.claude\skills %USERPROFILE%\src\iahp
```

**3. Invoke:** `/coder`, `load the architect skill`, or however your LLM accepts skill commands

### Project-Specific Submodule

For sandboxed environments (VMs, web-based IDEs, Codex, CI runners) that can only access files within the project directory, embed the skills as a submodule:

```bash
git submodule add git@github.com:<your-username>/iahp.git .claude/skills
```

This makes the skill library self-contained within the repo — no symlinks or external paths required.

## Available Skills

The library is **dynamic** — skills may be added over time. **Canonical source:** `skills.json` at repo root. The table below is a convenience summary; when in doubt, trust `skills.json` and each skill's `SKILL.md` frontmatter.

| Skill | Tier | Purpose |
|-------|------|---------|
| `baseline` | standard | Base skill with global context and conventions; all other skills inherit from this |
| `coder` | standard | Execute coding goals, manage context files, follow coding standards |
| `architect` | advanced | System design, architecture decisions, requirements refinement |
| `visionary` | advanced | Product brainstorming, epics, user stories, vision planning |
| `conductor` | advanced | Multi-skill workflow orchestrator; plans pipelines, manages phase transitions |
| `tester` | standard | Strategic test orchestration; delegates to framework-specific agents |
| `reviewer` | standard | Objective code and test reviewer; validates against project documentation |
| `gate` | standard | UX and quality review gate; audits recent work before proceeding |
| `skeptic` | advanced | Architectural complexity critic; questions excess complexity and design gaps (read-only) |
| `sast` | standard | Static Application Security Testing; scans for vulnerabilities |
| `devops` | standard | Cloud infrastructure, deployment, CI/CD, and observability |
| `troubleshooter` | standard | Interactive diagnosis for complex problems requiring manual verification |
| `researcher` | fast | Codebase exploration, technology investigation, and domain research (read-only) |
| `setup` | standard | Bootstrap new projects with standard structure and documentation templates |
| `gacp` | standard | Git Add, Commit, Push; stages changes, crafts a message, pushes |
| `gccp` | standard | Git Collapse, Commit, Push; squash-merges a feature branch into target |
| `handoff` | standard | End-of-session wrap-up; updates RESUME.md and TOT.md, then delegates to gacp |
| `summarize` | fast | Live 4-line project dashboard; updates SUMMARY.json fields |
| `sitrep` | fast | Situation report: compact summary of what was just done and next steps |
| `skill-manager` | standard | Manage, create, and maintain skills in the iahp repository |
| `agents-manager` | standard | Agent lifecycle and coordination; spawns, tracks, and orchestrates instances |
| `executive-advisor` | advanced | Executive knowledge management, append-only timelines, career/business advisory |
| `administrative-advisor` | standard | Task-oriented project management for non-technical initiatives |
| `storyteller` | advanced | Narrative/creative framework management; story structure, world-building |
| `ucs` | standard | Bidirectional sync between repo context and user context targets (Obsidian, Notion, etc.) |
| `ucc` | standard | Sync + compact: runs UCS first, then clears checked tasks and compacts |
| `build` | standard | Build project artifacts with framework detection, staleness checks, and version bumping |
| `send` | standard | Build and distribute project artifacts to a configured destination |
| `hours` | fast | Time tracking for client projects; add hours, submit periods, view summaries |
| `step` | standard | Interactive step-through mode for decisions, action items, or review points |
| `paste` | fast | Clipboard paste helper for text and images on macOS terminals |
| `screenshot` | fast | Capture and analyze screenshots; full screen or targeted window/app |
| `whip` | fast | Launch a command in the current terminal with auto-retry for known prompts |

### Skills manifest (machine-readable)

`skills.json` at repo root lists each skill with `name`, `description`, `path`, optional `base_skill`, and `model_tier`. Tooling that consumes this repo as a bundle can use it to discover skills without walking directories or parsing frontmatter. Update it when adding or changing skills.

## Skill Structure

Each skill is a directory containing a `SKILL.md` file:

```
skills/
├── baseline/
│   └── SKILL.md      # Generic project context instructions
├── coder/
│   └── SKILL.md
├── architect/
│   └── SKILL.md
└── ...
```

Browse `~/.claude/skills/` to see available skills.

## Skill Inheritance

All skills inherit from `baseline` via `base_skill: baseline` in their SKILL.md frontmatter. This provides common conventions and context shared across all skills.

## Model Tiers

Each skill declares a `model_tier` in its SKILL.md frontmatter — the minimum model capability needed. Orchestrators map this abstract tier to platform-specific models at spawn time.

| Tier | When to use | Examples |
|------|-------------|----------|
| **fast** | Mechanical, read-only, or trivial tasks | summarize, paste, screenshot, researcher, whip, hours, sitrep |
| **standard** | Standard implementation, analysis, operational work (default) | coder, tester, reviewer, devops, gacp |
| **advanced** | Deep reasoning, creative synthesis, strategic orchestration | architect, visionary, conductor, storyteller |

Platform mapping:

| Tier | Claude Code | Gemini | Codex / Other |
|------|------------|--------|---------------|
| **fast** | `haiku` / `claude-haiku-4-5` | Flash | Cheapest available |
| **standard** | `sonnet` / `claude-sonnet-4-6` | Pro | Default tier |
| **advanced** | `opus` / `claude-opus-4-6` | Ultra / Pro | Most capable available |

The `model_tier` field appears in three places: SKILL.md frontmatter (source of truth), `skills.json` (machine-readable), and `agents.json` `default_model` (agent spawning).

## Context Depth System

Context depth limits context bloat while keeping all information available. Instead of loading everything upfront, skills read only what they need, when they need it — no knowledge is lost, just deferred.

**Context Depth 1 (CD1)** files (README, TODO, PROJECT) are read on startup by every skill. All other documentation follows the **Context Depth Protocol**: scan summaries first, deep-read only when the current task requires it. Skills promote additional files to CD1 in their Canonical Context section based on their domain focus. See `baseline/SKILL.md` for the full specification.

## Agent Orchestration

**Optional feature** — agent orchestration requires Task tool support (Claude Code CLI). Skills work perfectly without agents via direct invocation (e.g., `/coder` or "load the coder skill").

**Use agents when:**
- Running parallel tasks
- Coordinating multi-step workflows
- Background execution needed
- Your LLM supports Task tool

**Use direct skills when:**
- Sequential, single-threaded work
- LLM doesn't support Task tool (Gemini, older models)
- Simpler workflow preferred

**Agents** are runtime instances that execute work using **skills** as templates. The `agents.json` manifest maps agent types to skills and defines how to spawn them.

### Architecture

```
Skills (templates) ──maps to──> Agents (types) ──spawns──> Instances (runtime)
     SKILL.md                    agents.json              Task tool subagents
```

- **Skills** — Define roles, behaviors, constraints, and workflows
- **Agents** — Define how to instantiate skills as workers (model, subagent type)
- **Instances** — Running subagents executing specific tasks

### Available Agents

Most agents map 1:1 to their skill (same name, `general-purpose` type). Exceptions:

| Agent | Difference |
|-------|-----------|
| `explorer` | Maps to `baseline` skill (not its own). Type: `Explore`. |
| `architect` | Type: `Plan` (not general-purpose). |
| `researcher`, `skeptic`, `gate` | Type: `Explore` (read-only). |

See `agents.json` for the full manifest with model tiers.

### Managing Agents

Use `agents-manager` to edit, update, or maintain agent definitions in `agents.json`. For orchestrating multi-agent workflows at runtime, use `conductor`.

## Design Philosophy

### Model-Agnostic

This library works with **any LLM** (Claude, Gemini, GPT, etc.). All models read the same instructions. There are no model-specific skill files or behaviors.

- `CLAUDE.md`, `GEMINI.md`, etc. are **identical pointers** to `AGENTS.md`
- If a model needs different instructions, the library design is wrong
- Model-specific *quirks* (like workspace sandboxing) are environment issues, not instruction issues

### Single Source of Truth

**AGENTS.md is the only instruction file.** Everything else points to it.

```
Project files:
  CLAUDE.md  ─┐
  CODEX.md   ─┤
  GEMINI.md  ─┼──> AGENTS.md ──> skill library AGENTS.md ──> SKILL.md files
  .cursor/   ─┘
```

**Why:**
- One place to update = no drift between files
- No confusion about which file is authoritative
- Pointer files are disposable boilerplate

### No Redundancy

Don't repeat information across files:

| Wrong | Right |
|-------|-------|
| List skills in project AGENTS.md | LLM discovers skills from library |
| Copy rules into multiple files | Rules live in one place (skill library AGENTS.md or SKILL.md) |
| Model-specific instruction sections | Same instructions for all models |

### Dynamic Discovery

Skills are discovered at runtime, not enumerated in config:

- LLM reads skill library directory structure
- `skills.json` exists for tooling, not for LLMs
- Projects don't list which skills are "available" — all skills are available

### Environment vs Instructions

Separate tooling limitations from skill instructions:

| Environment issue | Instruction issue |
|-------------------|-------------------|
| Sandbox blocks `~/.claude/skills/` | Which files to read |
| CLI doesn't support Task tool | What a skill does |
| Rate limits | Workflow rules |

**Environment issues are solved by environment config** (submodules, CLI flags, etc.), not by adding workaround instructions.

### File Hierarchy (Projects)

```
project/
├─ AGENTS.md        # Instructions: points to skill library, permissions, rules
├─ CLAUDE.md        # Pointer: "Read AGENTS.md"
├─ CODEX.md         # Pointer: "Read AGENTS.md" (identical)
├─ GEMINI.md        # Pointer: "Read AGENTS.md" (identical)
├─ .cursor/rules/   # Pointer: "Read AGENTS.md"
└─ README.md        # Human docs (LLM reads for project context, not instructions)
```

### File Hierarchy (Skill Library)

```
iahp/
├─ AGENTS.md        # Entry point: purpose, discovery rules, behavioral rules
├─ CLAUDE.md        # Pointer (for direct entry into library)
├─ CODEX.md         # Pointer (identical)
├─ GEMINI.md        # Pointer (identical)
├─ skills.json      # Machine-readable manifest (for tooling)
├─ README.md        # Human documentation
└─ <skill>/
   └─ SKILL.md      # Skill definition
```

## Repository Info

Repository: [github.com/shaunsauve/iahp](https://github.com/shaunsauve/iahp)

Licensed under the [IAHP License](LICENSE) — do whatever you want with it, just keep the attribution. Contributors welcome!
