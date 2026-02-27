# mema-kit — Usage Guide

**A memory protocol kit for Claude Code skills.**

Five built-in skills. Persistent memory across sessions. A protocol for building your own.

---

## Why Memory Matters

Claude Code has a **context window** — everything it "knows" during a conversation. mema-kit works within that window, not outside it.

```
"Load memory"   = Read .mema/ files → contents enter the context window
"Save memory"   = Write .mema/ files → knowledge persists for next session
"What's relevant" = Read index.md (~20 lines) → choose which files to load
```

**Without mema-kit:** every session starts blank. You re-explain everything, or the agent explores your entire codebase (slow, expensive).

**With mema-kit:** the agent reads `index.md`, instantly knows your architecture and recent decisions, loads only the 2-3 files relevant to your task, and gets to work.

Think of it like a developer's notebook — it doesn't give you a bigger brain, it gives you the right information faster.

---

## Quick Start

```bash
npx mema-kit          # install skills to .claude/skills/
claude
> /mema.onboard            # scan project, create .mema/, populate initial memory
> /mema.recall             # next new session: load memory into context
```

`/mema.onboard` reads your package.json, README, directory structure, and representative source files, then writes real content to `architecture.md` and `requirements.md`. Idempotent — safe to re-run.

`/mema.recall` loads your project memory into the current session — use it at the start of every new conversation to restore context instantly.

---

## Recalling Memory: /mema.recall

Every new Claude Code session starts with a blank context. `/mema.recall` fixes the cold-start problem by reading `.mema/` and printing a formatted summary into the conversation.

### Modes

| Mode | Command | What you get |
|------|---------|--------------|
| **Minimal** (default) | `/mema.recall` or `/mema.recall minimal` | Purpose, stack, architecture, current status, memory map |
| **Full** | `/mema.recall full` | Everything in Minimal + recent decisions, lessons, patterns, active context & plans |

### When to use which

| Situation | Mode |
|-----------|------|
| Starting a new session, need quick context | Minimal |
| Picking up a multi-day task | Full |
| Onboarding a teammate to the project | Full |
| Quick check on what decisions exist | Full |
| Daily development work | Minimal |

`/mema.recall` is **read-only** — it never modifies memory files. Safe to run at any time.

---

## Planning Work: /mema.plan

`/mema.plan` takes a high-level goal, explores your codebase, and produces a structured implementation plan with step-by-step specs. Plans are saved to `.mema/task-memory/` so `/mema.implement` can execute them.

### Usage

```
> /mema.plan add user authentication
> /mema.plan refactor the database layer
> /mema.plan add search functionality to the API
```

### What it does

1. **Loads memory** — architecture, requirements, decisions, lessons, patterns
2. **Explores the codebase** — reads relevant source files, understands current patterns
3. **Asks clarifying questions** (1-2 max) if the goal is ambiguous
4. **Produces a plan** — general approach + detailed steps with file paths and specifics
5. **Saves to task-memory** — creates `context.md`, `plan.md`, and `status.md` in `task-memory/[task-name]/`

### Example output

```
## Plan: User Authentication

### Approach
Add JWT-based authentication using the existing Fastify plugin system.
Follows the controller → service → repository pattern already in the codebase.

### Steps (5 total)
1. Create auth database schema and migration
2. Implement auth service (register, login, token refresh)
3. Create auth route handlers
4. Add authentication middleware (Fastify plugin)
5. Add auth integration tests

### Out of Scope
- OAuth/social login
- Role-based access control
- Password reset flow

---
Plan saved to task-memory/user-authentication/
To start implementing: /mema.implement user-authentication
```

### Revising plans

If you run `/mema.plan` for a task that already has a plan, it will offer to revise the existing plan rather than starting from scratch. This makes `/mema.plan` idempotent — safe to re-run.

---

## Implementing Plans: /mema.implement

`/mema.implement` picks up steps from an existing plan, implements them one at a time, verifies the result, and tracks progress. It's designed to give you control — one step at a time by default.

### Usage

```
> /mema.implement user-authentication          # implement next incomplete step
> /mema.implement user-authentication step 3   # implement a specific step
> /mema.implement user-authentication all      # implement all remaining steps
> /mema.implement                              # list active tasks, then pick one
```

### What it does

1. **Loads the plan** — reads `plan.md`, `status.md`, and `context.md` from the task
2. **Picks the next step** — first incomplete step, or the one you specified
3. **Implements the step** — creates/modifies files following the plan's spec
4. **Verifies** — runs tests, checks for errors, validates against the plan
5. **Updates progress** — marks the step complete in `status.md`
6. **Reports** — shows what was done, what's next, overall progress

### Progress tracking

After each step, you'll see a progress summary:

```
## Progress: User Authentication

Step 2/5 complete: Implement auth service

Verified: All tests passing (4 new tests)

### Overall Progress
[====------] 2/5 steps
Next: Step 3 — Create auth route handlers

To continue: /mema.implement user-authentication
```

### Task completion

When all steps are done, `/mema.implement` offers to archive the task:

- Marks `status.md` as complete
- Moves `task-memory/[task-name]/` to `archive/[task-name]/`
- Removes the task from active tasks in `index.md`
- Records any lessons learned and patterns discovered

### Learning from implementation

After each step, `/mema.implement` reflects on the work:
- Unexpected issues become **lessons** in `agent-memory/lessons.md`
- Effective approaches become **patterns** in `agent-memory/patterns.md`
- Decisions made during implementation are saved to `project-memory/decisions/`

This means your memory grows smarter with every implementation cycle.

---

## The plan → implement Workflow

`/mema.plan` and `/mema.implement` form a complete spec-driven development workflow:

```
/mema.plan                              /mema.implement
  │                                    │
  ├─ reads:                            ├─ reads:
  │   architecture                     │   plan.md (from /mema.plan)
  │   requirements                     │   status.md
  │   decisions                        │   context.md
  │   lessons & patterns               │   architecture, decisions
  │                                    │   lessons & patterns
  ├─ writes:                           │
  │   task-memory/[task]/context.md    ├─ writes:
  │   task-memory/[task]/mema.plan.md       │   status.md (mark steps done)
  │   task-memory/[task]/status.md     │   decisions/ (if any)
  │                                    │   lessons.md (if any)
  │                                    │   patterns.md (if any)
  │                                    │   archive/ (on completion)
  ▼                                    ▼
       both flow through .mema/index.md
```

### Full workflow example

```bash
# Session 1: Explore and plan
> /mema.recall                                    # load project context
> /mema.plan add user authentication              # explore codebase, produce plan

# Session 2: Implement (pick up where you left off)
> /mema.recall                                    # load context + active tasks
> /mema.implement user-authentication             # implement step 1
> /mema.implement user-authentication             # implement step 2

# Session 3: Finish up
> /mema.recall
> /mema.implement user-authentication all         # implement remaining steps
# → task archived, lessons saved
```

---

## Extending with Custom Skills

mema-kit ships with five built-in skills (`/mema.onboard`, `/mema.recall`, `/mema.plan`, `/mema.implement`, `/mema.create-skill`). You can create your own skills to extend the workflow.

### Example: Create `/explore`

```
> /mema.create-skill
  Name: explore
  Purpose: Research technical decisions and save findings
  Complexity: standard
```

Creates `.claude/skills/explore/SKILL.md` — a 4-phase skill that loads existing architecture and decisions, helps you research options, then saves new decisions and context to `.mema/`.

**Using it:**

```
> /explore what auth strategy should we use?
```

The agent loads your stack from memory, researches JWT vs sessions vs OAuth, and saves the decision:

```
.mema/project-memory/decisions/2026-02-24-auth-strategy.md
  → "JWT with refresh tokens. Why: stateless, fits our REST API, team has experience."
```

Next session, any skill that loads memory will know this decision exists — including `/mema.plan`, which can incorporate it into implementation plans.

### How custom skills connect with built-ins

```
/explore          /mema.plan             /mema.implement
   │                 │                  │
   ├─ reads:         ├─ reads:          ├─ reads:
   │  architecture   │  architecture    │  plan
   │  requirements   │  decisions       │  lessons
   │                 │  context         │  patterns
   ├─ writes:        ├─ writes:         │
   │  decisions      │  plan            ├─ writes:
   │  context        │  status          │  lessons
   │                 │                  │  patterns
   │                 │                  │  status → archive
   ▼                 ▼                  ▼
        all flow through .mema/index.md
```

Each skill reads what previous skills wrote. The index ties it all together.

> **Tip:** Start every new session with `/mema.recall` to load project context before using other skills. It takes seconds and saves minutes of re-exploration.

### Preview before write

After generating a skill, `/mema.create-skill` shows you the full SKILL.md content for review before writing anything to disk. Reply **APPROVE** to write the file, describe a change to revise a specific section, or **CANCEL** to exit without changes.

### Updating existing skills

Re-running `/mema.create-skill` with an existing skill name won't blindly overwrite. It detects the existing file, shows you its description and section headings, then offers three choices:

1. **Enhance existing** — apply a described change to specific sections, preserving the rest
2. **Overwrite** — start fresh with a new interview and preview
3. **Cancel** — exit without changes

---

## The Memory Protocol

Every skill follows four phases, defined in `_memory-protocol.md`:

**1. AUTO-LOAD** — Read `index.md`, load relevant files only
**2. WORK** — Do the skill's job with loaded context
**3. AUTO-SAVE & CURATE** — For each piece of knowledge: ADD, UPDATE, DELETE, or NOOP
**4. AUTO-INDEX** — Update `index.md` to reflect changes

### Curation Rules

| Action | When |
|--------|------|
| **ADD** | New decision, finding, lesson, or pattern |
| **UPDATE** | Existing knowledge changed (refined reasoning, new example) |
| **DELETE** | Wrong, superseded, or redundant |
| **NOOP** | Still accurate — leave it alone (most files, most of the time) |

Different file types have different curation styles:
- **Decisions** — conservative (rarely delete, even reversed decisions teach)
- **Context** — aggressive (prune dead ends, consolidate overlaps)
- **Plans** — replace (keep final version only)
- **Lessons/Patterns** — consolidate (merge similar entries)

---

## Memory Structure

```
.mema/
├── index.md               # Pointer map — read this first
├── project-memory/        # Architecture, requirements, decisions
│   └── decisions/         # YYYY-MM-DD-short-name.md
├── task-memory/           # Per-task context, plans, status
├── agent-memory/          # Lessons learned, reusable patterns
├── archive/               # Completed tasks
└── _templates/            # File templates
```

The index is a **rebuildable cache** — if it gets out of sync, the next skill rebuilds it from the directory structure. The actual `.mema/` files are the source of truth.

---

## Tips

- **Memory is just markdown.** Open any file to see what the agent knows. Edit directly if something's wrong.
- **`.mema/` is gitignored by default.** To share decisions with your team, uncomment `!.mema/project-memory/` in `.gitignore`.
- **Curate, don't hoard.** The value of memory is its signal-to-noise ratio. Prune aggressively.
- **Any skill can use the protocol.** Use `/mema.create-skill` or manually follow the 4-phase lifecycle.
- **One step at a time.** `/mema.implement` defaults to one step per invocation. This gives you a chance to review each change before continuing.
