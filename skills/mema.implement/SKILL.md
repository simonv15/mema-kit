---
description: Execute implementation plan steps one at a time. Picks up the next step from an existing plan, implements it, verifies the result, and tracks progress. Run /plan first to create a plan.
---

# /implement — Plan Step Execution

You are executing the /implement skill. Follow these steps carefully.

This skill picks up a step from an existing plan (created by `/plan`), implements it, verifies the result, and updates progress tracking. By default, it implements **one step at a time** to give the user control over the process.

## Phase 1: AUTO-LOAD

1. Read `.mema/index.md` to understand current project state
2. If `index.md` is missing or `.mema/` does not exist:
   - Tell the user: "No memory found. Run `/onboard` first to set up mema-kit for this project."
   - **Stop here** — do not continue to further steps.
3. If `index.md` is empty, run the **Rebuild Procedure** from `_memory-protocol.md`
4. Scan `## Active Tasks` in `index.md` to find tasks with plans
5. Load relevant memory files:
   - `project-memory/architecture.md` — for technical context during implementation
   - `project-memory/decisions/` — past decisions that affect implementation
   - `agent-memory/lessons.md` — mistakes to avoid
   - `agent-memory/patterns.md` — reusable approaches

## Phase 2: WORK

### 2a: Select Task

Parse the user's input to determine which task to implement:

- **Task specified:** `/implement user-auth` → look for `task-memory/user-auth/`
- **Task + step specified:** `/implement user-auth step 3` → load that specific step
- **No task specified:** `/implement` → list active tasks from index.md and ask which one
- **"all" modifier:** `/implement user-auth all` → implement all remaining steps sequentially (see 2e)

If the specified task directory doesn't exist:
- Tell the user: "No plan found for '[task-name]'. Run `/plan [goal]` first to create an implementation plan."
- **Stop here.**

### 2b: Load Task Context

Read the task's files from `task-memory/[task-name]/`:

1. **`plan.md`** — the full implementation plan with all steps
2. **`status.md`** — current progress (which steps are done)
3. **`context.md`** — exploration findings relevant to this task

If `plan.md` is missing, tell the user: "Task directory exists but has no plan. Run `/plan [goal]` to create one."

### 2c: Select Step

Determine which step to implement:

- **If user specified a step** (e.g., `step 3`): validate it exists in the plan and isn't already complete. If already complete, inform the user and ask if they want to re-implement it.
- **If no step specified:** find the first incomplete step in `status.md` (first unchecked `- [ ]` item). If all steps are complete, see section 2f (Task Completion).

Tell the user which step you're implementing:

```
## Implementing Step [N]/[total]: [Step title]

[Brief description of what this step does]
```

### 2d: Implement the Step

Follow the plan's specification for this step:

1. **Read the step details** from `plan.md` — files to create/modify, specific implementation details, dependencies
2. **Check dependencies** — verify that all prerequisite steps are marked complete in `status.md`. If a dependency is incomplete, warn the user: "Step [N] depends on Step [M] which isn't complete yet. Proceed anyway?" If the user says no, stop.
3. **Implement the changes** — create/modify files as specified in the plan. Follow the project's existing coding patterns (from architecture.md and patterns.md). Apply lessons learned (from lessons.md) to avoid known pitfalls.
4. **Verify the changes:**
   - If the project has tests and the step involves testable code: run relevant tests
   - Check for obvious errors (syntax, imports, type errors)
   - Validate the implementation matches the plan's specification
   - If verification fails: do NOT mark the step as complete. Inform the user with details about what went wrong and suggest fixes.

### 2e: Implement All Remaining (if requested)

If the user requested "all" (e.g., `/implement user-auth all`):

1. Implement steps sequentially, starting from the first incomplete step
2. After each step, verify before moving to the next
3. If any step fails verification, stop and report. Do not continue to subsequent steps.
4. After each successful step, show a brief progress update:
   ```
   Step [N]/[total] complete: [description]
   ```
5. After all steps are done, proceed to 2f (Task Completion)

### 2f: Update Progress

After implementing a step (whether it succeeded or failed):

1. **Update `status.md`:**
   - Mark the completed step: `- [x] Step N: [description]`
   - Add any notes about deviations from the plan under `## Notes`
   - Update the `**Updated:**` date

2. **Print a progress summary:**

```
## Progress: [Task Name]

Step [N]/[total] complete: [what was done]

[if verification passed:]
Verified: [how — tests passed, no errors, etc.]

[if verification failed:]
Issue: [what went wrong]
Suggested fix: [how to resolve]

### Overall Progress
[====------] [completed]/[total] steps
Next: Step [N+1] — [description]

To continue: /implement [task-name]
```

### 2g: Task Completion

If all steps are now complete:

1. Print a completion summary:

```
## Task Complete: [Task Name]

All [N] steps implemented successfully.

### What was built
- [Summary of changes made across all steps]

### Files changed
- [List of files created or modified]

Would you like to archive this task? (This moves it from active tasks to archive/)
```

2. If the user confirms archiving (or doesn't object), proceed to archive in Phase 3.
3. If the user wants to keep it active (e.g., for further iteration), leave it in `task-memory/`.

### 2h: Learn

After completing work (whether one step or all steps), reflect:

- Did anything unexpected happen during implementation? → Record as a lesson
- Did you use a pattern that worked well? → Record as a pattern
- Did any previous lesson prove wrong or need updating? → Update or delete it
- Did the plan need adjustment? → Note this for future planning improvements

## Phase 3: AUTO-SAVE & CURATE

Follow the curation rules in `_memory-protocol.md`. For each piece of knowledge produced:

- **Decisions made** during implementation → ADD to `project-memory/decisions/YYYY-MM-DD-short-name.md`
- **Architecture changes** (if implementation changed the architecture) → UPDATE `project-memory/architecture.md`
- **Lessons learned** → ADD/UPDATE `agent-memory/lessons.md`
- **Patterns discovered** → ADD/UPDATE `agent-memory/patterns.md`
- **Task progress** → UPDATE `task-memory/[task-name]/status.md`

Apply ADD/UPDATE/DELETE/NOOP to each memory file. Most files will be NOOP.

### Task Archiving (on completion)

If the task is fully complete and the user has confirmed archiving:

1. Update `task-memory/[task-name]/status.md`:
   - Set `**Status:** complete`
   - Fill in the `**Completed:**` field with today's date
2. Move the entire `task-memory/[task-name]/` directory to `archive/[task-name]/`
3. Remove the task from `## Active Tasks` in `index.md`

## Phase 4: AUTO-INDEX

Update `.mema/index.md`:
1. Re-read the current index
2. If a step was completed: update the task's summary in `## Active Tasks` (e.g., "3/7 steps complete")
3. If the task was archived: move entry from `## Active Tasks` to remove it, and optionally note it under a completed tasks record
4. Add entries for any new files (decisions, lessons, patterns)
5. Update summaries for modified files
6. Remove entries for deleted files
7. Update the `**Updated:**` date
