# Praxis-kit — Usage Guide

**A spec-driven development kit for Claude Code with intelligent memory management.**

You run slash commands. The agent handles the rest — loading context, saving knowledge, pruning noise.

---

## How Memory Interacts with Claude Code's Context

Before diving in, it helps to understand **what's actually happening** when Praxis-kit "loads" and "saves" memory.

**There's no magic.** Claude Code has a **context window** — everything it "knows" during a conversation. Praxis-kit works **within** that context window, not outside it.

```
"Load memory"  = Agent uses the Read tool to read .praxis/ files
                  → file contents enter the context window

"Save memory"   = Agent uses the Write tool to write .praxis/ files
                  → knowledge persists on disk for the next session

"Decide what's   = Agent reads the short index.md (~20 lines),
 relevant"        then chooses which files to Read based on your request
```

### Why This Matters

**Without Praxis-kit:** Every new session starts blank. The agent knows nothing about your project. You re-explain everything, or the agent explores your entire codebase (slow, expensive, loads irrelevant files into context).

**With Praxis-kit:** The agent reads `index.md` (small file), instantly knows your architecture, recent decisions, and active tasks. It reads only the 2-3 files relevant to your current task — then gets to work with the right context already loaded.

```
Without kit:                          With kit:
┌──────────────────────┐              ┌──────────────────────┐
│ Context Window        │              │ Context Window        │
│                       │              │                       │
│ CLAUDE.md             │              │ CLAUDE.md + About Me  │
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

**Think of it like a developer's notebook.** The notebook doesn't give you a bigger brain — it gives you the right information faster. Praxis-kit doesn't expand Claude Code's context window. It **uses the context window more efficiently** by loading curated, relevant knowledge instead of raw codebase exploration.

---

## Quick Setup

```bash
# 1. Install Praxis-kit skills into your project
npx praxis-kit

# 2. Open your project in Claude Code
cd your-project
claude

# 3. Initialize the project (creates .praxis/, updates CLAUDE.md)
/kickoff

# 4. Set up your profile
/profile
```

**Alternative installs** (all end with "run `/kickoff`"):
```bash
npx skills add github/praxis-kit    # Via Vercel Skills (37+ agents)
# or manually:
cp -r praxis-kit/skills/ your-project/.claude/skills/
```

After setup, your project looks like this:

```
your-project/
├── .claude/skills/          # Praxis-kit skills (6 commands) — committed to git
│   ├── _memory-protocol.md  # Shared curation rules
│   ├── kickoff/SKILL.md
│   ├── profile/SKILL.md
│   ├── explore/SKILL.md
│   ├── plan-docs/SKILL.md
│   ├── gen-test/SKILL.md
│   └── implement/SKILL.md
├── .praxis/                 # Memory system (auto-managed) — gitignored
│   ├── _templates/          # Templates for memory files
│   ├── index.md             # Memory map — agent reads this first
│   ├── project-memory/      # Tech stack, requirements, decisions
│   ├── task-memory/         # Per-task context, plans, decisions
│   ├── agent-memory/        # Lessons learned, reusable patterns
│   └── archive/             # Completed task memories
├── .gitignore               # .praxis/ gitignored by /kickoff
└── CLAUDE.md                # Your profile + workflow conventions
```

---

## The Workflow

```
/kickoff → /profile → /explore → /plan-docs → /gen-test → /implement
                         ↑                                      │
                         └──────── loop as needed ──────────────┘
