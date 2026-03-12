---
description: Execute implementation plan steps one at a time. Picks up the next step from an existing feature plan, implements it, verifies the result, and tracks progress. Run /mema.plan first to create a plan.
---

# /mema.implement — Feature Step Execution

You are executing the /mema.implement skill. Follow these steps carefully.

This skill picks up a step from an existing feature plan (created by `/mema.plan`), implements it, verifies the result, and updates progress tracking. By default, it implements **one step at a time** to give the user control.

## Phase 1: AUTO-LOAD

1. Read `.mema/index.md` to understand current project state
2. If `index.md` is missing or `.mema/` does not exist:
   - Tell the user: "No memory found. Run `/mema.onboard` first."
   - **Stop here.**
3. If `index.md` is empty, run the **Rebuild Procedure** from `_memory-protocol.md`
4. Scan `## Active Features` in `index.md` to find features with plans
5. Load relevant memory:
   - `project/architecture.md` — technical context
   - `project/decisions/` — past decisions that affect implementation
   - `agent/lessons.md` — mistakes to avoid
   - `agent/patterns.md` — reusable approaches

## Phase 2: WORK

### 2a: Select Feature

Parse the user's input:

- **Feature name or number:** `/mema.implement user-auth` or `/mema.implement 001` → find `features/NNN-name/`
- **Feature + step:** `/mema.implement user-auth step 3` → implement that specific step
- **No input:** list active features from index.md and ask which one
- **"all" modifier:** `/mema.implement user-auth all` → implement all remaining steps (see 2e)

If the feature directory doesn't exist:
- Tell the user: "No feature found for '[input]'. Run `/mema.specify` and `/mema.plan` first."
- **Stop here.**

### 2b: Load Feature Context

Read from `features/NNN-name/`:

1. **`tasks.md`** — the ordered task list (prefer this over plan.md for step selection)
2. **`plan.md`** — the technical design
3. **`spec.md`** — what the feature is supposed to do
4. **`status.md`** — current progress

If `tasks.md` is missing, tell the user: "No tasks found. Run `/mema.tasks [feature]` first."

### 2c: Select Step

- **If user specified a step:** validate it exists and isn't already complete. If complete, ask if they want to re-implement it.
- **If no step specified:** find the first incomplete item (`- [ ]`) in `tasks.md`. If all items are complete, proceed to 2f (Task Completion).

Tell the user which step is being implemented:

```
## Implementing: [task description]

[Brief description of what this step does]
```

### 2d: Implement the Step

1. **Read the task details** from `tasks.md` — files to create/modify, what to do
2. **Check dependencies** — if the task references prior tasks that aren't done, warn the user and ask to confirm before proceeding
3. **Implement the changes** — create/modify files as specified; follow the project's existing patterns (from architecture.md and patterns.md); apply lessons (from lessons.md) to avoid known pitfalls
4. **Verify:**
   - If the project has tests relevant to this step: run them
   - Check for syntax errors, missing imports, obvious issues
   - If verification fails: do NOT mark as complete; report what went wrong and suggest a fix

### 2e: Implement All Remaining (if requested)

1. Implement tasks sequentially from first incomplete task
2. Verify each before moving to next
3. If any step fails, stop and report — do not continue
4. Show a brief progress update after each step

### 2f: Update Progress

After each step:

1. **Update `features/NNN-name/status.md`:**
   - Update status to `in-progress` if this is the first step
   - Add a progress log entry: date + task + notes
   - Update "Next Task" field
   - Update `**Updated:**` date

2. **Update `features/NNN-name/tasks.md`:**
   - Mark completed task: `- [x]`

3. **Print progress summary:**

```
## Progress: [Feature Name]

Task complete: [what was done]

[if verified:] Verified: [how]
[if failed:] Issue: [what went wrong] | Suggested fix: [how to resolve]

### Overall Progress
[====------] [completed]/[total] tasks
Next: [next task description]

To continue: /mema.implement [feature-name]
```

### 2g: Feature Completion

If all tasks in `tasks.md` are now complete:

1. Print completion summary:

```
## Feature Complete: [Feature Name]

All [N] tasks implemented.

### What was built
[Summary of changes]

### Files changed
[List of files created or modified]
```

2. **Git Automation Checkpoint:**
   Check if `scripts/bash/commit-changes.sh` exists (use Glob: `scripts/bash/commit-changes.sh`):

   **If found:**
   - Ask the user: "All [N] tasks are complete. Please confirm your tests pass before I commit. (yes/no)"
   - If **yes**:
     - Compose a Conventional Commits message: `feat(<feature-name>): <brief description from spec Purpose>`
     - Stage implementation files: run `git add <file> ...` for each file created or modified during this implementation (review the progress log in `status.md` for the file list)
     - Run: `bash scripts/bash/commit-changes.sh --json "<commit_message>"`
     - On `status: "ok"`: report "Committed [sha]." and print "**To undo: `git reset HEAD~1`**"
       Then ask: "Would you like to open a draft PR? (yes/no)"
       - If **yes** and `scripts/bash/create-pr.sh` exists:
         Generate a PR title (same as the commit message description) and a short body summarising what was built, then run: `bash scripts/bash/create-pr.sh --json "<title>" "<body>"`
         Handle all statuses: `created` → report URL; `exists` → report existing URL; `missing` → display the manual steps printed to stderr; `skipped` → note non-GitHub remote; `error` → report error
       - If `create-pr.sh` not found: note "Run `npx mema-kit` to install PR automation scripts."
     - On `status: "error"`: report the error; do NOT proceed to archiving
   - If **no**: note "Skipping commit — remember to run `git add` + `git commit` + `git push` manually before opening a PR."

   **If not found:** note: "Git scripts not installed — run `npx mema-kit` to enable automatic commit and PR creation."

3. Archive this feature? (moves to `archive/` and removes from active features)
   If user confirms, archive in Phase 3.

### 2h: Learn

After completing work, reflect:
- Unexpected issues → record as lesson
- Patterns that worked → record as pattern
- Previous lessons that were wrong → update or delete them

## Phase 3: AUTO-SAVE & CURATE

Follow curation rules in `_memory-protocol.md`:

- **Decisions made** during implementation → ADD to `project/decisions/YYYY-MM-DD-short-name.md`
- **Architecture changes** → UPDATE `project/architecture.md`
- **Structural changes** (new files, directories, or moves) → UPDATE `project/structure.md`: add/remove/rename the affected entries in `## Directory Tree` and `## Where to Find X`. If nothing structural changed, NOOP.
- **Lessons learned** → ADD/UPDATE `agent/lessons.md`
- **Patterns discovered** → ADD/UPDATE `agent/patterns.md`
- **Task progress** → UPDATE `features/NNN-name/status.md` (done in 2f)

Most files will be NOOP.

### Feature Archiving (on completion)

If fully complete and user confirmed:

1. Update `features/NNN-name/status.md`: set `**Status:** complete`
2. Move `features/NNN-name/` to `archive/NNN-name/`
3. Remove feature from `## Active Features` in `index.md`

## Phase 4: AUTO-INDEX

Update `.mema/index.md`:
1. Re-read the current index
2. Update the feature's summary in `## Active Features` with current progress (e.g., "3/7 tasks complete")
3. If archived: remove from `## Active Features`
4. Add entries for new files (decisions, lessons, patterns)
5. Update `**Updated:**` date
