# 01 — Memory Protocol

**Produces:** `skills/_memory-protocol.md`
**Milestone:** 1
**Dependencies:** None — this is the foundation everything else builds on

---

## What This File Is

The memory protocol is a single markdown file that lives in `.claude/skills/` alongside the SKILL.md files. Every skill references it with an instruction like "Read and follow `_memory-protocol.md` for all memory operations." It's the **single source of truth** for how the agent reads, writes, and curates memory in `.praxis/`.

### Why a separate file instead of embedding in each SKILL.md?

**Decision: Extract the protocol into its own file.**

Reasoning:
- There are 6 skills, and at least 4 of them (explore, plan-docs, gen-test, implement) need identical memory instructions.
- If we embedded the protocol in each SKILL.md, we'd have ~80 lines of duplicated instructions across 4 files. That's a maintenance nightmare — change one, forget another, and behavior becomes inconsistent.
- Claude Code loads all files in `.claude/skills/` into context, so `_memory-protocol.md` will be available automatically when any skill runs.
- The underscore prefix (`_memory-protocol.md`) is a deliberate convention to signal "this is a shared resource, not a standalone skill." It won't appear as a slash command because it has no YAML frontmatter with a `description` field.

Alternative considered: Put the protocol in `.praxis/` with the data. Rejected because the protocol is an **instruction file** (tells the agent what to do), not a **memory file** (stores project knowledge). It should version-control with the skills, not with ephemeral memory data.

---

## Key Design Decisions

### 1. The curation framework: ADD / UPDATE / DELETE / NOOP

**Decision: Use a four-operation framework adapted from Mem0's research.**

Reasoning:
- Mem0's paper showed that structured curation (deciding explicitly what to add, update, or delete) beats naive "save everything" by 26% accuracy and saves 90% tokens.
- But Mem0 uses a vector database with programmatic operations. We need the same framework expressed as **natural language instructions** that Claude can follow.
- Four operations is the minimum complete set: you can create, modify, remove, or leave alone. Adding more (MERGE, SPLIT, ARCHIVE) would increase cognitive load without proportional benefit. Archiving is handled by the `/implement` skill at task completion, not by the protocol itself.
- NOOP is explicitly included (rather than just "do nothing if none of the others apply") because it forces the agent to **consciously decide** that a memory is still valid. Without NOOP, the agent might skip memories without evaluating them.

### 2. Metadata format: in-body markers, not YAML frontmatter

**Decision: Use `**Status:** active | **Updated:** 2026-02-23` in the markdown body.**

Reasoning:
- LLMs are notoriously inconsistent with YAML frontmatter. They sometimes forget the closing `---`, mix up indentation, or generate invalid YAML that breaks parsers.
- In-body bold markers are just markdown text. Claude generates them reliably. They're easy to read for humans too.
- We only need two pieces of metadata: status (active/complete/archived) and last updated date. YAML would be overkill.
- There's no parser reading this metadata programmatically — only the agent reads it. Bold markers are unambiguous to an LLM.

Alternative considered: No metadata at all, just file names and directory placement. Rejected because status information (is this decision still active? when was this last updated?) is valuable for the agent's curation decisions, and encoding it purely in directory structure (e.g., moving to `archive/`) is too coarse.

### 3. Per-file-type curation rules

**Decision: Define different curation behaviors for each memory file type.**

Reasoning:
- Not all memory is equal. A decision (e.g., "chose PostgreSQL because X") should almost never be deleted — it's a historical record. But an exploration context (e.g., "compared 5 databases") should be pruned once a decision is made.
- Without per-type rules, the agent has to figure out the right behavior from scratch every time. This leads to inconsistency — sometimes it over-prunes, sometimes it hoards.
- By defining clear rules ("decisions: rarely delete, update when changed" vs. "context: prune dead-ends, consolidate findings"), we give the agent a simple lookup: what type of file is this? → follow these rules.

The four file types and their curation personalities:

| File type | Curation personality | Why |
|-----------|---------------------|-----|
| `decision.md` | **Conservative** — rarely delete, update when changed | Decisions are historical record. Even reversed decisions have value ("we tried X, it failed because Y"). |
| `context.md` | **Aggressive** — prune dead-ends, consolidate findings | Exploration context accumulates fast. Dead-end research (evaluated but rejected) has no future value. Keeping it wastes tokens on future loads. |
| `plan.md` | **Replace** — keep final version only, update during implementation | Draft plans are noise once a final plan exists. Implementation discoveries should update the plan, not create new files. |
| `lessons.md` | **Consolidate** — merge similar lessons, update with new examples | Lessons compound. "Drizzle needs explicit type casting" and "Drizzle enum handling requires casting" are the same lesson — merge them. |

### 4. Index.md update procedure

**Decision: Mandatory final step in every skill, with rebuild-from-scan fallback.**

