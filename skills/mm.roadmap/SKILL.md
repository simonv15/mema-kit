---
description: Synthesize discovery outputs into a prioritized project plan and feature list. Creates numbered feature directories in .mema/features/ ready for specification and implementation.
---

# /mm.roadmap — Project Roadmap

You are executing the /mm.roadmap skill. Follow these steps carefully.

This skill synthesizes everything from the discovery phase (seed, clarify, research, challenge) into a structured project plan with a prioritized feature list. It creates feature directories ready for `/mm.specify`.

## AUTO-LOAD

1. Read `.mema/index.md`
2. Read all available `product/` files:
   - `product/seed.md` — the original idea
   - `product/clarify.md` — refined intent (if exists)
   - `product/research.md` — findings and recommended approach (if exists)
   - `product/challenge.md` — risks and constraints (if exists)
3. Check what feature directories already exist in `features/` — to avoid creating duplicates
4. If `product/roadmap.md` exists, read it — re-run will update it

## WORK

### Synthesize the Plan

Using the discovery outputs, derive:

**Problem statement**: One paragraph — specific problem, specific audience, why current solutions fall short.

**Value proposition**: One sentence — what this does better than alternatives, for whom.

**Feature list**: Break the full vision into discrete, independently buildable features. For each feature:
- Name (kebab-case, 2-4 words)
- One-line description
- Priority: P1 (MVP — must have), P2 (important — ship soon), P3 (nice to have)
- Estimated complexity: Small / Medium / Large

**MVP scope**: The smallest subset that delivers real value — typically P1 features only.

**Out of scope**: Features explicitly deferred.

### Number Features

Assign 3-digit sequential numbers starting from 001. If feature directories already exist in `features/`:
- Read their names to determine the current highest number N
- Start new features from N+1

Order features by priority (P1 first), then by logical dependency (if feature B depends on feature A, A gets a lower number).

### Create Feature Directories

For each feature in the roadmap, create a directory `features/NNN-kebab-name/` with a starter `status.md`:

```
# [Feature Name] — Status

**Status:** pending | **Updated:** [today's date]

## Current Status

`pending` — defined in roadmap, not yet specified
```

Do NOT create spec.md, plan.md, or tasks.md — those are created by `/mm.specify`, `/mm.plan`, and `/mm.tasks`.

For feature directories that already exist: skip creation, do not overwrite.

### Handle Re-run

If `roadmap.md` already exists:
- Show current feature list
- Ask: "Update roadmap (add/reprioritize features), or start fresh?"
- Updating: ADD new features (with new numbers), UPDATE descriptions/priorities for existing ones. NEVER delete existing feature directories.

### Save

Write `.mema/product/roadmap.md`:

```
# [Project Name] — Roadmap

**Status:** active | **Updated:** [today's date]

## Problem Statement

[Specific problem, specific audience, why current solutions fail]

## Value Proposition

[What this does better, for whom — one sentence]

## Feature List

| # | Feature | Description | Priority | Complexity | Directory |
|---|---------|-------------|----------|------------|-----------|
| 001 | [name] | [one line] | P1 — MVP | Medium | `features/001-name/` |
| 002 | [name] | [one line] | P2 | Small | `features/002-name/` |

## MVP Scope

[P1 features that form the minimum viable product]

## Out of Scope

- [Explicitly deferred features]
```

### Present to User

```
## Roadmap: [Project Name]

[N] features defined. MVP = [P1 feature names].

Feature directories created:
- features/001-name/ (pending)
- features/002-name/ (pending)
[...]

Next: Run /mm.specify to write the spec for your first feature.
Start with: /mm.specify 001
```

## AUTO-SAVE & CURATE

- ADD or UPDATE `product/roadmap.md`
- NOOP on all other memory files

## AUTO-INDEX

Update `.mema/index.md`:
1. Add or update `## Product Discovery`: `- \`product/roadmap.md\` — [N] features; MVP = [P1 features]`
2. Add each new feature directory to `## Active Features`: `- \`features/NNN-name/\` — [one-line description] (pending)`
3. Update `**Updated:**` date
