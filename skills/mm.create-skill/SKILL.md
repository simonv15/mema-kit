---
description: Generate a new memory-aware Claude Code skill. Creates a SKILL.md file with the correct memory lifecycle phases based on the skill's complexity.
---

# /mm.create-skill — Generate Memory-Aware Skills

You are creating a new Claude Code skill that integrates with mema-kit's memory protocol. Follow these steps carefully.

## AUTO-LOAD

1. Read `.mema/index.md` to understand current project state
2. If `index.md` is missing or empty, run the **Rebuild Procedure** from `_memory-protocol.md`
3. If `agent/patterns.md` exists, read it — check what skills have already been created to avoid duplicating existing skill logic

## Step 1: Interview

Gather the following from the user. Keep it to **2-3 exchanges max** — don't over-interview.

### Name validation (apply before asking anything else if name is already provided):
- If the name matches a reserved built-in (`mm.onboard`, `mm.recall`, `mm.plan`, `mm.implement`, `mm.create-skill`), warn: "This name matches a built-in mema-kit skill. Using it in `.claude/skills/` will shadow the built-in. Continue? (yes/no)"
- If the name is not kebab-case, convert it automatically and inform the user: "Name converted to kebab-case: [converted-name]"

### Required:
1. **Skill name** — kebab-case (e.g., `review`, `debug`, `migrate`).
2. **Purpose** — What does this skill do? One sentence is enough. If the answer is a single word or fewer than 5 characters, ask one follow-up question to expand it before proceeding.

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

Based on the interview answers, generate a SKILL.md file using the appropriate template below.

**Critical rule:** Generated skills reference `_memory-protocol.md` for curation rules. NEVER duplicate the memory protocol content inside generated skills.

### Generating the WORK phase (applies to all templates):

When filling the WORK phase of any template:
1. **Decompose the purpose** into 2–5 concrete developer actions — ask yourself: "what would a skilled developer do, step by step, to accomplish [purpose]?"
2. **Write each action** as an imperative instruction sentence (e.g., "Read each changed file and identify…"; "Compare findings against…"; "Write a summary of…")
3. **If the purpose has multiple distinct concerns** (multiple verbs, the word "and", or conditional logic) — organize into sub-sections: `### 2a: [First concern]`, `### 2b: [Second concern]`

### Generating AUTO-LOAD hints (standard and advanced templates):

Scan the purpose for domain keywords and replace the `[Add or remove entries…]` placeholder with relevant `.mema/` paths:
- Always include: `project/architecture.md` — technical context; `agent/lessons.md` — mistakes to avoid
- "decide / choose / compare / evaluate" → add `project/decisions/` — past decisions on this domain
- "pattern / reuse / template" → add `agent/patterns.md` — reusable approaches
- "implement / build / create / migrate" → add active `features/[feature-name]/` if one exists in the index
- "test / validate / check / audit" → note in `agent/lessons.md` entry that testing lessons are especially relevant

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
2. If `index.md` is missing or empty, inform the user to run `/mm.onboard` first
3. Based on the user's request, identify and read relevant memory files
4. Read only what's needed — don't load everything

## Phase 2: WORK

[Generate 2–5 concrete steps from the purpose — no placeholder text]

Use the loaded memory context to inform your work.

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
- `project/architecture.md` — for technical context
- `agent/lessons.md` — for mistakes to avoid
[Derive additional entries from purpose keywords per Step 2 generation instructions]

## Phase 2: WORK

[Generate 2–5 concrete steps from the purpose — no placeholder text]

Use the loaded memory context to inform your work.

## Phase 3: AUTO-SAVE & CURATE

Follow the curation rules in `_memory-protocol.md`. For each piece of knowledge produced:

- **Decisions made** → ADD to `project/decisions/YYYY-MM-DD-short-name.md`
- **Architecture changes** → UPDATE `project/architecture.md`
- **Lessons learned** → ADD/UPDATE `agent/lessons.md`
- **Patterns discovered** → ADD/UPDATE `agent/patterns.md`
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
   - Task-specific: `features/[feature-name]/` (context, plan, status)
   - Project-wide: `project/architecture.md`, relevant decisions
   - Agent knowledge: `agent/lessons.md`, `agent/patterns.md`
4. Read only what's needed — don't load everything

## Phase 2: WORK

### 2a: Task Setup
If no task directory exists for this work:
1. Create `features/[feature-name]/`
2. Write initial `context.md` with the task description and relevant findings

If a task directory exists, read the current status and continue where you left off.

### 2b: Core Work

