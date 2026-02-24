# 03 — Kickoff Skill

**Produces:** `skills/kickoff/SKILL.md`
**Milestone:** 1
**Dependencies:** 01-memory-protocol (protocol file must exist), 02-templates (template files must exist)

---

## What This Skill Does

`/kickoff` is the universal project initialization command. Regardless of how the user installed Praxis-kit (npm, Vercel Skills, manual copy), they always run `/kickoff` as their first step. It:

1. Creates the `.praxis/` directory structure with all subdirectories
2. Copies memory file templates into `.praxis/_templates/`
3. Initializes empty starter files (`index.md`, `architecture.md`, `requirements.md`, `lessons.md`, `patterns.md`)
4. Appends spec-driven workflow conventions to `CLAUDE.md`
5. Adds `.praxis/` to `.gitignore`

The skill is **idempotent** — running it twice doesn't break anything. On re-run, it verifies and repairs the structure rather than overwriting existing data.

---

## Key Design Decisions

### 1. Idempotency: verify and repair, never overwrite

**Decision: On re-run, check what exists and only create what's missing.**

Reasoning:
- Users will inevitably run `/kickoff` twice. Maybe they forgot they already ran it. Maybe they want to "make sure everything is set up." Maybe a teammate told them to run it.
- If `/kickoff` overwrites existing files, it would destroy curated memories from previous sessions. That's catastrophic — the whole point of the memory system is persistence.
- The idempotent approach is simple: for each file/directory, check if it exists. If yes, skip. If no, create. For CLAUDE.md, check if the workflow section already exists before appending.
- This also means `/kickoff` can serve as a "repair" command. If someone accidentally deletes `.praxis/agent-memory/`, running `/kickoff` recreates the directory without touching anything else.

### 2. CLAUDE.md: append a workflow section, don't overwrite the file

**Decision: Append a clearly-delimited section to CLAUDE.md, checking for duplicates first.**

Reasoning:
- The user likely already has a CLAUDE.md with project-specific instructions. Overwriting it would destroy their work.
- Appending is safe, but we need to prevent duplicates on re-run. The solution: look for a unique marker string (e.g., `## Praxis-kit Workflow`) before appending. If it exists, skip.
- The appended section should be short (~20 lines). CLAUDE.md is loaded into every conversation, so every line costs tokens. We want just enough to establish the workflow convention, not a full tutorial.
- If CLAUDE.md doesn't exist at all, the skill creates a minimal one with just the Praxis-kit section. We don't generate a full project CLAUDE.md — that's the user's responsibility.

### 3. What goes in the CLAUDE.md workflow section

**Decision: A brief description of the Explore → Plan → Code workflow, a note about `.praxis/` memory, and a reference to the skill commands.**

The section should contain:
- A 1-2 line statement that this project uses spec-driven development
- The workflow: `/explore` → `/plan-docs` → `/gen-test` → `/implement`
- A note that `.praxis/` contains project memory (so the agent doesn't delete or ignore it)
- A note to load `index.md` at the start of each session for context

What it should NOT contain:
- The full memory protocol (that's in `_memory-protocol.md`)
- Usage instructions for each command (that's in each SKILL.md)
- The user's profile (that's `/profile`'s job)

### 4. .gitignore handling

**Decision: Append `.praxis/` to .gitignore with a commented exception for `project-memory/`.**

Reasoning:
- `.praxis/` should be gitignored by default. Agent memories are developer-local — committing them would confuse teammates.
- But `project-memory/` (architecture decisions, requirements) is valuable to share. The commented-out exception (`# !.praxis/project-memory/`) lets users opt in by uncommenting one line.
- We check for existing `.praxis` entries in `.gitignore` before appending to avoid duplicates.
- If `.gitignore` doesn't exist, we create it with just the Praxis-kit entries.

### 5. Template copying strategy

**Decision: The SKILL.md contains the template content inline rather than reading from a `templates/` directory.**

Reasoning:
- When the user installs via `npx praxis-kit`, the CLI copies skills to `.claude/skills/`. But it doesn't copy `templates/` to the user's project — templates are only in the npm package.
- This means `/kickoff` can't rely on reading from a `templates/` directory at runtime. The templates need to be accessible from the SKILL.md itself.
- Solution: The SKILL.md contains the template content directly in its instructions. When the agent runs `/kickoff`, it reads the SKILL.md (which Claude Code loads automatically), finds the template content, and writes it to `.praxis/_templates/`.
- This is a trade-off: it makes the SKILL.md longer (~150 lines) but eliminates a runtime dependency. The alternative (the CLI also copies templates to a known location) adds complexity and a potential failure point.

### 6. Starter files: nearly empty, not template-filled

**Decision: `architecture.md`, `requirements.md`, `lessons.md`, and `patterns.md` are created with just a title and metadata line, not filled from templates.**

Reasoning:
- These files are filled by future skills (`/explore` fills architecture and requirements, `/implement` fills lessons and patterns). Pre-filling them with template sections would be misleading — the agent would see empty sections and might feel compelled to fill them prematurely.
- A title + metadata line signals "this file exists but has no content yet." The agent knows to write to it when it has something to write.
- `index.md` is the exception — it gets the full initial structure (section headers + format comments) because it needs to teach the agent the index format the first time `/explore` runs.

---

## Implementation Guide

### Step 1: Create the SKILL.md file structure

```
skills/
└── kickoff/
    └── SKILL.md
```

### Step 2: Write the SKILL.md

The SKILL.md has three parts:
1. **YAML frontmatter** — the `description` field shown in `/skills` list
2. **Prerequisite checks** — what to verify before doing work
3. **Execution steps** — the ordered instructions

### Step 3: Test idempotency

Run `/kickoff` on a fresh project. Then run it again. Verify:
- No files are overwritten
- No duplicate sections in CLAUDE.md
- No duplicate entries in .gitignore
- Missing files/directories are recreated

### Step 4: Test on projects with existing CLAUDE.md

Run `/kickoff` on a project that already has a CLAUDE.md with custom content. Verify:
- Custom content is preserved
- Workflow section is appended at the end
- No corruption

---

## Full SKILL.md Content

```markdown
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
```

---

## Design Notes

### Why the SKILL.md is long (~200 lines)

Most SKILL.md files are shorter, but `/kickoff` is special:
- It contains all 6 template files inline (because it can't read from `templates/` at runtime)
- It has detailed idempotency logic (check-then-create for every file)
- It modifies 3 different files (CLAUDE.md, .gitignore, plus all .praxis/ files)

This is acceptable because `/kickoff` runs once (or very rarely). The long instructions don't consume ongoing tokens — only the one-time setup session pays the cost.

### Why not create task-memory subdirectories during kickoff?

`task-memory/` is created as an empty directory. Task-specific subdirectories (like `task-memory/api-setup/`) are created by `/explore` or `/plan-docs` when the user starts working on a task. Pre-creating them would require knowing task names in advance, which we don't.

### Why templates live in `.praxis/_templates/` and not `.claude/skills/`

Templates are reference documents for the agent, not skill definitions. Placing them alongside SKILL.md files could confuse the skill loading system. The `_templates/` directory in `.praxis/` keeps data (templates) with data (memory files) and instructions (skills) with instructions (SKILL.md files).

The underscore prefix (`_templates/`) signals "this is a system directory, not user-created memory."
