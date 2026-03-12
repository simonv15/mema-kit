---
description: Bootstrap the mema-kit memory system for this project. Creates .mema/ directory, scans the project, populates initial memory, and configures CLAUDE.md and .gitignore.
---

# /mm.onboard — Project Memory Bootstrap

You are setting up the mema-kit memory system for this project. Follow these steps carefully. This command is idempotent — safe to re-run. Never overwrite existing data without confirming.

## Step 1: Check Current State

Before creating anything, assess what already exists:

1. Check if `.mema/` directory exists
2. Check if it uses the **old structure** (`project-memory/`, `task-memory/`, `agent-memory/`) — if so, migration is needed
3. Check if `CLAUDE.md` exists and has a `## Memory System` section
4. Check if `.gitignore` contains `.mema` entries

Report to the user: "Setting up mema-kit. Found existing .mema/ — will verify and update." or "Fresh setup — creating everything from scratch." or "Found old mema-kit structure — will migrate to new layout."

## Step 2: Migrate Old Structure (if needed)

If the old directory structure exists, migrate it before creating anything new:

- If `.mema/project-memory/` exists and `.mema/project/` does not → rename to `.mema/project/`; tell user: "Migrated project-memory/ → project/"
- If `.mema/agent-memory/` exists and `.mema/agent/` does not → rename to `.mema/agent/`; tell user: "Migrated agent-memory/ → agent/"
- If `.mema/task-memory/` exists and `.mema/features/` does not → rename to `.mema/features/`; tell user: "Migrated task-memory/ → features/"

If new structure already exists: NOOP on that directory.

## Step 3: Create .mema/ Directory Structure

Create the following directories if they don't already exist:

```
.mema/
├── product/
├── features/
├── project/
│   └── decisions/
├── agent/
└── archive/
```

For each directory: if it exists, skip it. If it doesn't, create it.

## Step 4: Write Template Files

Write the following files to `.mema/_templates/`. If a template file already exists, **skip it**.

### `.mema/_templates/decision.md`

```
# [Decision Title]

**Status:** active | **Updated:** YYYY-MM-DD

## Context

## Decision

## Options Considered

### Option A: [Name]

### Option B: [Name]

## Reasoning

## Consequences
```

### `.mema/_templates/spec.md`

```
# [Feature Name] — Spec

**Status:** active | **Updated:** YYYY-MM-DD

## Purpose

## User Scenarios

### Scenario 1

Given [state], When [action], Then [outcome]

## Acceptance Criteria

- [ ] [Criterion]

## Constraints
```

### `.mema/_templates/status.md`

```
# [Feature Name] — Status

**Status:** pending | **Updated:** YYYY-MM-DD

## Current Status

`pending` — not started

## Progress Log

| Date | Task | Notes |
|------|------|-------|

## Next Task

## Blockers
```

### `.mema/_templates/lessons.md`

```
# Agent Lessons

**Updated:** YYYY-MM-DD

## Lessons

### [Short Title]
- **Context:**
- **Example:**

---
```

### `.mema/_templates/patterns.md`

```
# Agent Patterns

**Updated:** YYYY-MM-DD

## Patterns

### [Pattern Name]
- **Structure:**
- **Example:**

---
```

## Step 5: Scan the Project

Read and analyze the project to populate memory with real content.

### 5a: Detect Project Type and Stack

