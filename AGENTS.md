# Agent entry point

This repo is a **universal skill library for any model** (Claude, Gemini, etc.). You were sent here from a project's model-specific file (e.g. `claude.md`, `gemini.md`) that points to this file as the starting point.

## Purpose

- **Skills** = reusable session instructions. Each skill lives in a directory with a `SKILL.md` (or `skill.md`) file.
- **The library is dynamic** — skills may be added or changed over time. Do not assume a fixed list.
- **Your job:** Understand what this library is, learn **which skills apply to the current project**, and **avoid reading full skill contents until real work begins** so you conserve context.

## Skills vs Agents

**Skills (Universal):**
- Work with any LLM (Claude, Gemini, etc.)
- Invoked directly (e.g., `/coder`, `/architect`)
- Sequential, single-context execution
- Core functionality

**Agents (Optional Enhancement):**
- Require Task tool support (Claude Code CLI)
- Spawned as subagents for parallel/background work
- Advanced orchestration patterns
- See `agents.json` and `agents-manager` skill
- **Not required** — Skills work perfectly without agents

## Which skills to read

- The **project** that pointed you here may be configured with a specific skill list (e.g. "Skills: /coder, /visionary" in their rules or prompt).
- Use that configuration. Only the skills the project (or user) specifies apply.
- **Do not** read every `SKILL.md` in this repo up front. Read a skill's full `SKILL.md` only when:
  - The user invokes that skill (e.g. "use coder", "/coder"), or
  - You are starting work that clearly requires that skill.
- To see what's available **without loading full contents:** list subdirectories in this repo; each skill is a directory containing `SKILL.md` or `skill.md`. Many skills have a `description` in the file's frontmatter (first few lines)—you can read that to get a one-liner without loading the whole file.

## Skill Selection Guide

Common decision points when choosing between similar skills:

| If you need... | Use | Not |
|---------------|-----|-----|
| Code standards, architecture validation, test quality | `/reviewer` | `/gate` |
| UX quality checkpoint before next phase | `/gate` | `/reviewer` |
| Manual investigation of visual/UI/interaction bugs | `/tester` (debug mode) | `/coder` |
| Automated test strategy and orchestration | `/tester` (plan/suite) | `/reviewer` |
| Design decisions, system architecture | `/architect` | `/coder` |
| Product direction, epics, user stories | `/visionary` | `/architect` |
| Codebase exploration, technology research | `/researcher` | `/coder` |
| Structural complexity, redundancy, design smell | `/skeptic` | `/reviewer` |

**`/reviewer` vs `/gate` vs `/skeptic`:** Reviewer is an adversarial code analyst — validates implementations against documented standards (ARCHITECTURE.md, REQUIREMENTS.md, CLAUDE.md). Gate is a UX quality checkpoint — audits user-facing features for completeness, error handling, and polish before phase transitions. Skeptic is an architectural critic — questions structural complexity, misleading abstractions, and design decisions at the system level. Reviewer writes to REVIEW.md; Gate produces approve/block decisions; Skeptic reports findings in conversation only (read-only, never writes files).

## Model Tiers

Skills declare a `model_tier` in frontmatter — the minimum model capability needed. Tiers use generic names so skills work across any LLM platform. This is metadata for orchestrators to consume; it is **not yet auto-routed**. Currently, only `agents.json` `default_model` is consumed at runtime (for agent spawning via Claude Code Task tool, using platform-specific model names). Direct skill invocations run on the session's current model.

| Tier | Skills | Rationale |
|------|--------|-----------|
| **fast** | summarize, paste, whip, screenshot, researcher, hours, sitrep | Mechanical, read-only, or trivial. No reasoning needed. |
| **standard** | coder, tester, reviewer, gate, devops, sast, gacp, gccp, handoff, setup, send, build, step, ucs, ucc, skill-manager, agents-manager, troubleshooter, administrative-advisor, baseline | Standard implementation, analysis, and operational work. Default tier. |
| **advanced** | architect, visionary, executive-advisor, storyteller, conductor, skeptic | Deep reasoning, creative synthesis, strategic orchestration. |

### Platform Model Mapping

The `model_tier` field is abstract and LLM-agnostic. Each platform maps tiers to concrete models. Update the model IDs below as providers release new versions.

| Tier | Claude | Gemini | OpenAI | Other |
|------|--------|--------|--------|-------|
| **fast** | haiku (`claude-haiku-4-5`) | Flash | gpt-4o-mini | Cheapest available |
| **standard** | sonnet (`claude-sonnet-4-6`) | Pro | gpt-4o | Default capable |
| **advanced** | opus (`claude-opus-4-6`) | Ultra / Deep Research | o3 | Most capable available |

**Runtime note:** `agents.json` `default_model` uses Claude-specific names (`haiku`, `sonnet`, `opus`) because it's consumed directly by the Claude Code Task tool. When adapting for other platforms, map the skill's `model_tier` through this table to select the appropriate model.

## What to do now

1. **Empty project:** If the current project appears empty (no README.md, no docs/ or archetype structure), invoke the setup skill to bootstrap before other work.
2. You have the purpose. If the project configured specific skills, use those. Otherwise list skill directories (or read frontmatter descriptions) to see what's available.
3. Be terse until a skill is loaded. If the user hasn't chosen a skill, ask which skill to use (or suggest from what you discovered).
4. When the user or task clearly requires a skill, **then** read that skill's `SKILL.md` (and its `base_skill` if present in frontmatter). Do not preload other skills.
5. For project setup and human-facing docs, see `README.md` in this repo.
