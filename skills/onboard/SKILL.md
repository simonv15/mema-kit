---
description: Bootstrap the mema-kit memory system for this project. Creates .mema/ directory, scans the project, populates initial memory, and configures CLAUDE.md and .gitignore.
---

# /onboard — Project Memory Bootstrap

You are setting up the mema-kit memory system for this project. Follow these steps carefully. This command is idempotent — safe to re-run. Never overwrite existing data.

## Step 1: Check Current State

Before creating anything, assess what already exists:

1. Check if `.mema/` directory exists
2. Check if `CLAUDE.md` exists and whether it contains a `## Memory System` section
3. Check if `.gitignore` exists and whether it contains `.mema` entries

Report what you found to the user: "Setting up mema-kit. Found existing .mema/ directory — will verify and repair." or "Fresh setup — creating everything from scratch."

## Step 2: Create .mema/ Directory Structure

Create the following directories if they don't already exist:

```
.mema/
├── _templates/
├── project-memory/
│   └── decisions/
├── task-memory/
├── agent-memory/
└── archive/
```

For each directory: if it exists, skip it. If it doesn't, create it.

## Step 3: Write Template Files

Write the following files to `.mema/_templates/`. If a template file already exists, **skip it** (the user may have customized it).

### `.mema/_templates/decision.md`

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

### `.mema/_templates/context.md`

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

### `.mema/_templates/plan.md`

```
# [Task Name] — Implementation Plan

**Status:** active | **Updated:** YYYY-MM-DD

## General Plan
<!-- High-level approach: architecture decisions, component design, data flow. Keep it to 1-2 paragraphs or a short list. This should answer "what are we building and how does it fit together?" -->

## Detailed Plan
<!-- Step-by-step implementation tasks. Each step should be specific enough to implement directly. -->

### Step 1: [Action]
<!-- What to do, which files to create/modify, any dependencies on prior steps. -->
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

### `.mema/_templates/lessons.md`

```
# Agent Lessons

**Updated:** YYYY-MM-DD

## Lessons

### [Short Title]
<!-- One-sentence lesson. -->
- **Context:** <!-- When/how this was discovered. -->
- **Example:** <!-- Concrete code example or scenario if applicable. -->

---

<!-- Add new lessons above this line. When entries exceed ~30, consolidate related lessons under grouped headers. -->
```

### `.mema/_templates/patterns.md`

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

### `.mema/_templates/status.md`

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

## Step 4: Scan the Project

This is the intelligence step. Read and analyze the project to populate memory with real content instead of empty placeholders.

### 4a: Detect Project Type and Stack

Read the following files (skip any that don't exist):

1. `package.json` or `pyproject.toml` or `Cargo.toml` or `go.mod` or `pom.xml` or `Gemfile` — to identify language, framework, and dependencies
2. `README.md` — to understand project purpose and setup
3. `CLAUDE.md` — to understand existing conventions and instructions
4. `tsconfig.json` or equivalent config files — to understand build setup

### 4b: Scan Directory Structure

List the top-level directories and key subdirectories (1-2 levels deep) to understand the project layout. Note:
- Source code location (`src/`, `lib/`, `app/`, etc.)
- Test location (`tests/`, `__tests__/`, `test/`, etc.)
- Config files present
- Any existing documentation

### 4c: Read Representative Source Files

Pick 2-3 source files that best represent the codebase patterns:
- The main entry point (e.g., `src/index.ts`, `main.py`, `main.go`)
- A representative module/component
- A test file (if tests exist)

Read these to understand coding patterns, style, and architecture.

### 4d: Summarize Findings

Before writing memory, compile your findings:
- **Project name** and purpose
- **Language/framework/stack** with versions
- **Architecture pattern** (monolith, microservices, CLI tool, library, etc.)
- **Key directories** and what they contain
- **Testing setup** (framework, patterns)
- **Build/run commands**
- **Notable conventions** (naming, patterns, config)

## Step 5: Populate Initial Memory

Using the scan findings, create memory files with **real content** (not empty placeholders).

### `.mema/project-memory/architecture.md`

Write an architecture overview based on what you discovered. Include:
- Tech stack with versions
- Project structure (key directories and their purposes)
- Architecture pattern
- Key entry points
- Build and run commands

Example format:

```
# Project Architecture

