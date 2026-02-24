---
description: Generate implementation-ready plans from exploration findings. Produces a general approach + step-by-step task list with specific files and functions.
---

# /plan-docs — Implementation Plan Generation

You are generating an implementation-ready plan for a development task. You will synthesize all available context into a clear, actionable plan that /gen-test and /implement can execute from.

Read and follow the memory protocol in `_memory-protocol.md` for all memory operations.

## Phase 1: AUTO-LOAD (Load All Relevant Context)

1. **Check prerequisites:** If `.praxis/` doesn't exist, stop and tell the user: "No .praxis/ directory found. Run /kickoff first to initialize the project."

2. **Read the index:** Read `.praxis/index.md`. If it's missing or empty, run the Rebuild Procedure from `_memory-protocol.md`.

3. **Determine the task:** What is the user asking to plan? Derive a kebab-case task name (e.g., "plan the user CRUD endpoints" → `user-crud`).

4. **Check for existing context:** Look in the index for:
   - `task-memory/<task-name>/context.md` (exploration findings for this task)
   - `project-memory/architecture.md` (project-wide architecture)
   - `project-memory/decisions/` (relevant decisions)
   - Any other related memory files

5. **Load everything relevant.** For planning, be generous with loading — a plan needs the full picture. Load architecture, relevant decisions, and all task context.

6. **Handle missing context:**
   - If rich exploration context exists → proceed to planning
   - If no exploration context exists for this task, assess complexity:
     - **Complex task** (many unknowns, architecture decisions needed): Suggest running `/explore` first: "This task has several open questions. I'd recommend running `/explore [topic]` first to research them. Want to do that?"
     - **Medium task** (some unknowns but researchable quickly): Offer to do quick inline research: "I don't have prior exploration for this task. I can do a quick research pass and then generate the plan. Or you can describe your requirements directly."
     - **Simple task** (user has clear requirements): Ask for requirements: "Tell me what you want to build and I'll create the plan."

7. **Check for existing plan:** If `task-memory/<task-name>/plan.md` already exists, ask the user: "I found an existing plan for [task]. Do you want to update it, or start fresh?"

## Phase 2: WORK (Generate the Plan)

Create a two-part plan using the template from `.praxis/_templates/plan.md`.

### Part 1: General Plan

Write a high-level overview that answers:
- **What** are we building? (Feature description in 2-3 sentences)
- **How** does it fit into the existing architecture? (Reference architecture.md)
- **What** key technical decisions apply? (Reference relevant decisions)
- **What** is the data flow? (Input → Processing → Output)

Keep it to 1-2 paragraphs or a short bullet list. This section is for understanding, not for implementing.

### Part 2: Detailed Plan

Write step-by-step implementation tasks. For each step:

1. **Action** — What to do (imperative verb: "Create", "Add", "Configure", "Update")
2. **Files** — Exact file paths to create or modify
3. **Details** — Specific enough to implement without ambiguity:
   - For new files: what the file should contain (data structures, function signatures, key logic)
   - For modifications: what to add or change in the existing file
   - For configuration: what settings to add and why
4. **Dependencies** — If this step requires a previous step to complete, note it (e.g., "Requires Step 1")

**Guidelines for step quality:**
- Each step should be completable in one focused coding session (not too big, not trivially small)
- Steps should be ordered so that tests can run after each step (not just at the end)
- A typical plan has 4-8 steps. Fewer means steps are too large. More than 10 means they're too granular.
- Include test-related steps where appropriate (e.g., "Add test fixtures" or "Update test configuration")

### Part 3: Out of Scope

List what this plan explicitly does NOT cover. Include:
- Related features that should be separate tasks
- Non-functional requirements deferred to later (performance, security hardening)
- Edge cases that can be handled in a follow-up task

## Phase 3: AUTO-SAVE (Save the Plan)

1. **Create the task directory** if it doesn't exist: `.praxis/task-memory/<task-name>/`

2. **Write the plan:** Save to `.praxis/task-memory/<task-name>/plan.md`
   - If overwriting an existing plan, replace the entire file
   - Use today's date for the `**Updated:**` metadata

3. **Create status file:** If `.praxis/task-memory/<task-name>/status.md` doesn't exist, create it using the template from `.praxis/_templates/status.md`. Populate the progress checklist from the detailed plan's steps.

4. **Apply curation** (from memory protocol):
   - **ADD** the plan and status files
   - **UPDATE** any related context files if planning revealed new information
   - **DELETE** draft notes or outdated context that the plan supersedes
   - **NOOP** for unrelated memories

## Phase 4: AUTO-INDEX (Update the Index)

Update `.praxis/index.md`:

1. Add or update the task entry under "Active Tasks": `- \`task-memory/<task-name>/\` — [one-line description] (plan ready)`
2. Update summaries for any modified files
3. Update the `**Updated:**` date

## Closing

Show the user a summary of the plan:

```
Plan created for [task name]:

General approach: [1-sentence summary]
Steps: [number] implementation steps
Estimated files: [number] files to create/modify

Saved to: .praxis/task-memory/<task-name>/plan.md

Next steps:
- Run /gen-test to generate test cases from this plan
- Run /implement to start building
- Or review the plan and ask me to adjust anything
```

If the user has feedback on the plan, update it immediately and re-save.
