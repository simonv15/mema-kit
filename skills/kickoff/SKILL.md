---
description: Initialize a project for spec-driven development with Praxis-kit. Creates .praxis/ memory structure, updates CLAUDE.md, and configures .gitignore.
---

# /kickoff — Project Initialization

You are initializing this project for spec-driven development with Praxis-kit. Follow these steps carefully. This command is idempotent — it's safe to re-run. Never overwrite existing data.

## Step 1: Check Current State

Before creating anything, assess what already exists:

1. Check if `.praxis/` directory exists
2. Check if `CLAUDE.md` exists and whether it contains a `## Praxis-kit Workflow` section
3. Check if `.gitignore` exists and whether it contains `.praxis` entries

Report what you found to the user: "Setting up Praxis-kit. Found existing .praxis/ directory — will verify and repair." or "Fresh setup — creating everything from scratch."

## Step 2: Create .praxis/ Directory Structure

Create the following directories if they don't already exist:

```
.praxis/
├── _templates/
├── project-memory/
│   └── decisions/
├── task-memory/
├── agent-memory/
└── archive/
```

For each directory: if it exists, skip it. If it doesn't, create it.

## Step 3: Write Template Files

Write the following files to `.praxis/_templates/`. If a template file already exists, **skip it** (the user may have customized it).

### `.praxis/_templates/decision.md`

```
# [Decision Title]

**Status:** active | **Updated:** YYYY-MM-DD

## Context
<!-- What situation or question prompted this decision? What problem are we solving? -->

## Decision
<!-- What was decided? Be specific and concrete. -->

## Options Considered

### Option A: [Name]
<!-- Brief description. Why chosen/rejected. -->

### Option B: [Name]
<!-- Brief description. Why chosen/rejected. -->

## Reasoning
<!-- Why this option was selected. What factors mattered most? What trade-offs were accepted? -->

## Consequences
<!-- What are the implications? What does this enable or constrain? Any known trade-offs or risks? -->
```

### `.praxis/_templates/context.md`

```
# [Topic] — Exploration Context

**Status:** active | **Updated:** YYYY-MM-DD

## Summary
<!-- 2-3 sentence overview of what was explored and the key takeaway. -->

## Key Findings
<!-- Bullet list of important facts, constraints, or insights discovered. Be specific and concise. -->

-
-
-

## Open Questions
<!-- What remains unresolved? What needs further exploration or a decision? -->

-
-

## Relates To
<!-- Links to related memory files (decisions, other context, plans). Use relative paths. -->

-
```

### `.praxis/_templates/plan.md`

```
# [Task Name] — Implementation Plan

**Status:** active | **Updated:** YYYY-MM-DD

## General Plan
<!-- High-level approach: architecture decisions, component design, data flow. Keep it to 1-2 paragraphs or a short list. This should answer "what are we building and how does it fit together?" -->

## Detailed Plan
<!-- Step-by-step implementation tasks. Each step should be specific enough to implement directly. -->

### Step 1: [Action]
- Files: `path/to/file`
- Details:

### Step 2: [Action]
- Files: `path/to/file`
- Details:

### Step 3: [Action]
- Files: `path/to/file`
- Details:

## Out of Scope
<!-- What this plan explicitly does NOT cover. Prevents scope creep during implementation. -->

-
```

### `.praxis/_templates/lessons.md`

```
# Agent Lessons

**Updated:** YYYY-MM-DD

## Lessons

### [Short Title]
- **Context:** <!-- When/how this was discovered. -->
- **Example:** <!-- Concrete code example or scenario if applicable. -->

---

<!-- Add new lessons above this line. When entries exceed ~30, consolidate related lessons under grouped headers. -->
```

### `.praxis/_templates/patterns.md`

```
# Agent Patterns

**Updated:** YYYY-MM-DD

## Patterns

### [Pattern Name]
- **Structure:** <!-- How the pattern is organized. -->
- **Example:** <!-- Concrete usage example. -->

---

<!-- Add new patterns above this line. -->
```