Reasoning:
- The index is the agent's entry point — if it's stale, the agent loads wrong context. Making the update mandatory (not optional) ensures it stays current.
- But mandating updates creates a fragility: what if a skill crashes before updating the index? Or what if the user manually edits `.praxis/` files? The index could go stale.
- The fallback solves this: if the index seems wrong (file referenced doesn't exist, or a file exists that's not in the index), the agent rebuilds from a directory scan. This makes the index a **cache**, not a source of truth.
- The rebuild procedure is simple: list all `.md` files in `.praxis/` subdirectories, read each file's first line and metadata, generate a new index. It takes seconds.

### 5. Relevance-based loading (not "load everything")

**Decision: The agent reads index.md, then decides which files to load based on the current task.**

Reasoning:
- Loading all memory files into context would waste tokens and dilute relevance. A project with 10+ explorations and 5 completed tasks could have 30+ memory files. Loading all of them would consume a huge chunk of the context window with mostly irrelevant information.
- The index is designed to be a quick-scan document: one-line summaries with file paths. The agent reads ~20 lines, makes a relevance decision ("this task is about auth, so I need the JWT decision and the API architecture, but not the CSS framework exploration"), and loads 2-4 files.
- This is the pattern Anthropic recommends: "Keep lightweight identifiers, load data on demand."
- This is also what makes Mem0's selective retrieval so effective: only load what matters for the current context.

---

## Implementation Guide

### Step 1: Create the file

Create `skills/_memory-protocol.md` with the content below. This file has no YAML frontmatter — it's not a skill, it's a shared reference document.

### Step 2: Verify integration points

After creating the file, make sure:
- It will be included when copying skills to `.claude/skills/` (the CLI script should copy everything in `skills/`)
- Each SKILL.md that uses memory references it explicitly (see plans 05–08)

### Step 3: Test the protocol

Before building any skills, you can test the protocol manually:
1. Create a mock `.praxis/` directory with some sample files
2. Give Claude Code the protocol text and ask it to curate the mock data
3. Check: Does it correctly identify what to ADD, UPDATE, DELETE, NOOP?
4. Check: Does it rebuild index.md correctly from a directory scan?

---

## Full File Content

Below is the complete content for `skills/_memory-protocol.md`. This is what gets installed into user projects at `.claude/skills/_memory-protocol.md`.

```markdown
# Memory Protocol

This document defines how you manage memory in `.praxis/`. Every skill that reads or writes memory must follow these rules.

## The Memory Lifecycle

Every skill execution follows four phases:

### Phase 1: AUTO-LOAD
1. Read `.praxis/index.md` to understand current project state
2. If `index.md` is missing or empty, run the **Rebuild Procedure** (see below)
3. Based on the user's request, decide which memory files are relevant
4. Read only the relevant files — do NOT load everything

**How to decide relevance:** Scan each index entry's one-line summary. If it relates to the user's current topic, technology, or task — load it. When in doubt, load it. When clearly unrelated, skip it.

### Phase 2: WORK
Execute the skill's core purpose (research, planning, test generation, implementation) with the loaded context.

### Phase 3: AUTO-SAVE & CURATE
For every piece of knowledge produced during this session, decide one of four actions:

**ADD** — Save new knowledge that doesn't exist yet
- A new decision with reasoning
- A new exploration finding worth preserving
- A new lesson learned from implementation
- A new pattern discovered for reuse

**UPDATE** — Modify existing knowledge that has changed
- A decision's reasoning was refined
- Architecture changed due to new requirements
- A plan step was adjusted during implementation
- A lesson gained a new example

**DELETE** — Remove knowledge that is wrong, superseded, or irrelevant
- Dead-end exploration (evaluated and rejected — no future value)
- Superseded decisions (old decision replaced by new one — keep the new one only)
- Redundant information (already captured in a more complete file)
- Temporary notes that served their purpose

**NOOP** — Leave unchanged (the memory is still accurate and relevant)
- Most memories should be NOOP on any given skill execution
- Only act (ADD/UPDATE/DELETE) when there's a clear reason

### Phase 4: AUTO-INDEX
Update `.praxis/index.md` to reflect all changes made in Phase 3. This is **mandatory** — never skip it.

## What to Save vs. What to Prune

### SAVE (curated knowledge worth preserving):
- Decisions with reasoning: "Chose Fastify over Express because: 2x faster benchmarks, built-in schema validation, better TypeScript support"
- Architecture and design patterns: "API follows controller → service → repository layers"
- Requirements and constraints: "Must support 100 concurrent users, PostgreSQL is required by client"
- Lessons from failures: "Drizzle ORM needs explicit type casting for PostgreSQL enums — spent 30 min debugging this"
- Reusable patterns: "Fastify route registration pattern: define schema, write handler, register in app.ts"

### PRUNE (noise that wastes future context):
- Conversational back-and-forth that led to a conclusion (keep the conclusion, prune the discussion)
- Dead-end explorations with no useful outcome (evaluated MongoDB, doesn't fit — delete the comparison notes)
- Temporary debugging context (fixed the bug, no recurring lesson — delete)
- Verbose explanations when a concise summary exists (condense, don't hoard)
- Information already captured elsewhere (don't duplicate across files)

## Per-File-Type Curation Rules

### decision.md — Conservative curation
- **Rarely delete.** Decisions are historical record. Even reversed decisions teach future sessions why something didn't work.
- **UPDATE** when the decision is refined, expanded, or its status changes.
- **ADD** reasoning if the original entry lacks a "why."
- Only **DELETE** if the decision was recorded in error (wrong project, duplicate entry).

### context.md — Aggressive curation
- **Prune dead-end explorations.** If you explored 5 options and chose 1, delete the notes on the 4 rejected options. The decision file captures what was chosen and why.
- **Consolidate findings.** If multiple explorations cover overlapping ground, merge them into one concise context file.
- **DELETE** when a decision supersedes the exploration entirely (the exploration's value is now captured in the decision).

### plan.md — Replace curation
- **Keep the final version only.** Draft plans are noise once a final plan exists.
- **UPDATE** during implementation — mark steps as complete, note adjustments.
- **Do not create multiple plan versions.** Overwrite the plan when it changes.

### lessons.md and patterns.md — Consolidation curation
- **Merge similar lessons.** "Drizzle needs type casting" and "Drizzle enum handling requires explicit cast" are the same lesson — keep one entry with both examples.
- **UPDATE** with new examples when the same pattern/lesson recurs.
- **DELETE** if a lesson is proven wrong by later experience.
- **Consolidate periodically.** If lessons.md exceeds ~30 entries, group related lessons under headers.

## Metadata Format

Every memory file includes metadata in the body (not YAML frontmatter):

```
**Status:** active | **Updated:** 2026-02-23
```

Status values:
- `active` — Current and relevant
- `complete` — Finished but still useful for reference
- `archived` — Moved to archive/ (set by /implement on task completion)

Place metadata on the line immediately after the title heading.

## index.md Format

The index is a structured pointer map with four sections:

```
# Memory Index