**Status:** active | **Updated:** [today's date]

## Stack
- **Language:** TypeScript 5.x
- **Runtime:** Node.js 20+
- **Framework:** Fastify 4.x
- **Database:** PostgreSQL 16 via Drizzle ORM
- **Testing:** Vitest

## Structure
- `src/` — Application source code
  - `routes/` — API route handlers
  - `services/` — Business logic
  - `db/` — Database schema and migrations
- `tests/` — Test files mirroring src/ structure

## Architecture
REST API following controller → service → repository layers.
Entry point: `src/app.ts`

## Commands
- `npm run dev` — Start development server
- `npm test` — Run test suite
- `npm run build` — Build for production
```

### `.mema/project-memory/requirements.md`

Write a requirements summary based on README, package.json description, and observed functionality:

```
# Project Requirements

**Status:** active | **Updated:** [today's date]

## Purpose
[What this project does, based on README and code]

## Key Requirements
- [Requirement discovered from code/docs]
- [Requirement discovered from code/docs]

## Constraints
- [Any constraints discovered (Node version, dependencies, etc.)]
```

### `.mema/agent-memory/lessons.md`

Create a starter lessons file with any project-specific gotchas discovered during scanning:

```
# Agent Lessons

**Updated:** [today's date]

## Lessons

<!-- Lessons will be added here as the agent learns from development experience. -->
```

If you discovered anything notable during scanning (e.g., unusual config, non-obvious setup steps), add it as the first lesson.

### `.mema/agent-memory/patterns.md`

Create a starter patterns file. If you identified clear patterns from the source files you read, add them:

```
# Agent Patterns

**Updated:** [today's date]

## Patterns

<!-- Patterns will be added here as the agent discovers reusable approaches. -->
```

### `.mema/index.md`

Build the index from the files you just created:

```
# Memory Index

**Updated:** [today's date]

## Active Tasks

## Project Knowledge
- `project-memory/architecture.md` — [one-line summary of stack/architecture]
- `project-memory/requirements.md` — [one-line summary of purpose]

## Recent Decisions

## Agent Lessons
- `agent-memory/lessons.md` — [N] lessons recorded
- `agent-memory/patterns.md` — [N] patterns recorded
```

## Step 6: Update CLAUDE.md

1. Read the current `CLAUDE.md` (if it exists)
2. Search for `## Memory System` in the file content
3. If found → **skip this step** (already configured)
4. If not found → append the following section at the end of the file
5. If `CLAUDE.md` doesn't exist → create the file with this content

Append this section:

```
## Memory System

This project uses mema-kit for persistent memory across sessions.

Memory lives in `.mema/`. At the start of each task, read `.mema/index.md` to load relevant context. After completing work, curate and save knowledge following the memory protocol in `.claude/skills/_memory-protocol.md`.

Memory is managed automatically by skills — do not manually modify `.mema/` files unless correcting an error.
```

## Step 7: Update .gitignore

1. Read the current `.gitignore` (if it exists)
2. Search for `.mema` in the file content
3. If found → **skip this step** (already configured)
4. If not found → append the following block at the end of the file
5. If `.gitignore` doesn't exist → create the file with this content

Append this block:

```
# mema-kit memory (developer-local)
.mema/*
# Uncomment to share project decisions with your team:
# !.mema/project-memory/
```

## Step 8: Confirm to the User

Print a summary of what was done, including what you discovered about the project:

```
mema-kit initialized! Here's what was set up:

[check] .mema/ directory structure (memory system)
[check] Memory templates in .mema/_templates/
[check] CLAUDE.md updated with memory system conventions
[check] .gitignore updated to exclude .mema/

Project scan results:
- [Language/framework discovered]
- [Architecture pattern discovered]
- [N] source directories mapped
- [Notable findings]

Memory populated:
- architecture.md — [summary]
- requirements.md — [summary]
- lessons.md — [N] initial lessons
- patterns.md — [N] initial patterns

Next: Start working on your project. Memory will be loaded and saved automatically by any mema-kit skill.
```

If this was a re-run (some items already existed), adjust the summary to show what was verified vs. created:

```
mema-kit verified! Everything looks good:

[check] .mema/ directory structure — already exists, verified
[check] Memory templates — already exist, skipped
[check] CLAUDE.md — memory section already present
[check] .gitignore — .mema/ already excluded

Your setup is intact. No changes were needed.
```