```

---

## Example: Building a Task Manager API

Let's walk through building a feature from start to finish.

### Step 1: `/kickoff`

Run once per project. Creates the `.praxis/` memory structure and sets up your project for spec-driven development. Idempotent — safe to re-run if something's missing.

```
You:  /kickoff
```

**What happens:**
- Creates `.praxis/` directory with all subdirectories and templates
- Adds spec-driven workflow section to CLAUDE.md
- Adds `.praxis/` to `.gitignore` (developer-local memory, not committed)
- Initializes empty `index.md`, `architecture.md`, `requirements.md`
- If `.praxis/` already exists, verifies and repairs rather than overwriting

**Result:** Your project is ready for spec-driven development.

---

### Step 2: `/profile`

Tell the agent who you are. Run once, re-run anytime to update.

```
You:  /profile
```

The agent asks about your skill level, preferences, and working style, then writes it to CLAUDE.md:

```markdown
# About Me
I'm a mid-level backend engineer. I prefer TypeScript, clean
architecture patterns, and well-commented code. Explain trade-offs
when making architectural decisions.
```

**Why this matters:** Every future conversation starts with Claude reading CLAUDE.md — so the agent always knows how to communicate with you.

---

### Step 3: `/explore`

Research and clarify anything — technical decisions, frameworks, business logic.

```
You:  /explore what tech stack should I use for a task manager REST API?
```

**What the agent does automatically:**
1. Reads `index.md` → sees the project is new (no prior context)
2. Researches: Node.js vs Python, Express vs Fastify, PostgreSQL vs SQLite, ORM options
3. Makes a recommendation with trade-offs
4. **Auto-saves to `.praxis/`:**

```
.praxis/
├── index.md                                          # Updated with new entries
├── project-memory/
│   ├── architecture.md                               # Updated: "Node.js + Fastify + PostgreSQL + Drizzle ORM"
│   └── decisions/
│       └── 2026-02-23-tech-stack.md                  # Decision + reasoning
└── task-memory/
    └── api-setup/
        └── context.md                                # Research findings (curated)
```

What gets **saved**: "Chose Fastify over Express. Why: 2x faster, built-in schema validation, better TypeScript support."

What gets **pruned**: The back-and-forth comparison discussion, rejected options that don't matter anymore.

---

You can run `/explore` multiple times for different topics:

```
You:  /explore how should we handle authentication?
```

The agent now **auto-loads** the previous tech stack decision (because it's relevant to auth) and researches auth options *with that context*. Saves a new decision to `.praxis/project-memory/decisions/2026-02-23-auth-jwt.md`.

---

### Step 4: `/plan-docs`

Generate implementation-ready plans from your exploration findings.

```
You:  /plan-docs plan the task CRUD endpoints
```

**What the agent does automatically:**
1. Reads `index.md` → finds architecture, tech stack decisions, auth decision
2. Loads all relevant context from previous `/explore` runs
3. Generates two artifacts:
   - **General plan**: High-level approach, endpoint design, data model
   - **Detailed plan**: Step-by-step tasks with specific files, functions, and dependencies

**Auto-saves to:**
```
.praxis/task-memory/task-crud/
├── context.md          # (from earlier /explore, if any)
└── plan.md             # The implementation plan
```

**Example output in `plan.md`:**
```markdown
## General Plan
REST API with 5 endpoints: POST/GET/GET:id/PUT/DELETE for tasks.
PostgreSQL with Drizzle ORM. JWT auth middleware on all routes.

## Detailed Plan
1. Create database schema: src/db/schema.ts (tasks table)
2. Create Drizzle migration: drizzle/0001_create_tasks.sql
3. Create route handlers: src/routes/tasks.ts
4. Add auth middleware: src/middleware/auth.ts
5. Add input validation: src/schemas/task.schema.ts
6. Register routes: src/app.ts
```

---

### Step 5: `/gen-test`

Generate test cases following TDD — tests first, code second.

```
You:  /gen-test generate tests for the task CRUD endpoints
```

**What the agent does automatically:**
1. Reads `task-memory/task-crud/plan.md` for implementation details
2. Generates test files in your codebase (not in `.praxis/`):

```
src/
└── tests/
    ├── tasks.test.ts         # Unit tests for CRUD logic
    └── tasks.integration.ts  # API endpoint tests
