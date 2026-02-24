---
description: Implement code following an existing plan. Creates a todo list, executes steps in order, runs tests, saves lessons learned, and archives completed tasks.
---

# /implement — Code Implementation

You are implementing a development task. You will follow the plan step by step, run tests after each step, and save lessons learned when done.

Read and follow the memory protocol in `_memory-protocol.md` for all memory operations.

## Phase 1: LOAD (Gather All Context)

1. **Check prerequisites:** If `.praxis/` doesn't exist, stop and tell the user: "No .praxis/ directory found. Run /kickoff first to initialize the project."

2. **Read the index:** Read `.praxis/index.md`.

3. **Find the plan:** Based on the user's request, identify the task and read `.praxis/task-memory/<task-name>/plan.md`.
   - If no plan exists, assess the task:
     - **Small task** (single file, clear scope): "No plan found, but this is straightforward. I'll implement directly from your description."
     - **Medium/large task**: "No plan found for [task]. This task involves multiple steps. I'd recommend running /plan-docs first for a structured approach. Want me to create a plan, or proceed with your instructions?"

4. **Load supporting context:**
   - `project-memory/architecture.md` — understand the project structure
   - Relevant `project-memory/decisions/` — understand key technical decisions
   - `task-memory/<task-name>/context.md` — exploration context if it exists
   - `agent-memory/lessons.md` — lessons to apply during implementation
   - `agent-memory/patterns.md` — patterns to follow

5. **Brief the user:** "I've loaded the plan for [task] along with [N] lessons and [N] patterns from prior work. Ready to implement [N] steps."

## Phase 2: SETUP (Create Todo List)

1. Read the plan's detailed steps.
2. Create a todo item for each step using Claude Code's task system (TaskCreate tool).
   - Subject: the step's action (e.g., "Create database schema")
   - Description: the step's details from the plan (files, specifics)
3. Set up dependencies: each step is blocked by the previous step.
4. Read `.praxis/task-memory/<task-name>/status.md` if it exists — check if some steps were already completed (from a previous interrupted session). Skip completed steps.

Report to the user:
```
Implementation plan for [task]:
1. [ ] [Step 1 action]
2. [ ] [Step 2 action]
...
Starting with Step 1.
```

## Phase 3: EXECUTE (Implement Step by Step)

For each step in the plan:

### 3a. Start the step
- Mark the task as in_progress
- Tell the user which step you're working on
- Review the step's details from the plan (files to create/modify, specific requirements)

### 3b. Implement
- Write the code as specified in the plan
- Apply loaded patterns where relevant (e.g., use the known route pattern)
- Apply loaded lessons proactively (e.g., add type casting if the lesson says it's needed)
- Follow the project's existing code conventions (import style, naming, formatting)

### 3c. Test
- Run the project's test suite (or the relevant subset)
- Evaluate results:
  - **All relevant tests pass** → mark step complete, move to next step
  - **Regression** (a previously passing test now fails) → stop, investigate, fix before continuing
  - **Expected failure** (a test for a future step fails) → acceptable, continue
  - **New test failure caused by this step's code** → fix before moving on

### 3d. Checkpoint
- Mark the task as completed
- Update `.praxis/task-memory/<task-name>/status.md`: check off the completed step
- If this is a logical checkpoint (major feature complete, all tests green), suggest committing: "Step [N] complete, tests passing. Good point to commit?"

### Handling issues during implementation:

- **Plan needs adjustment:** If implementation reveals that a plan step won't work as written, update the plan file with the corrected approach, then continue. Tell the user what changed and why.
- **Unexpected complexity:** If a step is much more complex than expected, tell the user and offer to break it into sub-steps.
- **External blocker:** If implementation is blocked by something outside the task (missing dependency, unclear requirement), pause and ask the user.

## Phase 4: REFLECT (Save Lessons and Patterns)

After all steps are complete and tests pass, reflect on what was learned.

Ask yourself:
1. **What surprised me during implementation?** (unexpected behavior, undocumented quirks)
2. **What took longer than expected?** (debugging that could have been avoided with foreknowledge)
3. **What pattern did I discover or apply successfully?** (reusable approach for future tasks)

### Save lessons:
Read `.praxis/agent-memory/lessons.md`. For each new insight:
- If a similar lesson already exists → **UPDATE** it with the new example
- If it's a new lesson → **ADD** it using the format:
  ```
  ### [Short Title]
  - **Context:** [When/how this was discovered]
  - **Example:** [Concrete code example or scenario]
  ```
- Update the `**Updated:**` date

### Save patterns:
Read `.praxis/agent-memory/patterns.md`. For each new pattern:
- If a similar pattern already exists → **UPDATE** with refinements
- If it's genuinely new → **ADD** it using the format:
  ```
  ### [Pattern Name]
  - **Structure:** [How the pattern is organized]
  - **Example:** [Concrete usage example]
  ```
- Update the `**Updated:**` date

**Guideline:** Be selective. Not every implementation teaches a lesson. Save only insights that would genuinely help a future agent working on a different task. "Used the database" is not a lesson. "PostgreSQL jsonb columns require explicit `::jsonb` cast in Drizzle raw queries" is a lesson.

Briefly tell the user what was saved: "Saved 2 lessons (Drizzle jsonb casting, Fastify preHandler order) and 1 pattern (service → repository data flow)."

## Phase 5: ARCHIVE (Complete and Archive the Task)

1. **Update status:** Set `.praxis/task-memory/<task-name>/status.md`:
   - All checkboxes checked
   - `**Status:** complete`
   - `**Completed:** [today's date]`

2. **Archive the task:** Move all files from `.praxis/task-memory/<task-name>/` to `.praxis/archive/<task-name>/`.

3. **Update the index:**
   - Remove the task from "Active Tasks"
   - Keep the decision entries in "Recent Decisions" (decisions are project-level, not task-level)
   - Update lesson/pattern summaries under "Agent Lessons"
   - Update the `**Updated:**` date

4. **Report to the user:**

```
Implementation complete! [task name]

✓ [N] steps completed
✓ All tests passing
✓ [N] lessons saved to agent-memory/
✓ Task archived to .praxis/archive/[task-name]/

[Optional: suggest next steps if relevant]
```
