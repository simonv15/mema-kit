---
description: Generate an ordered implementation task list for a feature. Reads the feature spec and plan, then writes a checkable task list to features/NNN-name/tasks.md.
---

# /mema.tasks — Feature Task Generation

You are executing the /mema.tasks skill. Follow these steps carefully.

This skill turns a technical plan into a concrete, ordered task list that `/mema.implement` can execute step by step.

## AUTO-LOAD

1. Read `.mema/index.md`
2. If `.mema/` doesn't exist:
   - Tell the user: "No memory found. Run `/mema.onboard` first."
   - **Stop here.**
3. Load relevant memory:
   - `agent/lessons.md` — to inform task granularity based on past experience
   - `agent/patterns.md` — to apply known good patterns in task ordering

## WORK

### Select Feature

Parse the user's input:
- **Number or name given** (e.g., `/mema.tasks 001` or `/mema.tasks user-auth`): find matching `features/NNN-name/`
- **No input**: list features that have `plan.md` but no `tasks.md`; ask which to generate tasks for

If no matching feature directory:
- Tell the user: "No feature found for '[input]'. Run `/mema.specify` first."
- **Stop here.**

### Load Feature Files

Read from `features/NNN-name/`:
1. **`plan.md`** — the technical design (required)
2. **`spec.md`** — acceptance criteria to guide task completeness

If `plan.md` is missing:
- Tell the user: "No plan found for [feature-name]. Run `/mema.plan [feature]` first."
- **Stop here.**

### Handle Existing tasks.md

If `tasks.md` already exists:
- Check if any tasks are already checked off (`- [x]`)
- If tasks are in progress: warn the user: "Tasks are partially complete ([N] done). Regenerating will reset unchecked tasks. Continue?"
- If no tasks started: regenerate silently

### Generate the Task List

From the plan, derive an ordered sequence of implementation tasks:

**Task properties:**
- Start with a verb: "Create", "Add", "Update", "Write", "Implement", "Configure"
- Include the exact file path when a specific file is involved
- Small enough that each task completes in one `/mema.implement` invocation
- Ordered logically: foundations before features, features before tests, tests before polish

**Grouping** (use section headers when ≥ 6 tasks):
- **Setup**: directory creation, config files, schema migrations
- **Core**: main implementation tasks
- **Tests**: test files (if the project has tests)
- **Polish**: documentation, cleanup, edge case handling

**Good task examples:**
- `- [ ] Create \`src/auth/service.ts\` with login and register functions`
- `- [ ] Add JWT middleware to \`src/middleware/auth.ts\``
- `- [ ] Update \`src/routes/index.ts\` to protect authenticated routes`

**Bad task examples (too vague):**
- `- [ ] Implement authentication` (too broad — what files? what functions?)
- `- [ ] Write tests` (which tests? for what?)

### Verify Coverage

Before writing, check: do the tasks, when completed, satisfy all acceptance criteria from `spec.md`? If any criterion is not covered by a task, add a task for it.

### Write Task File

Write `.mema/features/NNN-name/tasks.md`:

```
# [Feature Name] — Tasks

**Status:** active | **Updated:** [today's date]

## Setup

- [ ] [Setup task with file path]

## Core

- [ ] [Core task with file path]
- [ ] [Core task with file path]

## Tests

- [ ] [Test task with file path]

## Polish

- [ ] [Polish task]
```

Omit sections that have no tasks (e.g., omit Tests if the project has no test setup).

### Confirm to User

```
Tasks generated: features/[NNN-name]/tasks.md

[N] tasks across [M] sections.

Next: /mema.implement [NNN-name]
```

## AUTO-SAVE & CURATE

- ADD or UPDATE `features/NNN-name/tasks.md`
- UPDATE `features/NNN-name/status.md`: add note "tasks generated on [date]"
- NOOP on all other files

## AUTO-INDEX

Update `.mema/index.md`:
1. Update entry in `## Active Features`: `- \`features/NNN-name/\` — [description] (tasks ready, [N] tasks)`
2. Update `**Updated:**` date