```

Tests are written to **fail** — because the code doesn't exist yet. That's TDD.

---

### Step 6: `/implement`

Implement the code, following the plan, making tests pass.

```
You:  /implement implement the task CRUD endpoints
```

**What the agent does automatically:**
1. Reads `task-memory/task-crud/plan.md` for the step-by-step plan
2. Reads `agent-memory/lessons.md` for past mistakes to avoid
3. Creates a todo list from the plan:
   ```
   [ ] Create database schema
   [ ] Create Drizzle migration
   [ ] Create route handlers
   [ ] Add auth middleware
   [ ] Add input validation
   [ ] Register routes
   ```
4. Executes each task in order, running tests after each step
5. When done, **auto-saves**:
   - `agent-memory/lessons.md` → "Drizzle needs explicit type casting for PostgreSQL enums"
   - `agent-memory/patterns.md` → "Fastify route pattern: schema + handler + registration"
   - `task-memory/task-crud/status.md` → marked complete
6. **Auto-archives**: moves `task-memory/task-crud/` to `archive/task-crud/`
7. **Updates `index.md`**: task removed from "Active Tasks"

---

## How Memory Builds Over Time

After the example above, your `.praxis/` looks like:

```
.praxis/
├── index.md
│   # Active Tasks: (none — task-crud is archived)
│   # Project Knowledge: architecture.md, requirements.md
│   # Recent Decisions: tech-stack, auth-jwt
│   # Agent Lessons: 2 lessons recorded
│
├── project-memory/
│   ├── architecture.md          # Node.js + Fastify + PostgreSQL + Drizzle
│   ├── requirements.md
│   └── decisions/
│       ├── 2026-02-23-tech-stack.md
│       └── 2026-02-23-auth-jwt.md
│
├── agent-memory/
│   ├── lessons.md               # "Drizzle needs explicit type casting..."
│   └── patterns.md              # "Fastify route pattern..."
│
└── archive/
    └── task-crud/               # Completed task (preserved for reference)
        ├── context.md
        ├── plan.md
        └── status.md
```

Now when you start your **next task**:

```
You:  /explore how should we add real-time notifications?
```

The agent reads `index.md` and **automatically knows**:
- Your stack is Node.js + Fastify + PostgreSQL
- You're using JWT auth
- Past lesson: Drizzle needs explicit type casting for enums

It loads only what's relevant and starts exploring **with full project context** — without you having to explain anything.

---

## Command Reference

| Command | Purpose | Memory Effect |
|---------|---------|---------------|
| `/kickoff` | Initialize project + `.praxis/` structure | Creates `.praxis/`, writes to CLAUDE.md |
| `/profile` | Set your skill level, preferences, style | Writes `# About Me` to CLAUDE.md |
| `/explore` | Research anything (tech, business, etc.) | Reads relevant memory → saves findings + decisions |
| `/plan-docs` | Generate implementation-ready plans | Reads exploration context → saves plans |
| `/gen-test` | Generate TDD test cases | Reads plans → writes tests to codebase |
| `/implement` | Implement code + run tests | Reads plans + lessons → saves lessons + archives task |

---

## Tips

- **You can skip steps.** Don't need to explore? Jump straight to `/plan-docs`. Each skill checks prerequisites and offers to create what's missing — it guides, not gates.
- **You can loop back.** After `/plan-docs`, realized you need more research? Run `/explore` again. Memory accumulates.
- **Memory is just markdown.** Open any `.praxis/` file to see what the agent knows. Edit it directly if something's wrong.
- **index.md is self-healing.** If it gets out of sync, the next skill will rebuild it from the `.praxis/` directory structure.
- **Decisions include "why."** Every decision file explains the reasoning — so future-you (or future-agent) understands the context, not just the choice.
- **`.praxis/` is gitignored by default.** It's your local agent workspace. To share project decisions with your team, uncomment `!.praxis/project-memory/` in `.gitignore`.
