# Contracts: 12-Skill Interface Definitions

**Phase**: 1 — Design
**Branch**: `002-expand-lifecycle`
**Date**: 2026-02-27

## Overview

Each skill contract defines: invocation syntax, what it reads from `.mema/`, what it writes, and its memory lifecycle role. All skills follow AUTO-LOAD → WORK → AUTO-SAVE & CURATE → AUTO-INDEX.

---

## Discovery Skills (Product Phase)

### `/mema.seed [optional: inline idea]`

| | |
|---|---|
| **Reads** | Nothing required — first skill in the chain |
| **Writes** | `.mema/product/seed.md` |
| **Behavior** | Captures the user's idea exactly as stated. If no argument, prompts for input. Mirrors the idea back and suggests `/mema.clarify` next. |
| **Idempotency** | Overwrites `seed.md` on re-run after confirming with user. |

---

### `/mema.clarify`

| | |
|---|---|
| **Reads** | `.mema/product/seed.md` |
| **Writes** | `.mema/product/clarify.md` |
| **Behavior** | Asks 3–5 targeted questions covering: problem being solved, target audience, motivation, scope, constraints. Saves a structured summary of the clarified intent. |
| **Idempotency** | On re-run: shows existing clarify.md, asks what to refine. |
| **Guard** | If `seed.md` is missing, warns and offers to accept an inline description. |

---

### `/mema.research [optional: focus area]`

| | |
|---|---|
| **Reads** | `.mema/product/seed.md`, `.mema/product/clarify.md` |
| **Writes** | `.mema/product/research.md` |
| **Behavior** | Uses WebSearch tool to find: existing solutions/competitors, market context, technical options. Saves findings with source URLs. Optional focus area (e.g., "competitors", "tech stack") narrows the search. |
| **Idempotency** | On re-run: appends new findings, marks date of refresh. |
| **Guard** | If web search unavailable: informs user, proceeds with training knowledge, flags limitation in output. |

---

### `/mema.challenge`

| | |
|---|---|
| **Reads** | `.mema/product/seed.md`, `.mema/product/clarify.md`, `.mema/product/research.md` |
| **Writes** | `.mema/product/challenge.md` |
| **Behavior** | Stress-tests the idea: validates/challenges assumptions, surfaces risks with severity/likelihood/mitigation, identifies blind spots, suggests alternatives for critical failures. |
| **Idempotency** | On re-run: updates challenge.md with new analysis. |

---

### `/mema.roadmap`

| | |
|---|---|
| **Reads** | `.mema/product/` (all discovery files), `.mema/index.md` |
| **Writes** | `.mema/product/roadmap.md`, creates `.mema/features/NNN-name/` directories (one per feature) with `status.md: pending` |
| **Behavior** | Synthesizes discovery outputs into a prioritized feature list. Creates numbered feature directories. Outputs: problem statement, value proposition, feature list with priorities, MVP scope. |
| **Idempotency** | On re-run: updates roadmap.md; does not recreate existing feature directories; only adds new ones. |

---

## Feature Workflow Skills

### `/mema.specify [optional: feature description or number]`

| | |
|---|---|
| **Reads** | `.mema/index.md`, `.mema/product/roadmap.md` (if exists), `.mema/product/research.md` (if exists), `.mema/project/architecture.md` (if exists) |
| **Writes** | `.mema/features/NNN-name/spec.md`, creates directory if needed |
| **Behavior** | If roadmap exists: presents feature list, user picks one. If no roadmap or inline description given: generates spec from description. Spec covers: purpose, user scenarios, acceptance criteria, constraints. |
| **Idempotency** | On re-run for existing feature: shows current spec, offers to update specific sections. |
| **Numbering** | Scans `features/` for highest N, uses N+1. If roadmap created the directory, uses existing number. |

---

### `/mema.plan [optional: feature name or number]`

