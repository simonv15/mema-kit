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
