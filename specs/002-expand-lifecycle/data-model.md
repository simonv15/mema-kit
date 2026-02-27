# Data Model: Full AI-Assisted Development Lifecycle

**Phase**: 1 — Design
**Branch**: `002-expand-lifecycle`
**Date**: 2026-02-27

## Overview

All data is stored as markdown files in `.mema/`. No databases, no JSON config files, no binary formats. The "data model" describes the directory structure, file purposes, and state transitions managed by the 12 skills.

---

## The `.mema/` Directory Structure

```
.mema/
├── index.md                      # Rebuildable pointer map — read first
│
├── product/                      # Discovery phase outputs (written once, updated by re-running skills)
│   ├── seed.md                   # Raw idea capture
│   ├── clarify.md                # Clarified intent and scope
│   ├── research.md               # Competitor, market, and tech findings
│   ├── challenge.md              # Risks, assumptions, stress-test results
│   └── roadmap.md                # Prioritized feature list
│
├── features/                     # One directory per feature
│   ├── 001-feature-name/
│   │   ├── spec.md               # What + why (non-technical)
│   │   ├── plan.md               # Technical implementation design
│   │   ├── tasks.md              # Ordered implementation task list
│   │   └── status.md             # Current status + progress log
│   └── 002-another-feature/
│       └── ...
│
├── project/                      # Project-wide stable knowledge
│   ├── architecture.md           # Tech stack, system design, key patterns
│   ├── requirements.md           # Core constraints and non-negotiables
│   └── decisions/
│       └── YYYY-MM-DD-name.md    # Individual architectural decisions
│
├── agent/                        # Cross-session agent knowledge
│   ├── lessons.md                # Mistakes and how to avoid them
│   └── patterns.md               # Reusable approaches that worked
│
└── archive/
    └── 001-feature-name/         # Completed features (moved from features/)
        └── ...
```

---

## Entity 1: Product Memory (`product/`)

Holds the outputs of the five discovery skills. Written once during discovery; updated by re-running the relevant skill.

| File | Written by | Read by | Content |
|------|-----------|---------|---------|
| `seed.md` | `mema.seed` | `mema.clarify`, `mema.research`, `mema.roadmap` | Raw idea, stream of consciousness, initial thoughts |
| `clarify.md` | `mema.clarify` | `mema.research`, `mema.challenge`, `mema.roadmap` | Refined problem statement, target audience, scope, motivation |
| `research.md` | `mema.research` | `mema.challenge`, `mema.roadmap`, `mema.specify` | Competitor analysis, market context, tech stack options, sources |
| `challenge.md` | `mema.challenge` | `mema.roadmap`, `mema.specify` | Risk register, validated/risky assumptions, mitigations |
| `roadmap.md` | `mema.roadmap` | `mema.specify`, `mema.recall` | Prioritized feature list with one-line descriptions and feature directory references |

**Metadata format** (in-body, not YAML):
```
**Status:** active | **Updated:** 2026-02-27
```

---

## Entity 2: Feature (`features/NNN-name/`)

The central unit of work. Each feature is fully self-contained — all four files represent the complete lifecycle of that feature from specification to completion.

| File | Written by | Read by | Content |
|------|-----------|---------|---------|
| `spec.md` | `mema.specify` | `mema.plan`, `mema.tasks`, `mema.implement` | What the feature does and why — non-technical, user-focused |
| `plan.md` | `mema.plan` | `mema.tasks`, `mema.implement` | Technical design: approach, data model, key decisions |
| `tasks.md` | `mema.tasks` | `mema.implement` | Ordered checklist of implementation tasks with file paths |
| `status.md` | `mema.implement` | `mema.recall`, `mema.implement` | Current status, completed tasks log, next task |

**Feature status values**: `pending` → `in-progress` → `complete`

**Numbering**: 3-digit sequential (`001`, `002`, ...). Assigned by `mema.roadmap` (bulk) or `mema.specify` (single, scans for next available).

**Constraints**:
- Feature name is kebab-case
- Directory name format: `NNN-kebab-case-name` (no spaces, no uppercase)
- On completion: entire directory moves to `archive/NNN-name/`

---

## Entity 3: Project Knowledge (`project/`)

Stable, long-lived facts about the codebase. Updated when the project structure changes, not after every feature.

| File | Written by | Read by | Content |
|------|-----------|---------|---------|
| `architecture.md` | `mema.onboard`, `mema.implement` | All skills | Tech stack, system design, directory structure, key patterns |
| `requirements.md` | `mema.onboard` | `mema.specify`, `mema.plan` | Non-negotiables, constraints, client requirements |
| `decisions/YYYY-MM-DD-name.md` | `mema.plan`, `mema.implement` | All skills | Individual architectural decisions with reasoning |

---

## Entity 4: Agent Knowledge (`agent/`)

Cross-session, potentially cross-project knowledge. Accumulates over time.

| File | Written by | Read by | Content |
|------|-----------|---------|---------|
| `lessons.md` | `mema.implement`, `mema.create-skill` | All skills | Mistakes and how to avoid them; grouped by domain when >30 entries |
| `patterns.md` | `mema.implement`, `mema.create-skill` | All skills | Reusable approaches that worked; pattern + context + example |

---

## Entity 5: Index (`index.md`)

A pointer map rebuilt from directory scan if missing. **Never the source of truth.**

**Format** (updated from current to reflect new structure):

```markdown
# Memory Index

**Updated:** 2026-02-27

## Active Features
- `features/001-user-auth/` — JWT authentication for API (in-progress, step 2/5)
- `features/002-search/` — Full-text search across posts (pending)

## Product Discovery
- `product/seed.md` — Async standup tool for remote teams
- `product/roadmap.md` — 6 features defined, 1 in progress

## Project Knowledge
- `project/architecture.md` — Node.js + Fastify + PostgreSQL + Drizzle
- `project/decisions/2026-02-27-auth-jwt.md` — JWT with refresh tokens

## Agent Knowledge
- `agent/lessons.md` — 4 lessons recorded
- `agent/patterns.md` — 3 patterns recorded
```

---

## State Transitions

### Feature lifecycle

```
[not yet created]
       │
  /mema.specify
       │
  features/NNN/spec.md created
  status.md: "pending"
       │
  /mema.plan
       │
  features/NNN/plan.md created
       │
  /mema.tasks
       │
  features/NNN/tasks.md created
       │
  /mema.implement (first run)
       │
  status.md: "in-progress"
       │
  /mema.implement (subsequent runs)
       │
  All tasks complete
  status.md: "complete"
       │
  /mema.implement (archive on completion)
       │
  Moved to archive/NNN-name/
```

### Discovery lifecycle

```
/mema.seed → product/seed.md
/mema.clarify → product/clarify.md
/mema.research → product/research.md
/mema.challenge → product/challenge.md
/mema.roadmap → product/roadmap.md + features/NNN-name/ (one per feature)
```

Discovery is optional and non-blocking — a developer can skip directly to `/mema.specify` if they already know what to build.
