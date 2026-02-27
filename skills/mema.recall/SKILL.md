---
description: Recall project memory into the current session. Loads .mema/ knowledge (architecture, decisions, lessons, patterns) and prints a formatted summary. Use at the start of a session to restore context.
---

# /mema.recall — Session Memory Recall

You are executing the /mema.recall skill. This is a **read-only** skill — it loads memory and prints a summary into the conversation. It never writes to any files.

Follow these steps carefully.

## Step 1: Determine Mode

Parse the user's input to decide which mode to use:

- **No arguments** or `minimal` → **Minimal mode** (default) — fast overview with active features, project identity, and next action
- `full` → **Full mode** — everything in Minimal plus decisions, lessons, patterns, and product discovery

If the user provides an unrecognized argument, warn them and fall back to Minimal mode.

## Step 2: AUTO-LOAD

1. Read `.mema/index.md`
2. If `index.md` is missing or `.mema/` does not exist:
   - Tell the user: "No memory found. For an existing project, run `/mema.onboard` to set up mema-kit. For a new idea, run `/mema.seed` to start the discovery workflow."
   - **Stop here** — do not continue.
3. Parse the index to identify available memory files.

## Step 3: Load Active Features

Read `features/NNN-name/status.md` for every feature directory listed under `## Active Features` in `index.md` that is NOT marked `complete`.

For each active feature, note:
- Feature name and number
- Current status (`pending` or `in-progress`)
- Last completed task and next task (from status.md progress log)

This is the most important context — surface it first.

## Step 4: Load Project Knowledge

Read the following (skip any that don't exist):

1. `.mema/project/architecture.md` — tech stack, structure, architecture pattern
2. `.mema/project/requirements.md` — project purpose and constraints

## Step 5: Load Additional Files (Full Mode Only)

**Skip entirely if in Minimal mode.**

1. **Recent decisions** — Read files listed under `## Project Knowledge` → `decisions/` in `index.md`
2. **Lessons** — Read `agent/lessons.md`
3. **Patterns** — Read `agent/patterns.md`
4. **Product discovery** — Read `product/roadmap.md` summary if listed in index

Read only files that exist and are listed in the index.

## Step 6: REPORT

Print the memory summary directly into the conversation. **Never write output to a file.**

---

### Minimal Mode Output

```
## Project Memory

### Active Features
[For each active feature:]
- **[NNN] [Feature name]** — [status] | Next: [next task]
[If no active features: "No features in progress. Run /mema.specify to start one."]

### Project
[Name] — [purpose from requirements.md]
Stack: [tech stack from architecture.md]

### What to run next
[Suggest the most logical next command based on active feature status]

---
*Use `/mema.recall full` for decisions, lessons, and product discovery.*
```

---

### Full Mode Output

```
## Project Memory (Full)

### Active Features
[For each active feature:]
- **[NNN] [Feature name]** — [status] | Next: [next task]
[If no active features: "No features in progress. Run /mema.specify to start one."]

### Product Discovery
[If product/ files exist:]
- Idea: [summary from seed.md]
- Roadmap: [N features defined — from roadmap.md]
[If no product/ files: omit section]

### Project
[Name] — [purpose]
Stack: [tech stack]
Architecture: [pattern]

### Recent Decisions
[For each decision file, list:]
- **[Decision title]** — [one-line summary]
[If none: "No decisions recorded yet."]

### Lessons
[Bullet list from agent/lessons.md]
[If none: "No lessons recorded yet."]

### Patterns
[Bullet list from agent/patterns.md]
[If none: "No patterns recorded yet."]

### Memory Map
- Active Features: [N]
- Product Discovery: [files present]
- Project Knowledge: [N] files, [N] decisions
- Agent Knowledge: [N] lessons, [N] patterns
```

---

**Important:** This skill is purely informational. If memory files are missing or out of date, suggest the user run `/mema.onboard` or the relevant skill — do not modify memory files yourself.
