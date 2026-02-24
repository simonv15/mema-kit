# mema-kit — Usage Guide

**A memory protocol kit for Claude Code skills.**

Install two skills. Get persistent, curated memory across every session. Build new skills that plug into the same memory system.

---

## How Memory Interacts with Claude Code's Context

Before diving in, it helps to understand **what's actually happening** when mema-kit "loads" and "saves" memory.

**There's no magic.** Claude Code has a **context window** — everything it "knows" during a conversation. mema-kit works **within** that context window, not outside it.

```
"Load memory"  = Agent uses the Read tool to read .mema/ files
                  → file contents enter the context window

"Save memory"   = Agent uses the Write tool to write .mema/ files
                  → knowledge persists on disk for the next session

"Decide what's   = Agent reads the short index.md (~20 lines),
 relevant"        then chooses which files to Read based on your request
```

### Why This Matters

**Without mema-kit:** Every new session starts blank. The agent knows nothing about your project. You re-explain everything, or the agent explores your entire codebase (slow, expensive, loads irrelevant files into context).

**With mema-kit:** The agent reads `index.md` (small file), instantly knows your architecture, recent decisions, and active tasks. It reads only the 2-3 files relevant to your current task — then gets to work with the right context already loaded.

```
Without kit:                          With kit:
┌──────────────────────┐              ┌──────────────────────┐
│ Context Window        │              │ Context Window        │
│                       │              │                       │
│ CLAUDE.md             │              │ CLAUDE.md             │
│ Your message          │              │ SKILL.md instructions │
│ ...nothing else.      │              │ Your message          │
│                       │              │ index.md (auto-read)  │
│ Agent must explore    │              │ architecture.md       │
│ entire codebase       │              │ relevant decision.md  │
│ from scratch.         │              │                       │
│ ❌ Slow, expensive    │              │ Agent starts work     │
│ ❌ Loads irrelevant   │              │ with RIGHT context.   │
│    files into context │              │ ✓ Fast, token-lean   │
└──────────────────────┘              └──────────────────────┘
```

**Think of it like a developer's notebook.** The notebook doesn't give you a bigger brain — it gives you the right information faster. mema-kit doesn't expand Claude Code's context window. It **uses the context window more efficiently** by loading curated, relevant knowledge instead of raw codebase exploration.

---

## Quick Setup

```bash
# 1. Install mema-kit skills into your project
npx mema-kit

# 2. Open your project in Claude Code
cd your-project
claude

# 3. Bootstrap memory (scans project, creates .mema/, populates initial knowledge)
/onboard
```

After setup, your project looks like this:

```
your-project/
├── .claude/skills/          # mema-kit skills (2 commands) — committed to git
│   ├── _memory-protocol.md  # Shared curation rules
│   ├── onboard/SKILL.md     # /onboard — bootstrap memory
│   └── create-skill/SKILL.md # /create-skill — generate new skills
├── .mema/                   # Memory system (auto-managed) — gitignored
│   ├── _templates/          # Templates for memory files
│   ├── index.md             # Memory map — agent reads this first
│   ├── project-memory/      # Tech stack, requirements, decisions
│   ├── task-memory/         # Per-task context, plans, decisions
│   ├── agent-memory/        # Lessons learned, reusable patterns
│   └── archive/             # Completed task memories
├── .gitignore               # .mema/ gitignored by /onboard
└── CLAUDE.md                # Memory system conventions
```

---

## Using /onboard

Run once per project. `/onboard` doesn't just create empty directories — it actively scans your project and populates memory with real content.

```
You:  /onboard
```

**What happens:**
1. Creates `.mema/` directory with all subdirectories and templates
2. Scans your project: reads package.json, README, directory structure, and representative source files
3. Populates `architecture.md` with your actual tech stack, project structure, and build commands
4. Populates `requirements.md` with discovered project purpose and constraints
5. Creates starter `lessons.md` and `patterns.md` (with any gotchas found during scanning)
6. Builds `index.md` pointing to all populated files
7. Adds memory system section to CLAUDE.md
8. Adds `.mema/` to `.gitignore`

