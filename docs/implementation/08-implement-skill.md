# 08 — Implement Skill

**Produces:** `skills/implement/SKILL.md`
**Milestone:** 4
**Dependencies:** 06-plan-docs-skill (reads plan.md), 07-gen-test-skill (expects tests to exist, but works without them)

---

## What This Skill Does

`/implement` is the culmination of the workflow. It reads the plan, creates a todo list from the plan steps, executes each step in order, runs tests after each step, and — when done — saves lessons learned, records patterns discovered, and archives the completed task.

This is the most complex skill because it:
- Reads from multiple memory files (plan, context, architecture, lessons, patterns)
- Writes code to the codebase
- Manages a todo list for multi-step execution
- Runs tests between steps
- Writes to multiple memory files (lessons, patterns, status)
- Archives completed tasks

Example usage:
```
/implement implement the task CRUD endpoints
/implement build the auth middleware
/implement implement the database migration
```

---

## Key Design Decisions

### 1. Todo list: use Claude Code's native task system

**Decision: Create a todo list using Claude Code's built-in TaskCreate/TaskUpdate tools.**

Reasoning:
- Claude Code has a native task system (TaskCreate, TaskUpdate, TaskList) that shows progress to the user in real-time. Using it gives the user visibility into which step is being worked on, which are done, and which remain.
- Building a custom todo system (e.g., writing checkmarks to a file) would duplicate existing functionality and provide a worse UX (no real-time updates).
- The todo items map 1:1 from the plan's detailed steps. Each "### Step N: [Action]" becomes a task.
- Task dependencies can be set (step 2 blocked by step 1) to enforce execution order.

### 2. Execute steps sequentially, test after each

**Decision: Complete one step at a time, run tests after each step, only proceed if tests pass (or the user overrides).**