**Updated:** 2026-02-23

## Active Tasks
- `task-memory/api-setup/` — Setting up REST API with Fastify (plan ready, implementing)

## Project Knowledge
- `project-memory/architecture.md` — Node.js + Fastify + PostgreSQL + Drizzle stack
- `project-memory/requirements.md` — Core requirements and constraints

## Recent Decisions
- `project-memory/decisions/2026-02-23-tech-stack.md` — Chose Fastify + PostgreSQL + Drizzle
- `project-memory/decisions/2026-02-23-auth-jwt.md` — JWT with refresh tokens for auth

## Agent Lessons
- `agent-memory/lessons.md` — 3 lessons recorded (Drizzle type casting, Fastify plugin order, test isolation)
- `agent-memory/patterns.md` — 2 patterns recorded (route registration, error handling middleware)
```

Each entry is: `- \`file-path\` — one-line summary`

### Updating the Index
After every curated save:
1. Re-read the current index.md
2. Add entries for new files
3. Update summaries for modified files
4. Remove entries for deleted files
5. Update the `**Updated:**` date

### Rebuild Procedure (fallback)
If `index.md` is missing, empty, or clearly stale (references files that don't exist):
1. List all directories in `.praxis/`: `project-memory/`, `task-memory/`, `agent-memory/`, `archive/`
2. For each directory, list all `.md` files (excluding `_templates/`)
3. Read the first 3 lines of each file to get title and metadata
4. Generate index entries in the format above
5. Write the rebuilt `index.md`

This procedure makes the index a **rebuildable cache** — it's convenient but never the only copy of truth. The actual files in `.praxis/` are the source of truth.
```

---

## Design Notes for Future Reference

### Why not use a database or JSON for the index?

Markdown is the right format because:
1. The agent reads it with the same Read tool it uses for everything else — no special parsing needed
2. Humans can read and edit it directly
3. It's small enough (~20 lines for a typical project) that the agent scans it in seconds
4. There's no programmatic consumer that would benefit from structured formats like JSON

### Why "one-line summaries" in the index?

The summary serves as a **relevance signal**. When the agent reads the index, it uses the summary to decide whether to load the full file. If summaries were too short ("tech stack decision"), the agent couldn't make good relevance decisions. If summaries were too long (full paragraphs), the index itself would become bloated.

One line (~10-15 words) is the sweet spot: enough to judge relevance, small enough that 20+ entries still fit in a quick scan.

### Why the explicit "NOOP" operation?

It would be natural to say "if none of ADD/UPDATE/DELETE apply, do nothing." But explicitly naming NOOP forces the agent to evaluate every existing memory and consciously decide it's still valid. Without NOOP, the agent might skip memories it hasn't evaluated, leading to stale entries accumulating without review.

Think of it like a code review: "no changes needed" is different from "I didn't look at this file."
