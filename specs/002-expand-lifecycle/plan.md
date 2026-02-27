# Implementation Plan: Full AI-Assisted Development Lifecycle

**Branch**: `002-expand-lifecycle` | **Date**: 2026-02-27 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-expand-lifecycle/spec.md`

## Summary

Expand mema-kit from a 5-skill memory protocol kit into a 12-skill full development lifecycle tool. Add 7 new discovery and feature-workflow skills (`mema.seed`, `mema.clarify`, `mema.research`, `mema.challenge`, `mema.roadmap`, `mema.specify`, `mema.tasks`), update 5 existing skills to use a restructured `.mema/` directory layout (`product/`, `features/`, `project/`, `agent/`), update the CLI to install all 12 skills, and rewrite documentation for the full lifecycle.

## Technical Context

**Language/Version**: Markdown (skills) + Node.js ≥ 16.7.0 (`bin/cli.js`)
**Primary Dependencies**: None — Claude Code native Read/Write/WebSearch tools only
**Storage**: File system — `.mema/` directories (markdown files)
**Testing**: Manual — invoke skills in Claude Code, verify `.mema/` file contents
**Target Platform**: Claude Code (any OS)
**Project Type**: CLI tool + skill library (markdown instructions)
**Performance Goals**: N/A for markdown skills; CLI install completes in <5 seconds
**Constraints**: Zero runtime dependencies; all skills under `mema.` namespace; 12-skill ceiling
**Scale/Scope**: 12 skills, ~25 file changes, ~30 new/updated markdown files

## Constitution Check

- [x] **I. Memory-First** — All 12 skills implement AUTO-LOAD → WORK → AUTO-SAVE → AUTO-INDEX. `/mema.recall` is read-only but still has AUTO-LOAD.
- [x] **II. Zero Runtime Dependencies** — `/mema.research` uses Claude Code's native WebSearch tool (not an npm package). CLI stays Node.js `fs`/`path` only.
- [x] **III. Idempotency** — All skills check existing state. Re-running any skill updates rather than duplicates. `/mema.onboard` migrates old structure and leaves new structure untouched.
- [x] **IV. Skills as Single Source of Truth** — All changes originate in `skills/`. `_memory-protocol.md` is updated first; all skills reference it.
- [x] **V. Simplicity** — 7 new skills is a large expansion. Each maps 1:1 to a distinct user story phase. `/review` was explicitly excluded. Brainstormer's 6-skill set reduced to 5 discovery skills by merging `/review` into idempotency. Documented below.

## Project Structure

### Documentation (this feature)

```text
specs/002-expand-lifecycle/
├── plan.md              # This file
├── research.md          # Phase 0 — 7 design decisions
├── data-model.md        # Phase 1 — .mema/ structure + file entities
├── quickstart.md        # Phase 1 — dev guide, test scenarios, pitfalls
├── contracts/
│   └── skill-contracts.md  # Phase 1 — all 12 skill interfaces
└── tasks.md             # Phase 2 — /speckit.tasks output (not yet created)
```

### Source Code (repository root)

```text
skills/
├── _memory-protocol.md           (UPDATE)
├── mema.onboard/SKILL.md         (UPDATE)
├── mema.recall/SKILL.md          (UPDATE)
├── mema.plan/SKILL.md            (UPDATE)
├── mema.implement/SKILL.md       (UPDATE)
├── mema.create-skill/SKILL.md    (UPDATE — path refs only)
├── mema.seed/SKILL.md            (NEW)
├── mema.clarify/SKILL.md         (NEW)
├── mema.research/SKILL.md        (NEW)
├── mema.challenge/SKILL.md       (NEW)
├── mema.roadmap/SKILL.md         (NEW)
├── mema.specify/SKILL.md         (NEW)
└── mema.tasks/SKILL.md           (NEW)

templates/
├── index.md                      (UPDATE — new 4-section format)
├── product/                      (NEW directory)
│   ├── seed.md
│   ├── clarify.md
│   ├── research.md
│   ├── challenge.md
│   └── roadmap.md
├── features/                     (NEW directory)
│   └── feature/
│       ├── spec.md
│       ├── plan.md
│       ├── tasks.md
│       └── status.md
├── project/                      (renamed from project-memory/)
│   ├── architecture.md
│   ├── requirements.md
│   └── decisions/decision.md
└── agent/                        (renamed from agent-memory/)
    ├── lessons.md
    └── patterns.md

bin/cli.js                        (UPDATE — install 12 skills)
docs/guide.md                     (MAJOR UPDATE)
CLAUDE.md                         (UPDATE — active technologies + recent changes)
```

**Structure Decision**: Single project, skills-library pattern. No `src/`, `tests/`, or `models/` directories — this is a markdown skill library with one Node.js file. All logic lives in SKILL.md files.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| 7 new skills (Principle V: Simplicity) | Each skill covers a distinct, non-overlapping lifecycle phase required by the spec (P1–P4 user stories) | Merging discovery skills into fewer: any merge (e.g., seed+clarify) creates a skill that does two things, violating single-responsibility and making re-runs ambiguous |

## Phase 0: Research

**Status**: Complete — see [research.md](research.md)

| Decision | Resolution |
|----------|------------|
| Migration strategy for old `.mema/` | `/mema.onboard` auto-migrates on re-run; no separate migration skill |
| Web search without dependencies | Claude Code native WebSearch tool — pure markdown instruction |
| Feature numbering | 3-digit sequential; `mema.roadmap` bulk-assigns, `mema.specify` scans for next N+1 |
| `mema.plan` role | Feature-level technical design: reads `features/NNN/spec.md` → writes `features/NNN/plan.md` |
| `_memory-protocol.md` scope | Surgical: rename directory references + update index format; curation rules unchanged |
| `mema.recall` updates | New "Active Features" section at top; full mode adds `product/roadmap.md` summary |
| Final 12-skill inventory | 7 new + 5 updated (see research.md Decision 7 table) |

## Phase 1: Design & Contracts

**Status**: Complete

### Artifacts

| Artifact | File | Purpose |
|----------|------|---------|
| Data model | [data-model.md](data-model.md) | Full `.mema/` directory structure, all entities, state transitions |
| Skill contracts | [contracts/skill-contracts.md](contracts/skill-contracts.md) | All 12 skill interfaces: reads, writes, behavior, idempotency |
| Development guide | [quickstart.md](quickstart.md) | Implementation order, test scenarios, pitfalls, done criteria |

### Key Design Choices

1. **Implementation order**: Foundation (protocol + templates + CLI) → Updated skills → New discovery skills → New feature-workflow skills → Docs. Each phase is independently testable.

2. **`_memory-protocol.md` updated first**: Every skill references it. Updating it before any skill prevents any skill referencing stale directory names.

3. **Discovery is optional, not a prerequisite**: `mema.specify` works with or without `product/` files. This makes the feature-workflow path (P2) fully independent of the discovery path (P1).

4. **`mema.plan` keeps its name**: The function is still planning — just scoped to feature-level technical design rather than goal-breaking. No rename confusion.

5. **Templates directory mirrors `.mema/` structure**: `templates/` contains one file per `.mema/` file. Organized as `templates/product/`, `templates/features/feature/`, etc. — matching the runtime structure exactly, making `/mema.onboard` straightforward to implement.

6. **`bin/cli.js` minimal change**: Add 7 new skill directory names to the existing copy loop. Existing logic is correct and unchanged.

7. **`docs/guide.md` major rewrite**: The current guide documents 5 skills. The new guide must document the full lifecycle with worked examples for all four user stories. This is the last item — written after all skills are done and tested.
