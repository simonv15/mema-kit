# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# About Me
I am a junior AI engineer. When I ask you to implement something, please briefly explain the key architectural decision you're making and why. If I use incorrect terminology, gently correct me. 
Prefer well-commented code over terse code.

## Project Overview

mema-kit is a memory protocol kit for Claude Code skills. It provides a `.mema/` memory system that persists curated knowledge (architecture, decisions, lessons, patterns) across sessions, plus three built-in skills: `/onboard` (bootstrap memory for a project), `/recall` (load memory into current session), and `/create-skill` (generate new memory-aware skills).

The core innovation is the **memory protocol** — a 4-phase lifecycle (AUTO-LOAD → WORK → AUTO-SAVE & CURATE → AUTO-INDEX) that any skill can plug into.

## Repository Structure

```
mema-kit/
├── bin/cli.js                    # npx mema-kit CLI (copies skills to user projects)
├── skills/                       # Single source of truth for all distribution channels
│   ├── _memory-protocol.md       # Shared ADD/UPDATE/DELETE/NOOP curation rules
│   ├── onboard/SKILL.md          # /onboard — project memory bootstrap
│   ├── recall/SKILL.md           # /recall — session memory recall
│   └── create-skill/SKILL.md     # /create-skill — generate memory-aware skills
├── templates/                    # .mema/ memory file templates (copied by /onboard)
│   ├── index.md, decision.md, context.md, plan.md, lessons.md, patterns.md, status.md
├── package.json                  # npm package (bin → cli.js, zero runtime deps)
└── docs/
    └── guide.md                  # User-facing usage guide with worked examples
```

## Architecture

**Three built-in skills** form the starting point: `/onboard` bootstraps memory for a project (scans codebase, populates initial knowledge), `/recall` loads memory into the current session (read-only summary for cold-start), `/create-skill` generates new memory-aware skills at three complexity levels (simple, standard, advanced).

**Memory system** (`.mema/` directory in user projects):
- `index.md` is a rebuildable cache (pointer map), not source of truth. Skills rebuild it from directory scan if missing.
- Memory lifecycle per skill: AUTO-LOAD (read index.md, load relevant files) → WORK → AUTO-SAVE & CURATE (ADD/UPDATE/DELETE/NOOP) → AUTO-INDEX.
- All memory operations use Claude Code's native Read/Write tools — no external dependencies.
- `_memory-protocol.md` is shared across all skills (DRY). Each SKILL.md references it rather than duplicating curation rules.

**Distribution** is multi-channel but converges: `npx mema-kit` installs skills to `.claude/skills/`, then user runs `/onboard` for project setup. "Install the tool" and "set up the project" are deliberately separate.

## Key Conventions

- **Kebab-case** for all skill directories and commands: `create-skill`
- **Timestamp-based decision file naming:** `YYYY-MM-DD-short-name.md`
- **In-body metadata** (`**Status:** active | **Updated:** 2026-02-23`), not YAML frontmatter
- **Idempotent skills** — all safe to re-run (verify/repair, don't overwrite)
- **Zero runtime dependencies** — CLI uses only Node.js `fs` and `path`
- **`.mema/` gitignored by default** in user projects; `project-memory/` optionally committed; `.claude/skills/` always committed

## Memory System

This project uses mema-kit for persistent memory across sessions.

Memory lives in `.mema/`. At the start of each task, read `.mema/index.md` to load relevant context. After completing work, curate and save knowledge following the memory protocol in `.claude/skills/_memory-protocol.md`.

Memory is managed automatically by skills — do not manually modify `.mema/` files unless correcting an error.