| | |
|---|---|
| **Reads** | `.mema/features/NNN/spec.md`, `.mema/project/architecture.md`, `.mema/project/decisions/`, `.mema/agent/lessons.md` |
| **Writes** | `.mema/features/NNN/plan.md` |
| **Behavior** | Creates technical implementation design: approach, data model/entities, key decisions, file structure. Informed by existing architecture and past lessons. |
| **Idempotency** | On re-run: updates plan.md, marks previous version superseded. |
| **Guard** | If `spec.md` missing for the feature: prompts to run `/mema.specify` first. |

---

### `/mema.tasks [optional: feature name or number]`

| | |
|---|---|
| **Reads** | `.mema/features/NNN/spec.md`, `.mema/features/NNN/plan.md` |
| **Writes** | `.mema/features/NNN/tasks.md` |
| **Behavior** | Generates an ordered, checkable task list with file paths. Tasks are grouped by phase (setup, core, polish). Each task is specific enough to execute without additional context. |
| **Idempotency** | On re-run: regenerates tasks.md (warns if tasks are partially complete). |

---

### `/mema.implement [optional: feature name, step number, or "all"]`

| | |
|---|---|
| **Reads** | `.mema/features/NNN/tasks.md`, `.mema/features/NNN/plan.md`, `.mema/features/NNN/status.md`, `.mema/project/architecture.md`, `.mema/agent/lessons.md` |
| **Writes** | Source code files (per tasks.md), `.mema/features/NNN/status.md`, `.mema/agent/lessons.md` (if lessons found), `.mema/project/decisions/` (if decisions made) |
| **Behavior** | Executes one task at a time by default. Updates status.md after each task. On completion of all tasks: marks status complete, offers to archive. |
| **Idempotency** | Checks current task status before executing; skips already-complete tasks. |
| **Archive** | On full completion: moves `features/NNN/` to `archive/NNN/`, removes from index Active Features. |

---

## Utility Skills

### `/mema.onboard`

| | |
|---|---|
| **Reads** | Project files (README, package.json, source files) |
| **Writes** | `.mema/` directory structure, `project/architecture.md`, `project/requirements.md`, `index.md`, `.gitignore` entry |
| **Behavior** | Scans project and populates memory. On new project: creates empty structure. On existing project: scans codebase. On re-run: updates stale, leaves accurate. **Migration**: detects old `project-memory/`/`task-memory/`/`agent-memory/` structure and migrates to new paths. |

---

### `/mema.recall [optional: "full"]`

| | |
|---|---|
| **Reads** | `.mema/index.md`, active `features/NNN/status.md` files, `project/architecture.md` |
| **Writes** | Nothing (read-only) |
| **Behavior** | Prints formatted context summary. **Minimal** (default): active features + status, project identity, next action. **Full**: adds product discovery summary, recent decisions, lessons, patterns. |

---

### `/mema.create-skill`

| | |
|---|---|
| **Reads** | `.mema/index.md`, `.mema/agent/patterns.md` |
| **Writes** | `.claude/skills/[name]/SKILL.md`, `.mema/agent/patterns.md` |
| **Behavior** | Generates new memory-aware skills. (Unchanged from 001-enhance-create-skill — path references updated to new `.mema/` structure.) |

---

## CLI Contract: `npx mema-kit`

```bash
npx mema-kit               # installs all 12 skills to .claude/skills/
npx mema-kit --list        # lists skills that would be installed
npx mema-kit --force       # overwrites existing skill files
```

Installs to `.claude/skills/`:
```
mema.onboard/SKILL.md
mema.recall/SKILL.md
mema.seed/SKILL.md
mema.clarify/SKILL.md
mema.research/SKILL.md
mema.challenge/SKILL.md
mema.roadmap/SKILL.md
mema.specify/SKILL.md
mema.plan/SKILL.md
mema.tasks/SKILL.md
mema.implement/SKILL.md
mema.create-skill/SKILL.md
_memory-protocol.md
```

**Behavior unchanged from current**: copies files from `skills/` directory, creates `.claude/skills/` if it doesn't exist, preserves existing skill files unless `--force` is passed.
