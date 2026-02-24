# 06 — Plan-Docs Skill

**Produces:** `skills/plan-docs/SKILL.md`
**Milestone:** 3
**Dependencies:** 01-memory-protocol, 02-templates, 05-explore-skill (typically runs after exploration, but works without it)

---

## What This Skill Does

`/plan-docs` transforms exploration findings into an implementation-ready plan. It reads everything the agent knows about a task (from prior `/explore` sessions), synthesizes it, and produces a two-part plan:

1. **General plan** — High-level approach, architecture, key decisions (the "what and why")
2. **Detailed plan** — Step-by-step tasks with specific files, functions, and dependencies (the "how")

The plan is saved to `.praxis/task-memory/<task>/plan.md` and becomes the primary input for `/gen-test` and `/implement`.

Example usage:
```
/plan-docs plan the task CRUD endpoints
/plan-docs design the user authentication flow
/plan-docs plan the database migration strategy
```

---

## Key Design Decisions

### 1. Two-part plan structure: General + Detailed

**Decision: Split every plan into a high-level overview and a step-by-step implementation guide.**

Reasoning:
- Different downstream consumers need different levels of detail. `/gen-test` needs the general plan to understand what to test (architecture, data flow, edge cases) but doesn't need to know which files to create. `/implement` needs the detailed plan with exact files and implementation order.
- Humans reviewing the plan also benefit from the split. A developer can skim the general plan in 30 seconds to check the approach, then drill into the detailed plan only if the approach is sound.
- Combining both into one flat document would force the reader to wade through implementation steps to understand the architecture, or wade through architecture descriptions to find the next task.
- The two parts live in a single file (`plan.md`) with clear headings. This is simpler than two separate files and ensures they stay in sync.

### 2. Detailed plan: numbered steps with file paths

**Decision: Each step in the detailed plan specifies the action, the file(s) it touches, and implementation details.**

