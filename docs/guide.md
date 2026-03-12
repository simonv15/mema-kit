# mema-kit — Usage Guide

**A full AI-assisted development lifecycle kit for Claude Code.**

Twelve built-in skills. Persistent memory across sessions. From vague idea to shipped code, without switching tools.

---

## Why Memory Matters

Claude Code has a **context window** — everything it "knows" during a conversation. mema-kit works within that window, not outside it.

```
"Load memory"     = Read .mema/ files → contents enter the context window
"Save memory"     = Write .mema/ files → knowledge persists for next session
"What's relevant" = Read index.md (~20 lines) → choose which files to load
```

**Without mema-kit:** every session starts blank. You re-explain everything, or the agent explores your entire codebase (slow, expensive).

**With mema-kit:** the agent reads `index.md`, instantly knows your architecture, active features, and recent decisions — and gets to work.

---

## The Two Starting Points

### Starting from a vague idea (new project)

```bash
npx mema-kit          # install skills to .claude/skills/
claude
> /mm.seed          # capture your idea
> /mm.clarify       # refine with Q&A
> /mm.research      # find what exists (web search)
> /mm.challenge     # stress-test assumptions
> /mm.roadmap       # create feature list
> /mm.specify 001   # spec the first feature
> /mm.plan 001      # technical design
> /mm.tasks 001     # generate task list
> /mm.implement 001 # build it, one task at a time
```

### Starting from an existing project

```bash
npx mema-kit          # install skills
claude
> /mm.onboard       # scan project, create .mema/, populate memory
> /mm.specify       # spec a new feature
> /mm.plan          # technical design
> /mm.tasks         # generate task list
> /mm.implement     # build it
```

---

## Discovery Skills (New Projects)

### `/mm.seed [optional: inline idea]`

Captures your raw idea exactly as described — no editing, no judgment. Use stream of consciousness, bullet points, half-formed thoughts. Saves to `.mema/product/seed.md`.

```
> /mm.seed I want to build a tool that helps remote teams do async standups
```

### `/mm.clarify`

Asks 3–5 targeted questions to turn a seed into a crisp problem statement: who is it for, what problem does it solve, what's in scope, what's the motivation. Saves to `.mema/product/clarify.md`.

### `/mm.research [optional: focus area]`

Uses web search to investigate existing solutions, market context, and technical options. Saves findings with source links to `.mema/product/research.md`. Add a focus area to narrow the search:

```
> /mm.research competitors
> /mm.research tech stack options
```

### `/mm.challenge`

Plays devil's advocate. Identifies risky assumptions, builds a risk register with severity/likelihood/mitigation, and surfaces blind spots. Critical risks are flagged explicitly. Saves to `.mema/product/challenge.md`.

### `/mm.roadmap`

Synthesizes all discovery outputs into a prioritized feature list with a problem statement and MVP scope. Creates numbered feature directories (`features/001-name/`, `features/002-name/`, etc.) ready for specification. Saves to `.mema/product/roadmap.md`.

---

## Feature Workflow Skills

These work on any project — with or without the discovery phase.

### `/mm.specify [feature number or description]`

Creates the "what and why" spec for a feature. If a roadmap exists, presents the feature list and asks which to specify. Otherwise, takes a description directly. Saves to `.mema/features/NNN-name/spec.md`.

```
> /mm.specify 001
> /mm.specify "add user authentication"
```

### `/mm.plan [feature]`

Creates the technical implementation design: approach, file changes, key decisions. Reads the feature spec and explores the existing codebase to ensure the plan fits established patterns. Saves to `.mema/features/NNN-name/plan.md`.

### `/mm.tasks [feature]`

Generates an ordered, checkable task list from the plan. Each task starts with a verb and includes a file path — specific enough to execute without additional context. Saves to `.mema/features/NNN-name/tasks.md`.

### `/mm.implement [feature] [optional: step N | all]`

