---
description: Create a technical implementation plan for a feature. Reads the feature spec, explores the codebase, and writes a detailed plan to features/NNN-name/plan.md for use by /mm.tasks and /mm.implement.
---

# /mm.plan — Feature Technical Design

You are executing the /mm.plan skill. Follow these steps carefully.

This skill takes a feature spec (created by `/mm.specify`) and produces a technical implementation plan — what to build, how it fits the existing architecture, and which files to change.

## Phase 1: AUTO-LOAD

1. Read `.mema/index.md` to understand current project state
2. If `index.md` is missing or `.mema/` does not exist:
   - Tell the user: "No memory found. Run `/mm.onboard` first to set up mema-kit."
   - **Stop here.**
3. If `index.md` is empty, run the **Rebuild Procedure** from `_memory-protocol.md`
4. Load relevant memory:
   - `project/architecture.md` — current stack and patterns
   - `project/requirements.md` — constraints to respect
   - `project/decisions/` — past decisions that affect this plan
   - `agent/lessons.md` — mistakes to avoid
   - `agent/patterns.md` — reusable approaches to apply

## Phase 2: WORK

### 2a: Select Feature

Parse the user's input:
- **Feature name or number given:** `/mm.plan user-auth` or `/mm.plan 001` → find matching `features/NNN-name/`
- **No input:** list features that have a `spec.md` but no `plan.md`; ask which to plan

If the feature directory doesn't exist:
- Tell the user: "No feature found for '[input]'. Run `/mm.specify` first to create a feature spec."
- **Stop here.**

If `plan.md` already exists:
- Tell the user: "A plan already exists for [feature-name]. Would you like to revise it or start fresh?"
- If revising: load the existing plan as a starting point.

### 2b: Load the Feature Spec

Read `features/NNN-name/spec.md` in full.

If `spec.md` is missing:
- Tell the user: "No spec found for [feature-name]. Run `/mm.specify` first."
- **Stop here.**

### 2c: Explore the Codebase

Before writing the plan, explore what already exists. Read 3–5 files relevant to this feature:
- Entry points or route files the feature will touch
- Existing patterns for similar features (e.g., if adding auth, read an existing auth-adjacent file)
- Test files for the area being changed
- Config files if the feature requires configuration changes

Note: current patterns, naming conventions, architectural constraints, and anything the spec didn't mention that affects implementation.

### 2d: Clarify if Needed

If the spec leaves meaningful technical ambiguity, ask **one clarifying question** using AskUserQuestion. Skip this step if the spec is clear.

Good clarifying questions:
- "The spec mentions [X]. Should this follow the existing pattern in [file], or take a new approach?"
- "Should this feature include tests, or is that deferred?"

### 2e: Write the Plan

Produce a technical plan in these parts:

**Approach** — 1–2 paragraphs:
- What architectural approach will be used?
- How does it fit the existing codebase patterns?
- What key technical decisions does this plan make?

**Key Entities / Data** (if relevant):
- Data structures, models, or types involved
- Database schema changes if applicable

**File Changes** — the complete set of files to create or modify:
- List each file with a one-line description of what changes
- Include test files

**Implementation Notes** — gotchas, constraints, dependencies:
- Lessons from lessons.md that apply
- Patterns from patterns.md to follow
- Non-obvious dependencies or ordering requirements

### 2f: Write Plan File

Write `features/NNN-name/plan.md`:

```
# [Feature Name] — Plan

**Status:** active | **Updated:** [today's date]

## Approach

[High-level technical approach from 2e]

## Key Entities

[Data structures / models if applicable]

## File Changes

- `path/to/file` — [what changes]
- `path/to/file` — [what changes]

## Implementation Notes

[Gotchas, patterns to follow, ordering requirements]
```

### 2g: Present to User

```
## Plan: [Feature Name]

### Approach
[1-2 sentence summary]

### Files to change ([N] total)
- [file] — [what]
- [file] — [what]

---
Plan saved to features/[NNN-name]/plan.md
Next: /mm.tasks [NNN-name]
```

## Phase 3: AUTO-SAVE & CURATE

Follow the curation rules in `_memory-protocol.md`:

- **Significant architectural decisions** made during planning → ADD to `project/decisions/YYYY-MM-DD-short-name.md`
- **Architecture discoveries** (found something missing or wrong in architecture.md) → UPDATE `project/architecture.md`
- **Lessons** from planning → ADD/UPDATE `agent/lessons.md`
- **Patterns** identified → ADD/UPDATE `agent/patterns.md`

Most files will be NOOP.

## Phase 4: AUTO-INDEX

Update `.mema/index.md`:
1. Re-read the current index
2. If the feature's entry in `## Active Features` doesn't mention a plan, update its summary: add "(plan ready)"
3. Add entries for any new decision files
4. Update `**Updated:**` date
