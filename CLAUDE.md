# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Praxis-kit is a spec-driven development kit for Claude Code that adds structured workflow and intelligent memory management via slash commands. It enforces an **Explore → Plan → Code** workflow where the agent automatically saves curated knowledge and loads relevant context per task.

**Current status:** Implementation-ready — no source code exists yet, but detailed implementation plans are complete. The `docs/plan.md` (comprehensive spec), `docs/guide.md` (user-facing usage guide), and `docs/implementation/` (step-by-step build plans for every component) define the full MVP. Implementation follows 5 milestones sequentially, starting with Milestone 1 (Foundation).

## Planned Repository Structure

```
praxis-kit/
├── bin/cli.js                    # npx praxis-kit CLI (copies skills to user projects)
├── skills/                       # Single source of truth for all distribution channels
│   ├── _memory-protocol.md       # Shared ADD/UPDATE/DELETE/NOOP curation rules
│   ├── kickoff/SKILL.md          # /kickoff — project initialization
│   ├── profile/SKILL.md          # /profile — user profile setup
│   ├── explore/SKILL.md          # /explore — research & clarify
│   ├── plan-docs/SKILL.md        # /plan-docs — implementation plans
│   ├── gen-test/SKILL.md         # /gen-test — TDD test cases
│   └── implement/SKILL.md        # /implement — code + tests
├── templates/                    # .praxis/ memory file templates (copied by /kickoff)
│   ├── index.md, decision.md, context.md, plan.md, lessons.md, status.md
├── package.json                  # npm package (bin → cli.js, zero runtime deps)
└── docs/
    ├── plan.md                   # Full project spec and milestone definitions
    ├── guide.md                  # User-facing usage guide
    └── implementation/           # Step-by-step build plans (00-09)
        ├── 00-overview.md        # Reading order, dependency graph, milestone map
        ├── 01-memory-protocol.md # → skills/_memory-protocol.md
        ├── 02-templates.md       # → templates/*.md
        ├── 03-kickoff-skill.md   # → skills/kickoff/SKILL.md
        ├── 04-profile-skill.md   # → skills/profile/SKILL.md
        ├── 05-explore-skill.md   # → skills/explore/SKILL.md
        ├── 06-plan-docs-skill.md # → skills/plan-docs/SKILL.md
        ├── 07-gen-test-skill.md  # → skills/gen-test/SKILL.md
        ├── 08-implement-skill.md # → skills/implement/SKILL.md
        └── 09-cli-packaging.md   # → bin/cli.js + package.json
```

## Implementation Plans

`docs/implementation/` contains build-ready plans for every component, numbered in dependency order (01→09). Each plan includes the complete file content to produce, reasoning behind decisions, and step-by-step build instructions. **Always read the relevant implementation plan before building a component.** See `docs/implementation/00-overview.md` for the dependency graph and reading order.

## Architecture

**Six slash commands** form the workflow: `/kickoff` → `/profile` → `/explore` → `/plan-docs` → `/gen-test` → `/implement`. Skills degrade gracefully — each checks prerequisites and guides users if something is missing.

**Memory system** (`.praxis/` directory in user projects):
- `index.md` is a rebuildable cache (pointer map), not source of truth. Skills rebuild it from directory scan if missing.
- Memory lifecycle per skill: AUTO-LOAD (read index.md, load relevant files) → WORK → AUTO-SAVE & CURATE (ADD/UPDATE/DELETE/NOOP) → AUTO-INDEX.
- All memory operations use Claude Code's native Read/Write tools — no external dependencies.
- `_memory-protocol.md` is shared across all 6 skills (DRY). Each SKILL.md references it rather than duplicating curation rules.

**Distribution** is multi-channel but converges: `npx praxis-kit` (or Vercel Skills, or manual copy) installs skills to `.claude/skills/`, then user runs `/kickoff` for project setup. "Install the tool" and "set up the project" are deliberately separate.

## Key Conventions

- **Kebab-case** for all skill directories and commands: `plan-docs`, `gen-test`
- **Timestamp-based decision file naming:** `YYYY-MM-DD-short-name.md`
- **In-body metadata** (`**Status:** active | **Updated:** 2026-02-23`), not YAML frontmatter
- **Idempotent skills** — all safe to re-run (verify/repair, don't overwrite)
- **Zero runtime dependencies** — CLI uses only Node.js `fs` and `path`
- **`.praxis/` gitignored by default** in user projects; `project-memory/` optionally committed; `.claude/skills/` always committed

## Milestones

1. Foundation: `_memory-protocol.md` + templates + `/kickoff` + `/profile`
2. Explore phase: `/explore` with full memory read/write/prune cycle
3. Plan phase: `/plan-docs` with memory integration
4. Code phase: `/gen-test` + `/implement` with task archiving
5. Packaging: `bin/cli.js`, npm publish, Vercel Skills, integration testing across 3 project types

See `docs/plan.md` for full task breakdowns per milestone.