Executes one task at a time by default. Reads the task list, implements the next incomplete task, verifies it, and updates progress. When all tasks are done, offers to archive the feature.

```
> /mm.implement 001         # implement next task
> /mm.implement 001 step 3  # implement a specific task
> /mm.implement 001 all     # implement all remaining tasks
```

---

## Utility Skills

### `/mm.onboard`

Bootstraps memory for an existing project. Scans the codebase (package.json, README, source files) and populates `.mema/` with real content. Generates or updates `CLAUDE.md`. Safe to re-run — updates stale content, leaves accurate content untouched.

For projects with the old mema-kit structure (`project-memory/`, `agent-memory/`, `task-memory/`): automatically migrates to the new layout on re-run.

### `/mm.recall [optional: full]`

Loads project memory into the current session. Shows active features and their status at the top — the most important context for a returning developer. Use at the start of every session.

```
> /mm.recall        # minimal — active features + project identity + next action
> /mm.recall full   # everything + decisions + lessons + product discovery
```

### `/mm.create-skill`

Generates a new memory-aware Claude Code skill. Interviews you on the skill's name, purpose, and complexity level, generates a SKILL.md with proper memory lifecycle phases, shows you a preview before writing, and offers to enhance existing skills if you re-run with an existing skill name.

---

## The Full Lifecycle in One View

```
vague idea
    │
    ├── /mm.seed       → .mema/product/seed.md
    ├── /mm.clarify    → .mema/product/clarify.md
    ├── /mm.research   → .mema/product/research.md
    ├── /mm.challenge  → .mema/product/challenge.md
    └── /mm.roadmap    → .mema/product/roadmap.md
                                  │
                          pick a feature
                                  │
    ├── /mm.specify    → .mema/features/NNN-name/spec.md
    ├── /mm.plan       → .mema/features/NNN-name/plan.md
    ├── /mm.tasks      → .mema/features/NNN-name/tasks.md
    └── /mm.implement  → source code + .mema/features/NNN-name/status.md
                                  │
                         /mm.recall (next session)
```

Every skill reads what previous skills wrote. The index ties it all together.

---

## Memory Structure

```
.mema/
├── index.md               # Pointer map — read this first
├── product/               # Discovery phase outputs
│   ├── seed.md            # Raw idea
│   ├── clarify.md         # Refined intent
│   ├── research.md        # Competitor and market findings
│   ├── challenge.md       # Risk register
│   └── roadmap.md         # Prioritized feature list
├── features/              # One directory per feature
│   └── 001-feature-name/
│       ├── spec.md        # What + why
│       ├── plan.md        # Technical design
│       ├── tasks.md       # Implementation task list
│       └── status.md      # Progress tracking
├── project/               # Stable project knowledge
│   ├── architecture.md
│   ├── requirements.md
│   ├── structure.md       # Annotated directory tree
│   └── decisions/
├── agent/                 # Cross-session knowledge
│   ├── lessons.md
│   └── patterns.md
└── archive/               # Completed features
```

The index is a **rebuildable cache** — if it gets out of sync, any skill rebuilds it from the directory structure.

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
| **UPDATE** | Existing knowledge changed |
| **DELETE** | Wrong, superseded, or redundant |
| **NOOP** | Still accurate — leave it alone (most files, most of the time) |

---

## Tips

- **Memory is just markdown.** Open any file to see what the agent knows. Edit directly if something's wrong.
- **`.mema/` is gitignored by default.** To share decisions with your team, uncomment `!.mema/project/` in `.gitignore`.
- **Discovery is optional.** You can jump straight to `/mm.specify` if you already know what to build.
- **One task at a time.** `/mm.implement` defaults to one step per invocation — review each change before continuing.
- **Curate, don't hoard.** The value of memory is signal-to-noise ratio. Prune aggressively.
- **Start every session with `/mm.recall`.** It takes seconds and saves minutes of re-explanation.
