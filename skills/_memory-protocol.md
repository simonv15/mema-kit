# Memory Protocol

This document defines how you manage memory in `.mema/`. Every skill that reads or writes memory must follow these rules.

## The Memory Lifecycle

Every skill execution follows four phases:

### Phase 1: AUTO-LOAD
1. Read `.mema/index.md` to understand current project state
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
Update `.mema/index.md` to reflect all changes made in Phase 3. This is **mandatory** — never skip it.

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

### product/ files — Discovery phase outputs (seed, clarify, research, challenge, roadmap)
- **Overwrite on re-run.** Each file represents the current state of understanding. Re-running a discovery skill replaces stale content with fresh analysis.
- **NOOP** if the file is recent and the idea hasn't changed.
- `roadmap.md` is special: UPDATE to add new features, but never delete existing feature entries — features with directories already created should be marked, not removed.

### features/NNN-name/ files — Feature lifecycle files (spec, plan, tasks, status)
- `spec.md` — **UPDATE** when requirements change; never delete a spec that has a corresponding plan.
- `plan.md` — **Replace curation**: keep final version only; overwrite on re-run.
- `tasks.md` — **Replace curation**: regenerate when plan changes; warn if tasks are partially complete.
- `status.md` — **UPDATE** continuously during implementation; never delete.

### project/decisions/ — Conservative curation
- **Rarely delete.** Decisions are historical record. Even reversed decisions teach future sessions why something didn't work.
- **UPDATE** when the decision is refined, expanded, or its status changes.
- **ADD** reasoning if the original entry lacks a "why."
- Only **DELETE** if the decision was recorded in error (wrong project, duplicate entry).

### project/architecture.md and project/requirements.md — Replace curation
- **UPDATE** when the stack or requirements change.
- Keep current state only — these are reference documents, not history logs.

### project/structure.md — Replace curation
- **UPDATE** when directories or key files are added, renamed, or removed.
- Keep current state only — this is a navigation reference, not a history log.
- **NOOP** if no structural change occurred in this session.
- Never delete — if the project structure is unknown, leave the file with a minimal tree rather than removing it.

### agent/lessons.md and agent/patterns.md — Consolidation curation
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
- `archived` — Moved to archive/ (set by the completing skill on task completion)

Place metadata on the line immediately after the title heading.

## index.md Format

The index is a structured pointer map with four sections:

```
# Memory Index

**Updated:** 2026-02-27

## Active Features
- `features/001-user-auth/` — JWT authentication for API (in-progress, step 2/5)
- `features/002-search/` — Full-text search across posts (pending)

## Product Discovery
- `product/seed.md` — Async standup tool for remote teams
- `product/roadmap.md` — 6 features defined, 1 in progress

## Project Knowledge
- `project/architecture.md` — Node.js + Fastify + PostgreSQL + Drizzle stack
- `project/requirements.md` — Core requirements and constraints
- `project/decisions/2026-02-27-auth-jwt.md` — JWT with refresh tokens for auth

## Agent Knowledge
- `agent/lessons.md` — 4 lessons recorded
- `agent/patterns.md` — 3 patterns recorded
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
1. List all directories in `.mema/`: `product/`, `features/`, `project/`, `agent/`, `archive/`
2. For each directory, list all `.md` files
3. Read the first 3 lines of each file to get title and metadata
4. Generate index entries in the format above
5. Write the rebuilt `index.md`

This procedure makes the index a **rebuildable cache** — it's convenient but never the only copy of truth. The actual files in `.mema/` are the source of truth.