Reasoning:
- Sequential execution prevents the agent from "getting ahead of itself" — implementing step 5 before step 3 is complete would likely produce broken code.
- Testing after each step catches issues early. If step 3 breaks step 2's tests, it's better to know immediately than to discover it after implementing all 8 steps.
- The "or the user overrides" part is important: sometimes a test failure is expected (e.g., a test for step 5's feature fails because step 5 hasn't been implemented yet). The agent should distinguish between:
  - **Regressions** (step 2's tests that previously passed now fail) → stop and fix
  - **Expected failures** (step 5's tests fail because step 5 isn't done yet) → continue
- Passing tests provide a "green checkpoint" that the agent can return to if something goes wrong. This is the same principle as frequent git commits.

### 3. Load lessons and patterns defensively

**Decision: At the start of implementation, load `agent-memory/lessons.md` and `agent-memory/patterns.md`.**

Reasoning:
- Lessons are "things that went wrong before." Loading them prevents the agent from making the same mistakes twice. Example: "Drizzle needs explicit type casting for enums" — if the agent knows this before implementing a model with enums, it writes the correct code the first time.
- Patterns are "approaches that worked well." Loading them guides the agent toward proven solutions. Example: "Fastify route pattern: define schema, write handler, register in app.ts" — the agent follows this pattern instead of inventing a new structure.
- These files are usually small (a few dozen lines). The token cost of loading them is trivial compared to the benefit of avoiding re-learned mistakes.
- Loading them at the START (not when issues arise) is key. By the time the agent encounters a problem, it may have already written code the wrong way. Proactive loading prevents the problem.

### 4. How to save lessons

**Decision: At the end of implementation, reflect on what was learned and save lessons using the ADD/UPDATE curation framework.**

The agent should ask itself three questions:
1. **What surprised me?** (unexpected behavior, framework quirks, confusing APIs)
2. **What took longer than expected?** (debugging that could have been avoided with prior knowledge)
3. **What pattern did I discover?** (a reusable approach that worked well)

Reasoning:
- Lessons that aren't explicitly captured are lost. The next session starts fresh and makes the same mistakes.
- Automatic saving (not asking the user) keeps the flow smooth. The agent briefly mentions what it saved: "Saved lesson: Vitest mocks must be declared before imports."
- Lessons should be concrete and actionable, not vague. "Database was tricky" is useless. "PostgreSQL jsonb columns require explicit casting with Drizzle's `sql` template tag" is actionable.
- The ADD/UPDATE distinction matters: if a similar lesson already exists, UPDATE it with the new example rather than creating a duplicate.

### 5. Task archiving on completion

**Decision: When all plan steps are done and tests pass, move the task's memory to `archive/`.**

Reasoning:
- Completed tasks are not relevant to future work (in most cases). Keeping them in `task-memory/` would clutter the index and waste tokens when the agent loads context.
- Archiving (not deleting) preserves the record. If a user wants to reference how a past task was done, the archive is available.
- The archive structure mirrors the task structure: `archive/<task-name>/` contains the same files that were in `task-memory/<task-name>/`.
- The index is updated: the task is removed from "Active Tasks" and the agent knows it's done.

### 6. Handling implementation without a plan

**Decision: If no plan exists, offer to create one or proceed with user-provided instructions.**

Reasoning:
- Not every implementation needs a formal plan. "Add a console.log to the auth middleware" doesn't need `/plan-docs`.
- For small tasks, the agent can take direct instructions and implement without a plan. No memory overhead, no ceremony.
- For medium/large tasks without a plan, the agent should strongly suggest planning first: "This task involves multiple files and components. I'd recommend running /plan-docs first for a structured approach. Want to do that?"
- This matches the "skills guide, not gate" design philosophy.

### 7. Git commits during implementation

**Decision: The agent does NOT automatically commit after each step. It suggests committing at logical checkpoints.**

Reasoning:
- Auto-committing would be too opinionated. Some developers commit after every step. Others prefer one commit per feature. Some use squash merges and don't care about intermediate commits.
- The `/profile` preferences may indicate the user's style ("I prefer small commits" vs. "one commit per task").
- The agent suggests committing at logical points: "Step 3 is complete and tests pass. This would be a good point to commit. Want me to do that?" The user decides.
- This respects the user's workflow while providing helpful nudges.

---

## Implementation Guide

### Step 1: Create the SKILL.md file structure

```
skills/
└── implement/
    └── SKILL.md
```

### Step 2: Write the SKILL.md

The skill has five phases:
1. **LOAD** — read plan, lessons, patterns, architecture
2. **SETUP** — create todo list from plan steps
3. **EXECUTE** — implement each step, test after each
4. **REFLECT** — save lessons and patterns
5. **ARCHIVE** — move completed task to archive, update index

### Step 3: Test the full cycle

Run the complete flow: `/explore` → `/plan-docs` → `/gen-test` → `/implement`. Verify:
- Todo list is created from plan steps
- Each step is implemented in order
- Tests run after each step
- Lessons are saved to agent-memory/
- Task is archived after completion
- Index is updated correctly

### Step 4: Test error recovery

Deliberately introduce a test failure mid-implementation. Verify:
- The agent stops and attempts to fix the issue
- It doesn't skip to the next step
- After fixing, it re-runs tests and continues

---

## Full SKILL.md Content

```markdown
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
```

---

## Design Notes

### Why the execute phase is so detailed

`/implement` is where the agent spends the most time and does the most complex work. Clear, step-by-step instructions prevent the agent from:
- Skipping ahead (implementing step 5 before step 3)
- Ignoring test failures (continuing when tests are red)
- Forgetting to save progress (status.md not updated)
- Over-committing (creating unwanted git commits)

Every substep (3a, 3b, 3c, 3d) maps to a concrete action. This level of detail is unusual for a SKILL.md but necessary for the most complex skill.

### Why archiving moves files instead of deleting them

Deletion is irreversible. If the user wants to reference how a past task was implemented (e.g., "how did we set up auth?"), the archive provides that history. The archive is also useful if a task needs to be reopened ("the auth implementation has a bug, let me see the original plan").

The token cost is zero: archived files aren't indexed or loaded unless someone explicitly reads them. They're just files on disk.

### Why lesson reflection is at the end, not during implementation

During implementation, the agent is focused on writing code and passing tests. Interrupting to ask "did you learn anything?" would be jarring and would likely produce low-quality reflections ("uh, not really, I'm in the middle of something").

Post-implementation reflection, when the full experience is fresh and the context is complete, produces better insights. The agent can look at the whole journey: "Step 3 took three attempts because of a framework quirk — that's worth saving."

### Session interruption handling

If the user's session ends mid-implementation (context limit, connection drop, user closes the terminal), the progress is preserved:
- `status.md` has checkboxes showing which steps are done
- Completed code is in the codebase
- The plan is unchanged

When the user returns and runs `/implement` again, the agent:
1. Reads `status.md` and sees which steps are checked
2. Skips completed steps
3. Resumes from the first incomplete step

This is why `status.md` is updated after EVERY step, not just at the end. It's a crash-recovery mechanism.

### Why not auto-commit

Auto-committing after each step would create a git history like:
```
abc123 Step 1: Create database schema
def456 Step 2: Create migration
ghi789 Step 3: Create route handlers
jkl012 Step 4: Add auth middleware
```

Some developers love this. Others hate it (they want one clean commit per feature). Since git habits are deeply personal, the agent should suggest rather than assume. The `/profile` preference for commit style can inform the suggestion.