### `.praxis/_templates/status.md`

```
# [Task Name] — Status

**Status:** active | **Updated:** YYYY-MM-DD

## Progress

- [ ] Step 1: [description]
- [ ] Step 2: [description]
- [ ] Step 3: [description]

## Notes
<!-- Any blockers, deviations from plan, or important observations during implementation. -->

## Completed
**Completed:**
```

## Step 4: Create Starter Files

Create these files **only if they don't already exist**. If they exist, leave them untouched.

### `.praxis/index.md`

```
# Memory Index

**Updated:** [today's date]

<!-- Format: - `file-path` — one-line summary -->

## Active Tasks

## Project Knowledge
- `project-memory/architecture.md` — Project architecture (not yet documented)
- `project-memory/requirements.md` — Project requirements (not yet documented)

## Recent Decisions

## Agent Lessons
```

### `.praxis/project-memory/architecture.md`

```
# Project Architecture

**Status:** active | **Updated:** [today's date]

<!-- This file is populated by /explore as you research your project's technical decisions. -->
```

### `.praxis/project-memory/requirements.md`

```
# Project Requirements

**Status:** active | **Updated:** [today's date]

<!-- This file is populated by /explore as you discover and document project requirements. -->
```

### `.praxis/agent-memory/lessons.md`

```
# Agent Lessons

**Updated:** [today's date]

## Lessons

<!-- Lessons will be added here by /implement as the agent learns from development experience. -->
```

### `.praxis/agent-memory/patterns.md`

```
# Agent Patterns

**Updated:** [today's date]

## Patterns

<!-- Patterns will be added here by /implement as the agent discovers reusable approaches. -->
```

## Step 5: Update CLAUDE.md

1. Read the current `CLAUDE.md` (if it exists)
2. Search for `## Praxis-kit Workflow` in the file content
3. If found → **skip this step** (already configured)
4. If not found → append the following section at the end of the file
5. If `CLAUDE.md` doesn't exist → create the file with this content

Append this section:

```
## Praxis-kit Workflow

This project uses spec-driven development. Follow the Explore → Plan → Code workflow:

1. `/explore` — Research and clarify before making decisions
2. `/plan-docs` — Generate implementation-ready plans from exploration
3. `/gen-test` — Generate TDD test cases from plans
4. `/implement` — Implement code following the plan, run tests, save lessons

Memory lives in `.praxis/`. At the start of each task, read `.praxis/index.md` to load relevant context. Memory is managed automatically by skills — do not manually modify `.praxis/` files unless correcting an error.
```

## Step 6: Update .gitignore

1. Read the current `.gitignore` (if it exists)
2. Search for `.praxis` in the file content
3. If found → **skip this step** (already configured)
4. If not found → append the following block at the end of the file
5. If `.gitignore` doesn't exist → create the file with this content

Append this block:

```
# Praxis-kit memory (developer-local)
.praxis/*
# Uncomment to share project decisions with your team:
# !.praxis/project-memory/
```

## Step 7: Confirm to the User

Print a summary of what was done:

```
Praxis-kit initialized! Here's what was set up:

✓ .praxis/ directory structure (memory system)
✓ Memory templates in .praxis/_templates/
✓ Starter files: index.md, architecture.md, requirements.md, lessons.md, patterns.md
✓ CLAUDE.md updated with workflow conventions
✓ .gitignore updated to exclude .praxis/

Next steps:
1. Run /profile to set up your developer profile
2. Run /explore to start researching your project

Tip: .praxis/ is gitignored by default. To share project decisions with your team,
uncomment the !.praxis/project-memory/ line in .gitignore.
```

If this was a re-run (some items already existed), adjust the summary to show what was verified vs. created:

```
Praxis-kit verified! Everything looks good:

✓ .praxis/ directory structure — already exists, verified
✓ Memory templates — already exist, skipped
✓ Starter files — already exist, preserved
✓ CLAUDE.md — workflow section already present
✓ .gitignore — .praxis/ already excluded

Your setup is intact. No changes were needed.
```
