---
description: Recall project memory into the current session. Loads .mema/ knowledge (architecture, decisions, lessons, patterns) and prints a formatted summary. Use at the start of a session to restore context.
---

# /recall — Session Memory Recall

You are executing the /recall skill. This is a **read-only** skill — it loads memory and prints a summary into the conversation. It never writes to any files.

Follow these steps carefully.

## Step 1: Determine Mode

Parse the user's input to decide which mode to use:

- **No arguments** or `minimal` → **Minimal mode** (default) — fast overview of project purpose, stack, and current status
- `full` → **Full mode** — everything in Minimal plus decisions, lessons, patterns, and active context/plans

If the user provides an unrecognized argument (not `minimal`, `full`, or empty):
1. Warn them: "Unknown argument '[arg]'. Available modes: `minimal` (default), `full`."
2. Fall back to **Minimal mode** and continue.

## Step 2: AUTO-LOAD

1. Read `.mema/index.md`
2. If `index.md` is missing or `.mema/` does not exist:
   - Tell the user: "No memory found. Run `/onboard` first to set up mema-kit for this project."
   - **Stop here** — do not continue to further steps.
3. Parse the index to identify available memory files and their summaries.

## Step 3: Load Project Purpose

Read the following files (skip any that don't exist):

1. `.mema/project-memory/architecture.md` — extract tech stack, project structure, architecture pattern, and key commands
2. `.mema/project-memory/requirements.md` — extract project purpose, key requirements, and constraints

These form the core context for both Minimal and Full modes.

## Step 4: Load Current Status

1. Check the `## Active Tasks` section in `index.md`
2. If there are active tasks listed, read any linked status files (e.g., `task-memory/[task-name]/status.md`)
3. Note which tasks are in progress, their current step, and any blockers

## Step 5: Load Additional Files (Full Mode Only)

**Skip this step entirely if in Minimal mode.**

In Full mode, also read these files (skip any that don't exist):

1. **Recent decisions** — Read files listed under `## Recent Decisions` in `index.md`
2. **Lessons** — Read `agent-memory/lessons.md`
3. **Patterns** — Read `agent-memory/patterns.md`
4. **Active context and plans** — Read any `context.md` and `plan.md` files linked from active tasks in `index.md`

Read only files that exist and are listed in the index. Do not scan the directory tree for unlisted files.

## Step 6: REPORT

Print the memory summary directly into the conversation. **Never write output to a file.**

Use the format below based on the current mode.

---

### Minimal Mode Output

```
## Project Memory (Minimal)

### Purpose
[Project name and what it does — from requirements.md]

### Stack & Architecture
[Tech stack, architecture pattern, key entry points — from architecture.md]

### Current Status
[Active tasks and their progress — from index.md + status files]
[If no active tasks: "No active tasks."]

### Memory Map
[List each section from index.md with file count, e.g.:]
- Project Knowledge: [N] files
- Recent Decisions: [N] decisions
- Agent Lessons: [N] lessons, [N] patterns

---
*Showing minimal recall. Use `/recall full` for decisions, lessons, and patterns.*
```

---

### Full Mode Output

```
## Project Memory (Full)

### Purpose
[Project name and what it does — from requirements.md]

### Stack & Architecture
[Tech stack, architecture pattern, key entry points — from architecture.md]

### Current Status
[Active tasks and their progress — from index.md + status files]
[If no active tasks: "No active tasks."]

### Recent Decisions
[For each decision file, list:]
- **[Decision title]** ([date]) — [one-line summary or key choice made]
[If no decisions: "No decisions recorded yet."]

### Lessons
[Bullet list of lessons from lessons.md]
[If no lessons: "No lessons recorded yet."]

### Patterns
[Bullet list of patterns from patterns.md]
[If no patterns: "No patterns recorded yet."]

### Active Context & Plans
[For each active task, summarize its context and plan]
[If none: omit this section]

### Memory Map
- Project Knowledge: [N] files
- Recent Decisions: [N] decisions
- Agent Lessons: [N] lessons, [N] patterns
- Active Tasks: [N] tasks
- Archived Tasks: [N] archived
```

---

**Important:** This skill is purely informational. If you notice memory files are missing or out of date, suggest the user run `/onboard` or the relevant skill — do not attempt to fix memory yourself.