Reasoning:
- An "implementation-ready" plan means the agent (or developer) can start coding from it without ambiguity. "Create the database schema" is not implementation-ready. "Create `src/db/schema.ts` with a `tasks` table: id (UUID, PK), title (VARCHAR 255), status (ENUM: todo/in-progress/done), created_at (TIMESTAMP)" IS implementation-ready.
- File paths eliminate the "where does this code go?" question. The agent doesn't have to make structural decisions during implementation — those are already made during planning.
- Numbered steps establish order. Some steps depend on previous ones (you can't write route handlers before defining the schema). The numbers make dependencies implicit (each step can assume all prior steps are done).
- This format also maps directly to `/implement`'s todo list. Each step becomes a checkbox task.

### 3. How the plan relates to exploration context

**Decision: The plan synthesizes exploration findings — it doesn't duplicate them.**

Reasoning:
- The exploration phase may have produced multiple context files and decision files. The plan should reference these findings (build on them) but not copy them.
- For example, if `/explore` decided on PostgreSQL and saved a decision file, the plan should say "Using PostgreSQL (see decision: 2026-02-23-tech-stack)" and move on. It shouldn't re-explain why PostgreSQL was chosen.
- This keeps the plan focused on implementation rather than re-justifying decisions.
- The "Relates To" or header references in `plan.md` connect back to exploration artifacts for anyone who wants the full reasoning.

### 4. Out of Scope section

**Decision: Every plan includes an explicit "Out of Scope" section.**

Reasoning:
- Scope creep is the number one risk during implementation. The agent, while implementing step 3, might think "I should also add input validation for the other endpoints" — even though that's a different task.
- An explicit "Out of Scope" section prevents this. When the agent is tempted to do extra work, it checks the out-of-scope list first.
- This section is also valuable for humans reviewing the plan. It sets expectations about what this task does NOT include.
- Common out-of-scope items: error handling beyond the happy path, performance optimization, UI changes for backend tasks, tests for unrelated components.

### 5. Handling missing exploration context

**Decision: If no prior exploration exists for the task, offer three options.**

When `/plan-docs` runs without prior `/explore` data:

| Option | When to suggest | What happens |
|--------|----------------|-------------|
| **Explore first** | Complex tasks with many unknowns | "This task would benefit from exploration first. Want to run /explore?" |
| **Quick inline exploration** | Medium tasks where the agent can research quickly | The agent does a brief exploration within the planning session, saves context, then generates the plan |
| **Plan from user input** | Simple tasks or when the user has clear requirements | "Tell me what you want to build and I'll create a plan from your description" |

Reasoning:
- Forcing "/explore first" for every plan would be annoying for simple tasks. Sometimes the user knows exactly what they want.
- But skipping exploration for complex tasks leads to shallow plans based on assumptions.
- The three options let the agent calibrate based on task complexity, and the user can override.

### 6. Plan replaces, not accumulates

**Decision: Each task has exactly one `plan.md`. Re-running `/plan-docs` for the same task overwrites the existing plan.**

Reasoning:
- Draft plans are noise. If the user runs `/plan-docs`, reviews the plan, and asks for changes, the updated plan should replace the original.
- Keeping multiple plan versions would confuse `/implement` — which version should it follow?
- This aligns with the "replace curation" rule from the memory protocol.
- The agent should tell the user "This will replace the existing plan for [task]. Proceed?" when an existing plan is found.

---

## Implementation Guide

### Step 1: Create the SKILL.md file structure

```
skills/
└── plan-docs/
    └── SKILL.md
```

### Step 2: Write the SKILL.md

The skill follows the memory lifecycle:
1. **AUTO-LOAD** — read index, load all relevant context for the task
2. **WORK** — synthesize findings into a two-part plan
3. **AUTO-SAVE** — write plan.md to task-memory, create status.md
4. **AUTO-INDEX** — update index.md

### Step 3: Test plan quality

Run `/explore` on a topic, then `/plan-docs`. Evaluate:
- Does the general plan reflect the exploration findings?
- Are the detailed steps specific enough to implement directly?
- Does each step specify file paths?
- Is the out-of-scope section useful (not just filler)?

### Step 4: Test without prior exploration

Run `/plan-docs` directly without `/explore`. Verify:
- The agent offers the three options
- If the user provides requirements directly, the plan is still good
- If the agent does inline exploration, it saves context before planning

---

## Full SKILL.md Content

```markdown
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
```

---

## Design Notes

### Why planning is generous with context loading

Unlike `/explore` (which loads selectively), `/plan-docs` loads almost everything relevant. Planning requires the full picture:
- Architecture constraints determine what's possible
- Prior decisions determine what's already decided
- Task context determines what's been explored
- Other active tasks determine what might conflict

The token cost of loading more files during planning is offset by producing a better plan that requires fewer corrections during implementation.

### Why the plan includes file paths

This is a deliberate "shift left" of architectural decisions. Without file paths, the agent makes structural decisions during `/implement` — under time pressure, mid-coding. With file paths in the plan, structural decisions are made during `/plan-docs` — when the agent has full context and can think holistically.

This also makes the plan reviewable. A developer can look at the file paths and say "actually, let's put the middleware in `src/lib/middleware/` not `src/middleware/`" before any code is written.

### The status.md file

`/plan-docs` creates `status.md` alongside `plan.md`. This file has the same steps as the plan but as a checklist. `/implement` uses this checklist to track progress:
- Check off steps as they complete
- Note blockers or deviations
- Record completion date when all steps are done

Creating the status file during planning (not during implementation) means the task's tracking structure is ready before coding starts.

### Why 4-8 steps is the target range

- **Under 4 steps:** Each step is doing too much. The agent will struggle to complete a step in one focused pass, leading to partial implementations and lost progress.
- **4-8 steps:** Each step is a coherent unit of work. The agent can complete a step, run tests, commit, and move on. If the session ends mid-task, it's clear where to resume.
- **Over 10 steps:** Steps are too granular. "Create file X" and "Add imports to file X" should be one step, not two. Over-granular plans create checkbox noise and make it hard to see the big picture.

The agent should combine or split steps to hit this range. If a plan naturally has 12 steps, look for steps that can be merged. If it has 3, look for steps that should be broken down.
