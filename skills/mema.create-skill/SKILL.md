---
description: Generate a new memory-aware Claude Code skill. Creates a SKILL.md file with the correct memory lifecycle phases based on the skill's complexity.
---

# /mema.create-skill — Generate Memory-Aware Skills

You are creating a new Claude Code skill that integrates with mema-kit's memory protocol. Follow these steps carefully.

## Step 1: Interview

Gather the following from the user. Keep it to **2-3 exchanges max** — don't over-interview.

### Required:
1. **Skill name** — kebab-case (e.g., `review`, `debug`, `migrate`). If the user gives a name with spaces or camelCase, convert it.
2. **Purpose** — What does this skill do? One sentence is enough.

### Optional (offer sensible defaults):
3. **Memory needs** — Does this skill need to:
   - **Read** memory (load context, architecture, lessons) — most skills
   - **Write** memory (save decisions, findings, lessons) — skills that produce knowledge
   - **Both** (default) — most useful skills both read and write
4. **Complexity level**:
   - **Simple** — Read-only or minimal memory. 3 phases: AUTO-LOAD, WORK, REPORT. Good for: code review, linting, quick lookups.
   - **Standard** (default) — Full 4-phase lifecycle. Good for: most skills that produce and consume knowledge.
   - **Advanced** — Full lifecycle + task management, archiving, and lesson learning. Good for: implementation skills, multi-step workflows.

If the user doesn't specify memory needs or complexity, default to **both** and **standard**.

## Step 2: Generate SKILL.md

Based on the interview answers, generate a SKILL.md file. Use the appropriate template below based on complexity level.

**Critical rule:** Generated skills reference `_memory-protocol.md` for curation rules. NEVER duplicate the memory protocol content inside generated skills.

---

### Simple Template (3 phases)

```markdown
---
description: [User's purpose description]
---

# /[skill-name] — [Title]

You are executing the /[skill-name] skill. Follow these steps carefully.

## Phase 1: AUTO-LOAD

1. Read `.mema/index.md` to understand current project state
2. If `index.md` is missing or empty, inform the user to run `/mema.onboard` first
3. Based on the user's request, identify and read relevant memory files
4. Read only what's needed — don't load everything

## Phase 2: WORK

[Core skill logic goes here — describe what the skill does step by step]

1. [First action]
2. [Second action]
3. [Third action]

Use the loaded memory context to inform your work. Reference architecture decisions, past lessons, and patterns where relevant.

## Phase 3: REPORT

Summarize what was done and any findings. If you discovered anything worth preserving, tell the user:

"I noticed [finding]. Consider saving this as a lesson/decision/pattern using a memory-writing skill."

Do NOT modify memory files directly in a simple skill.
```

---

### Standard Template (4 phases)

```markdown
---
description: [User's purpose description]
---

# /[skill-name] — [Title]

You are executing the /[skill-name] skill. Follow these steps carefully.

## Phase 1: AUTO-LOAD

1. Read `.mema/index.md` to understand current project state
2. If `index.md` is missing or empty, run the **Rebuild Procedure** from `_memory-protocol.md`
3. Based on the user's request, identify and read relevant memory files
4. Read only what's needed — don't load everything

**Relevant memory for this skill:**
- `project-memory/architecture.md` — for technical context
- `project-memory/decisions/` — for past decisions related to this work
- `agent-memory/lessons.md` — for mistakes to avoid
- `agent-memory/patterns.md` — for reusable approaches
- [Add or remove entries based on the skill's purpose]

## Phase 2: WORK

[Core skill logic goes here — describe what the skill does step by step]

1. [First action]
2. [Second action]
3. [Third action]

Use the loaded memory context to inform your work.

## Phase 3: AUTO-SAVE & CURATE

Follow the curation rules in `_memory-protocol.md`. For each piece of knowledge produced:

- **Decisions made** → ADD to `project-memory/decisions/YYYY-MM-DD-short-name.md`
- **Architecture changes** → UPDATE `project-memory/architecture.md`
- **Lessons learned** → ADD/UPDATE `agent-memory/lessons.md`
- **Patterns discovered** → ADD/UPDATE `agent-memory/patterns.md`
- **Exploration findings** → ADD to appropriate `task-memory/` or `project-memory/` file

Apply ADD/UPDATE/DELETE/NOOP to each memory file. Most files will be NOOP.

## Phase 4: AUTO-INDEX

Update `.mema/index.md`:
1. Re-read the current index
2. Add entries for new files
3. Update summaries for modified files
4. Remove entries for deleted files
5. Update the `**Updated:**` date
```

