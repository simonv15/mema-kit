---
description: Break a high-level goal into a structured implementation plan. Explores the codebase, produces step-by-step specs, and saves them to task-memory/ for use by /mema.implement.
---

# /mema.plan — Implementation Planning

You are executing the /mema.plan skill. Follow these steps carefully.

This skill takes a user's goal (e.g., `/mema.plan add user authentication`), explores the codebase, and produces a detailed implementation plan saved to `.mema/task-memory/[task-name]/`.

## Phase 1: AUTO-LOAD

1. Read `.mema/index.md` to understand current project state
2. If `index.md` is missing or `.mema/` does not exist:
   - Tell the user: "No memory found. Run `/mema.onboard` first to set up mema-kit for this project."
   - **Stop here** — do not continue to further steps.
3. If `index.md` is empty, run the **Rebuild Procedure** from `_memory-protocol.md`
4. Load relevant memory files:
   - `project-memory/architecture.md` — to understand the current stack and structure
   - `project-memory/requirements.md` — to check how the goal fits project requirements
   - `project-memory/decisions/` — recent decisions that might affect the plan
   - `agent-memory/lessons.md` — mistakes to avoid in the plan
   - `agent-memory/patterns.md` — reusable approaches to incorporate

Read only what's needed — don't load everything.

## Phase 2: WORK

### 2a: Parse the Goal

Extract the task goal from the user's input. The goal is everything after `/mema.plan`.

- Example: `/mema.plan add user authentication` → goal is "add user authentication"
- Example: `/mema.plan refactor the database layer` → goal is "refactor the database layer"

If no goal is provided, ask the user: "What would you like to plan? Describe your goal in a sentence or two."

**Derive the task name** from the goal in kebab-case:
- "add user authentication" → `user-authentication`
- "refactor the database layer" → `database-layer-refactor`
- Keep it short (2-4 words max). Drop filler words like "add", "create", "the".

### 2b: Check for Existing Task

Check if `task-memory/[task-name]/` already exists:

- **If it exists:** Read the existing `plan.md`, `context.md`, and `status.md`. Tell the user: "Found an existing plan for [task-name]. Would you like to revise it, or start fresh?" If revising, load the existing plan as a starting point. If starting fresh, overwrite the existing files.
- **If it doesn't exist:** Continue to the next step.

### 2c: Explore the Codebase

Before writing the plan, explore the codebase to understand what exists and what needs to change. This is the intelligence step — don't skip it.

1. **Identify relevant files** — Based on the goal and loaded architecture, determine which source files, configs, and tests are relevant
2. **Read representative files** — Read 3-5 key files to understand current patterns, conventions, and structure
3. **Map dependencies** — Note what existing code the new work depends on or affects
4. **Identify constraints** — Note any technical constraints, compatibility requirements, or limitations discovered

### 2d: Clarify if Needed

If the goal is ambiguous, ask **1-2 clarifying questions** (no more). Use the AskUserQuestion tool.

Good clarifying questions:
- "Should X support Y, or is Z sufficient for now?"
- "Do you want this to follow the existing pattern in [file], or take a different approach?"

Skip this step if the goal is clear from context + exploration.

### 2e: Write the Plan

Using your exploration findings and loaded memory, produce the plan in three parts:

**General Plan** — High-level approach in 1-2 paragraphs:
- What are we building/changing?
- How does it fit with the existing architecture?
- What key architectural decisions does this plan make?

**Detailed Steps** — Step-by-step implementation specs. Each step must include:
- **Action:** What to do (create file, modify function, add test, etc.)
- **Files:** Specific file paths to create or modify
- **Details:** Enough detail that `/mema.implement` can execute the step without ambiguity
- **Dependencies:** Which prior steps must be complete first (if any)

Rules for steps:
- Each step should be small enough to implement in a single `/mema.implement` invocation
- Order steps logically (foundations first, then features, then tests, then cleanup)
- Be specific about file paths — use the actual paths discovered during exploration
- Include test steps where appropriate (not just at the end)

**Out of Scope** — Explicitly list what this plan does NOT cover. This prevents scope creep during implementation.

### 2f: Write Task Files

Create `task-memory/[task-name]/` with three files:

**`context.md`** — Exploration findings relevant to this task:
```
# [Task Name] — Exploration Context

**Status:** active | **Updated:** [today's date]

## Summary
[2-3 sentences: what was explored and the key takeaway]

## Key Findings
- [Important facts, constraints, or insights discovered during exploration]

## Open Questions
- [Anything unresolved that might affect implementation]

## Relates To
- [Links to related memory files]
```

**`plan.md`** — The full implementation plan:
```
# [Task Name] — Implementation Plan

**Status:** active | **Updated:** [today's date]

## General Plan
[High-level approach from 2e]

## Detailed Plan

### Step 1: [Action]
- **Files:** `path/to/file`
- **Details:** [Specific implementation details]
- **Dependencies:** None

### Step 2: [Action]
- **Files:** `path/to/file`
- **Details:** [Specific implementation details]
- **Dependencies:** Step 1

[... more steps ...]

## Out of Scope
- [What this plan does NOT cover]
```

**`status.md`** — Progress checklist mirroring the plan:
```
# [Task Name] — Status

**Status:** active | **Updated:** [today's date]

## Progress

- [ ] Step 1: [description]
- [ ] Step 2: [description]
- [ ] Step 3: [description]

## Notes
<!-- Any blockers, deviations from plan, or important observations. -->

## Completed
**Completed:**
```

### 2g: Present the Plan

Print a summary to the user:

```
## Plan: [Task Name]

### Approach
[1-2 sentence summary of general plan]

### Steps ([N] total)
1. [Step 1 summary]
2. [Step 2 summary]
3. [Step 3 summary]
...

### Out of Scope
- [Item 1]
- [Item 2]

---
Plan saved to task-memory/[task-name]/
To start implementing: /mema.implement [task-name]
```

## Phase 3: AUTO-SAVE & CURATE

Follow the curation rules in `_memory-protocol.md`. For each piece of knowledge produced:

- **Decisions made** about approach → ADD to `project-memory/decisions/YYYY-MM-DD-short-name.md` (only if the plan includes a significant architectural or technical decision worth preserving beyond this task)
- **Architecture insights** discovered during exploration → UPDATE `project-memory/architecture.md` (only if you found something missing or incorrect)
- **Lessons learned** during planning → ADD/UPDATE `agent-memory/lessons.md`
- **Patterns discovered** during exploration → ADD/UPDATE `agent-memory/patterns.md`

Apply ADD/UPDATE/DELETE/NOOP to each memory file. Most files will be NOOP.

**Do NOT save the plan itself as a decision.** The plan lives in task-memory. Only save standalone decisions that have value beyond this specific task.

## Phase 4: AUTO-INDEX

Update `.mema/index.md`:
1. Re-read the current index
2. Add an entry under `## Active Tasks`: `- \`task-memory/[task-name]/\` — [one-line summary] (plan ready)`
3. Update summaries for any modified files (decisions, lessons, patterns)
4. Remove entries for any deleted files
5. Update the `**Updated:**` date