**Example output:**

```
mema-kit initialized! Here's what was set up:

✓ .mema/ directory structure (memory system)
✓ Memory templates in .mema/_templates/
✓ CLAUDE.md updated with memory system conventions
✓ .gitignore updated to exclude .mema/

Project scan results:
- TypeScript 5.x + Fastify 4.x + PostgreSQL via Drizzle ORM
- REST API with controller → service → repository layers
- 4 source directories mapped (src/, tests/, drizzle/, config/)
- Vitest for testing, pnpm for package management

Memory populated:
- architecture.md — Node.js + Fastify + PostgreSQL + Drizzle stack
- requirements.md — Task management REST API with JWT auth
- lessons.md — 0 initial lessons
- patterns.md — 0 initial patterns
```

Idempotent — safe to re-run. On subsequent runs, verifies and repairs rather than overwriting.

---

## Using /create-skill

Generate a new memory-aware skill for your project.

```
You:  /create-skill
```

The agent asks 2-3 quick questions, then generates a complete SKILL.md with the right memory lifecycle.

### Worked Example: Creating a /review Skill

```
You:  /create-skill

Agent: What should this skill be called?
You:   review

Agent: What does /review do?
You:   Reviews code changes for quality, consistency with project patterns, and potential issues.

Agent: Memory needs — should /review read memory, write memory, or both?
       Default is both (read architecture + patterns, save new lessons).
You:   both is good

Agent: Complexity level?
       - Simple (3 phases) — read-only, no memory writes
       - Standard (4 phases) — read + write memory [default]
       - Advanced (4 phases + task management)
You:   standard
```

**Result:** `.claude/skills/review/SKILL.md` is created with:

```markdown
---
description: Reviews code changes for quality, consistency with project patterns, and potential issues.
---

# /review — Code Review

You are executing the /review skill. Follow these steps carefully.

## Phase 1: AUTO-LOAD
1. Read `.mema/index.md` to understand current project state
2. If `index.md` is missing or empty, run the Rebuild Procedure from `_memory-protocol.md`
3. Based on the user's request, identify and read relevant memory files
4. Read only what's needed — don't load everything

**Relevant memory for this skill:**
- `project-memory/architecture.md` — for technical context
- `project-memory/decisions/` — for past decisions related to this work
- `agent-memory/lessons.md` — for mistakes to avoid
- `agent-memory/patterns.md` — for reusable approaches

## Phase 2: WORK
[Review logic — check code against architecture, patterns, lessons...]

## Phase 3: AUTO-SAVE & CURATE
[Save any new lessons or patterns discovered during review...]

## Phase 4: AUTO-INDEX
[Update index.md to reflect changes...]
```

Now you can use it:

```
You:  /review check the auth middleware changes
```

The agent loads your architecture, past decisions, and known patterns — then reviews the code with that full context.

---

## The Memory Protocol in Depth

Every memory-aware skill follows four phases. This is defined in `_memory-protocol.md` and shared across all skills.

### Phase 1: AUTO-LOAD

1. Read `.mema/index.md` — the pointer map to all memory files
2. Scan each entry's one-line summary for relevance to the current task
3. Read only the relevant files into context
4. If `index.md` is missing, rebuild it from the `.mema/` directory structure

**Rule:** When in doubt about relevance, load it. When clearly unrelated, skip it.

### Phase 2: WORK

Execute the skill's core purpose with loaded context. This phase varies per skill.

### Phase 3: AUTO-SAVE & CURATE

For every piece of knowledge produced, decide one of four actions:

| Action | When to Use |
|--------|------------|
| **ADD** | New knowledge that doesn't exist yet (new decision, finding, lesson, pattern) |
| **UPDATE** | Existing knowledge that has changed (refined reasoning, adjusted plan, new example) |
| **DELETE** | Knowledge that is wrong, superseded, or irrelevant (dead-end exploration, duplicate info) |
| **NOOP** | Still accurate and relevant — leave unchanged (most files, most of the time) |

#### Per-File Curation Rules

- **decision.md** — Conservative. Rarely delete. Even reversed decisions teach why something didn't work.
- **context.md** — Aggressive. Prune dead-end explorations. Consolidate overlapping findings.
- **plan.md** — Replace. Keep the final version only. Update during implementation.
- **lessons.md / patterns.md** — Consolidation. Merge similar entries. Add examples to existing ones.

### Phase 4: AUTO-INDEX

Update `.mema/index.md` to reflect all changes. This is mandatory — never skip it.

1. Add entries for new files
2. Update summaries for modified files
3. Remove entries for deleted files
4. Update the `**Updated:**` date

---

## Memory Structure Reference

```
.mema/
├── _templates/                        # File templates (copied by /onboard)
│   ├── decision.md, context.md, plan.md, lessons.md, patterns.md, status.md
│
├── index.md                           # Pointer map — read this first
│
├── project-memory/                    # Project-wide knowledge
│   ├── architecture.md                # Tech stack, structure, patterns
│   ├── requirements.md                # Purpose, constraints, requirements
│   └── decisions/                     # Individual decision records
│       ├── 2026-02-23-tech-stack.md
│       └── 2026-02-23-auth-jwt.md
│
├── task-memory/                       # Per-task working memory
│   └── api-setup/
│       ├── context.md                 # Research findings
│       ├── plan.md                    # Implementation plan
│       └── status.md                  # Progress tracking
│
├── agent-memory/                      # Agent-learned knowledge
│   ├── lessons.md                     # Mistakes and surprises
│   └── patterns.md                    # Reusable approaches
│
└── archive/                           # Completed tasks (preserved for reference)
    └── api-setup/
```

### Metadata Format

Every memory file includes in-body metadata (not YAML frontmatter):

```
**Status:** active | **Updated:** 2026-02-23
```

Status values: `active` (current), `complete` (finished but useful), `archived` (moved to archive/).

### Index Format

```markdown
# Memory Index

**Updated:** 2026-02-23

## Active Tasks
- `task-memory/api-setup/` — Setting up REST API with Fastify (plan ready, implementing)

## Project Knowledge
- `project-memory/architecture.md` — Node.js + Fastify + PostgreSQL + Drizzle stack
- `project-memory/requirements.md` — Core requirements and constraints

## Recent Decisions
- `project-memory/decisions/2026-02-23-tech-stack.md` — Chose Fastify + PostgreSQL + Drizzle

## Agent Lessons
- `agent-memory/lessons.md` — 3 lessons recorded
- `agent-memory/patterns.md` — 2 patterns recorded
```

The index is a **rebuildable cache** — convenient but never the only source of truth. The actual files in `.mema/` are the source of truth.

---

## Tips

- **Memory is just markdown.** Open any `.mema/` file to see what the agent knows. Edit directly if something's wrong.
- **index.md is self-healing.** If it gets out of sync, the next skill will rebuild it from the `.mema/` directory structure.
- **Decisions include "why."** Every decision file explains the reasoning — so future-you (or future-agent) understands the context, not just the choice.
- **`.mema/` is gitignored by default.** It's your local agent workspace. To share project decisions with your team, uncomment `!.mema/project-memory/` in `.gitignore`.
- **Any skill can use the protocol.** The memory protocol isn't limited to the two built-in skills. Use `/create-skill` to generate new ones, or manually follow the 4-phase lifecycle in any SKILL.md.
- **Curate, don't hoard.** The value of memory is in its signal-to-noise ratio. Aggressive pruning of dead-end explorations and consolidation of similar lessons keeps memory useful.