[Generate 2–5 concrete steps from the purpose — no placeholder text]

Track progress by updating `features/[feature-name]/status.md` as you go.

### 2c: Learn

After completing work, reflect:
- Did anything unexpected happen? → Record as a lesson
- Did you use a pattern that worked well? → Record as a pattern
- Did any previous lesson prove wrong? → Update or delete it

## Phase 3: AUTO-SAVE & CURATE

Follow the curation rules in `_memory-protocol.md`. For each piece of knowledge produced:

- **Decisions made** → ADD to `project/decisions/YYYY-MM-DD-short-name.md`
- **Architecture changes** → UPDATE `project/architecture.md`
- **Lessons learned** → ADD/UPDATE `agent/lessons.md`
- **Patterns discovered** → ADD/UPDATE `agent/patterns.md`
- **Task progress** → UPDATE `features/[feature-name]/status.md`

Apply ADD/UPDATE/DELETE/NOOP to each memory file. Most files will be NOOP.

### Task Completion
If the task is fully complete:
1. Mark `features/[feature-name]/status.md` as `**Status:** complete`
2. Move `features/[feature-name]/` to `archive/[task-name]/`
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

## Step 2.5: Draft Review

Before writing any file to disk, show the user the complete generated SKILL.md for review.

1. Render the full generated SKILL.md content inside a fenced code block
2. Ask:
   > "Does this look correct? Reply **APPROVE** to write the file, describe a specific change to revise, or **CANCEL** to exit without writing."
3. **On a change request**: Apply the change to the named section only. Re-render the full draft. Repeat the prompt. If the user has requested more than 3 revisions, warn: "Multiple revisions requested. Consider re-running `/mm.create-skill` with a more detailed purpose." — then continue with the current draft.
4. **On CANCEL**: Exit immediately. Do not write, create, or modify any files.
5. **On APPROVE**: Proceed to Step 3.

## Step 3: Write the File

### Existence check

Before writing, check whether `.claude/skills/[skill-name]/SKILL.md` already exists.

**If the file does NOT exist:**
1. Create the directory `.claude/skills/[skill-name]/` if it doesn't exist
2. Write the approved content to `.claude/skills/[skill-name]/SKILL.md`

**If the file EXISTS:**
1. Read the existing file; extract the `description` frontmatter value and all `## Phase`, `## Step`, and `## AUTO-*` headings (headings only, not body content)
2. Show the user:
   ```
   Existing skill found: /[skill-name]
   Description: [existing description]
   Sections: [list of headings]

   Choose an action:
   (1) Enhance existing — apply a described change to specific sections
   (2) Overwrite — start fresh (goes through preview)
   (3) Cancel — exit without changes
   ```
3. **Option 1 — Enhance**: Ask "What specifically should I change?" Apply the directive to the named section(s) only, preserving everything else. Run the modified file through the Step 2.5 Draft Review flow, then write on APPROVE.
4. **Option 2 — Overwrite**: Discard the existing content. Return to Step 1 and run the full interview → generation → preview flow from scratch.
5. **Option 3 — Cancel**: Exit. No file changes.

## Step 4: Verify

Read back the file you just wrote and confirm:
- The `description` frontmatter is present and accurate
- The skill name is correct throughout
- Memory file paths use `.mema/` (not `.praxis/` or any other prefix)
- The skill references `_memory-protocol.md` for curation rules (standard and advanced only)
- No memory protocol content is duplicated inside the skill
- No `[…]`-style placeholder text remains

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

## AUTO-SAVE & CURATE

Follow the curation rules in `_memory-protocol.md`.

**If a skill file was written** (user did not CANCEL):
- ADD/UPDATE `agent/patterns.md` with a lightweight record: skill name, complexity level, one-sentence purpose, action taken (`created` / `enhanced` / `overwritten`), date (`YYYY-MM-DD`)
- UPDATE `project/structure.md`:
  - Add `├── [skill-name]/   — [skill purpose, one clause]` to the `.claude/skills/` subtree in `## Directory Tree`
  - Add entry to `## Where to Find X`: `**[Skill name] skill:** .claude/skills/[skill-name]/SKILL.md`
  - If `project/structure.md` does not exist, NOOP (structure.md is created by `/mm.onboard`)

**If no file was written** (user cancelled at any step):
- NOOP — no memory changes

## AUTO-INDEX

Update `.mema/index.md`:
1. Re-read the current index
2. If `agent/patterns.md` was modified, update its summary entry
3. If `project/structure.md` was modified, update its summary entry
4. Update the `**Updated:**` date
