# mema-kit — Usage Guide

**A memory protocol kit for Claude Code skills.**

Three built-in skills. Persistent memory across sessions. A protocol for building your own.

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
> /onboard            # scan project, create .mema/, populate initial memory
> /recall             # next new session: load memory into context
```

`/onboard` reads your package.json, README, directory structure, and representative source files, then writes real content to `architecture.md` and `requirements.md`. Idempotent — safe to re-run.

`/recall` loads your project memory into the current session — use it at the start of every new conversation to restore context instantly.

---

## Recalling Memory: /recall

Every new Claude Code session starts with a blank context. `/recall` fixes the cold-start problem by reading `.mema/` and printing a formatted summary into the conversation.

### Modes

| Mode | Command | What you get |
|------|---------|--------------|
| **Minimal** (default) | `/recall` or `/recall minimal` | Purpose, stack, architecture, current status, memory map |
| **Full** | `/recall full` | Everything in Minimal + recent decisions, lessons, patterns, active context & plans |

### When to use which

| Situation | Mode |
|-----------|------|
| Starting a new session, need quick context | Minimal |
| Picking up a multi-day task | Full |
| Onboarding a teammate to the project | Full |
| Quick check on what decisions exist | Full |
| Daily development work | Minimal |

`/recall` is **read-only** — it never modifies memory files. Safe to run at any time.

---

## Example: Building a Spec-Driven Dev Workflow

mema-kit ships with `/onboard` and `/create-skill`. Everything else you build yourself. Here's how to create a 3-skill workflow: **explore → plan → implement**.

### Step 1: Create `/explore`

```
> /create-skill
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

Next session, any skill that loads memory will know this decision exists.

### Step 2: Create `/plan`

```
> /create-skill
  Name: plan
  Purpose: Generate implementation plans from exploration findings
  Complexity: standard
```

**Using it:**

```
> /plan plan the user auth endpoints
```

The agent loads the auth decision from Step 1, architecture, and requirements — then writes a step-by-step plan to `.mema/task-memory/user-auth/plan.md`.

### Step 3: Create `/implement`

```
> /create-skill
  Name: implement
  Purpose: Implement code following a plan, run tests, save lessons
  Complexity: advanced
```

Advanced complexity adds task tracking and archiving. When the task is done, the agent moves task files to `archive/` and records any lessons learned.

**Using it:**

```
> /implement implement user auth endpoints
```

The agent loads the plan, architecture, and past lessons. It implements each step, runs tests, and when done:

- Saves "Drizzle needs explicit type casting for enums" to `lessons.md`
- Archives `task-memory/user-auth/` to `archive/user-auth/`
- Updates `index.md`

### How Memory Flows Between Skills

```
/explore          /plan             /implement
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

> **Tip:** Start every new session with `/recall` to load project context before using other skills. It takes seconds and saves minutes of re-exploration.

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
- **Any skill can use the protocol.** Use `/create-skill` or manually follow the 4-phase lifecycle.