---

### Advanced Template (4 phases + task management)

```markdown
---
description: [User's purpose description]
---

# /[skill-name] — [Title]

You are executing the /[skill-name] skill. Follow these steps carefully.

## Phase 1: AUTO-LOAD

1. Read `.mema/index.md` to understand current project state
2. If `index.md` is missing or empty, run the **Rebuild Procedure** from `_memory-protocol.md`
3. Based on the user's request, identify and read relevant memory files:
   - Task-specific: `task-memory/[task-name]/` (context, plan, status)
   - Project-wide: `project-memory/architecture.md`, relevant decisions
   - Agent knowledge: `agent-memory/lessons.md`, `agent-memory/patterns.md`
4. Read only what's needed — don't load everything

## Phase 2: WORK

### 2a: Task Setup
If no task directory exists for this work:
1. Create `task-memory/[task-name]/`
2. Write initial `context.md` with the task description and relevant findings

If a task directory exists, read the current status and continue where you left off.

### 2b: Core Work

[Core skill logic goes here — describe what the skill does step by step]

1. [First action]
2. [Second action]
3. [Third action]

Track progress by updating `task-memory/[task-name]/status.md` as you go.

### 2c: Learn

After completing work, reflect:
- Did anything unexpected happen? → Record as a lesson
- Did you use a pattern that worked well? → Record as a pattern
- Did any previous lesson prove wrong? → Update or delete it

## Phase 3: AUTO-SAVE & CURATE

Follow the curation rules in `_memory-protocol.md`. For each piece of knowledge produced:

- **Decisions made** → ADD to `project-memory/decisions/YYYY-MM-DD-short-name.md`
- **Architecture changes** → UPDATE `project-memory/architecture.md`
- **Lessons learned** → ADD/UPDATE `agent-memory/lessons.md`
- **Patterns discovered** → ADD/UPDATE `agent-memory/patterns.md`
- **Task progress** → UPDATE `task-memory/[task-name]/status.md`

Apply ADD/UPDATE/DELETE/NOOP to each memory file. Most files will be NOOP.

### Task Completion
If the task is fully complete:
1. Mark `task-memory/[task-name]/status.md` as `**Status:** complete`
2. Move `task-memory/[task-name]/` to `archive/[task-name]/`
3. Remove the task from "Active Tasks" in `index.md`

## Phase 4: AUTO-INDEX

Update `.mema/index.md`:
1. Re-read the current index
2. Add entries for new files
3. Update summaries for modified files
4. Remove entries for deleted files
5. Update the `**Updated:**` date
```

---

## Step 3: Write the File

1. Write the generated SKILL.md to `.claude/skills/[skill-name]/SKILL.md`
2. Create the directory if it doesn't exist
3. If the file already exists, warn the user and ask before overwriting

## Step 4: Verify

Read back the file you just wrote and confirm:
- The `description` frontmatter is present and accurate
- The skill name is correct throughout
- Memory file paths use `.mema/` (not `.praxis/` or any other prefix)
- The skill references `_memory-protocol.md` for curation rules (standard and advanced only)
- No memory protocol content is duplicated inside the skill

## Step 5: Confirm

Tell the user:

```
Skill created: /[skill-name]

Location: .claude/skills/[skill-name]/SKILL.md
Type: [simple|standard|advanced]
Memory: [read-only|write-only|read+write]

To use it:
  /[skill-name] [your request]

The skill follows the mema-kit memory protocol and will [read from / write to / read from and write to] .mema/ automatically.
```