Read (skip any that don't exist):
1. `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `pom.xml`, or `Gemfile` — language, framework, dependencies
2. `README.md` — project purpose and setup
3. `CLAUDE.md` — existing conventions
4. Config files (`tsconfig.json`, `.eslintrc`, etc.)

### 5b: Scan Directory Structure

List top-level directories and key subdirectories (1-2 levels deep). Note source, test, and config locations.

### 5c: Read Representative Source Files

Pick 2-3 files that best represent the codebase: main entry point, a representative module, a test file.

### 5d: Compile Findings

Before writing memory, note:
- Project name and purpose
- Language/framework/stack with versions
- Architecture pattern
- Key directories
- Testing setup
- Build/run commands
- Notable conventions

## Step 6: Populate Initial Memory

Using scan findings, create files with **real content** (not empty placeholders).

### `.mema/project/architecture.md`

```
# Project Architecture

**Status:** active | **Updated:** [today]

## Stack
- **Language:** [detected]
- **Framework:** [detected]
[other stack items]

## Structure
- `[dir]/` — [purpose]
[other directories]

## Architecture
[Pattern in 1-2 sentences. Entry point: path/to/entry]

## Commands
- `[dev command]` — Start development
- `[test command]` — Run tests
```

### `.mema/project/requirements.md`

```
# Project Requirements

**Status:** active | **Updated:** [today]

## Purpose
[What this project does, from README and code]

## Key Requirements
- [Requirement from code/docs]

## Constraints
- [Constraint discovered]
```

### `.mema/project/structure.md`

Using the directory scan from Step 5b, write an annotated repo tree and navigation guide:

```
# Repository Structure

**Status:** active | **Updated:** [today]

## Directory Tree

```
[project-name]/
[2–3 level annotated tree derived from Step 5b scan]
```

## Entry Points

[Key files per subsystem, e.g.:]
- `[entry file]` — [what it does]

## Source vs. Generated

- **Source:** [source dirs]
- **Generated:** [build output, node_modules, etc.]
- **Gitignored:** `.mema/`, [other gitignored items]

## Where to Find X

[Quick-reference for the top subsystems found during scan:]
- **[Component type]:** `[path/]`
```

### `.mema/agent/lessons.md`

```
# Agent Lessons

**Updated:** [today]

## Lessons

[Add any project-specific gotchas found during scan, or leave as:]
<!-- Lessons will be added here as development experience accumulates. -->
```

### `.mema/agent/patterns.md`

```
# Agent Patterns

**Updated:** [today]

## Patterns

[Add any clear patterns from source files, or leave as:]
<!-- Patterns will be added here as development experience accumulates. -->
```

### `.mema/index.md`

Build the index from files just created:

```
# Memory Index

**Updated:** [today]

## Active Features

## Product Discovery

## Project Knowledge
- `project/architecture.md` — [one-line stack/architecture summary]
- `project/requirements.md` — [one-line purpose summary]
- `project/structure.md` — [one-line: e.g. "Annotated repo tree, 3 top-level dirs"]

## Agent Knowledge
- `agent/lessons.md` — [N] lessons recorded
- `agent/patterns.md` — [N] patterns recorded
```

## Step 7: Update CLAUDE.md

Read the current `CLAUDE.md` (if exists) and follow the appropriate path:

### Path A: CLAUDE.md already exists

1. Search for `## Memory System`
2. If found → **skip this step** (already configured)
3. If not found → append the Memory System section below

Memory System section:

```
## Memory System

This project uses mema-kit for persistent memory across sessions.

Memory lives in `.mema/`. At the start of each task, read `.mema/index.md` to load relevant context. After completing work, curate and save knowledge following the memory protocol in `.claude/skills/_memory-protocol.md`.

Memory is managed automatically by skills — do not manually modify `.mema/` files unless correcting an error.
```

### Path B: CLAUDE.md does NOT exist — Generate from scratch

Follow sub-steps 7a through 7f.

#### 7a: Ask user "About Me"

Ask one question using AskUserQuestion:

> "Before I generate your CLAUDE.md, how would you describe yourself?"

Options:
- **Junior developer** — "I'm learning. Explain decisions, be thorough, correct my terminology gently."
- **Senior developer** — "I'm experienced. Keep explanations brief, focus on trade-offs and edge cases."
- **Skip** — Use a sensible default

#### 7b–7f: Generate CLAUDE.md sections

Use Step 5 scan data to write:
- `# About Me` — from user's answer in 7a
- `## Project Overview` — name, description, directory tree, architecture
- `## Coding Standards` — naming conventions, style, patterns, tooling detected
- `## Technical Workflows` — dev/test/build commands from package scripts
- `## Skill Commands` — scan `.claude/skills/` for SKILL.md frontmatter descriptions
- `## Memory System` — standard section (same as Path A)

## Step 8: Update .gitignore

1. Read current `.gitignore` (if exists)
2. If `.mema` is already excluded → skip
3. If not → append:

```
# mema-kit memory (developer-local)
.mema/*
# Uncomment to share project decisions with your team:
# !.mema/project/
```

## Step 9: Confirm to User

Print a summary of what was done:

```
mema-kit initialized!

[check] .mema/ structure created (product/, features/, project/, agent/)
[check] project/structure.md generated
[check] CLAUDE.md [generated / updated / already configured]
[check] .gitignore updated

Project scan:
- [Language/framework]
- [Architecture pattern]
- [Key finding]

Next steps:
- New idea? Run /mm.seed to start the discovery workflow
- Existing feature to build? Run /mm.specify to create a feature spec
- Start a new session? Run /mm.recall to load context
```

For a re-run with migration:

```
mema-kit updated!

[check] Migrated project-memory/ → project/
[check] Migrated agent-memory/ → agent/
[check] Migrated task-memory/ → features/
[check] Directory structure verified

Your existing memory is preserved. Run /mm.recall to see current state.
```
