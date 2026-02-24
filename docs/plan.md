# Project Plan: Praxis-kit

**Session:** ai-agent-dev-kit
**Date:** 2026-02-23

---

## Problem Statement & Value Proposition

**Problem:** AI coding agents (Claude Code, Codex, etc.) lack a structured development workflow. Developers either jump straight into coding without exploration/planning, or manually manage context — choosing what files and background to feed the agent. This leads to wasted tokens, wrong assumptions, and inconsistent results.

**Value Proposition:** **Praxis-kit** is a Claude Code skill kit that enforces a spec-driven **Explore → Plan → Code** workflow with **intelligent memory management**. The agent automatically saves useful knowledge (specs, decisions with reasoning, key findings) and prunes unnecessary content — then autonomously loads only the relevant memories for each task. Developers get structured development discipline without manual context curation.

**Name origin:** *Praxis* means "the practical application of theory" — turning specs into working code. That's exactly what this kit does.

**Unique differentiator:** Human-readable, agent-portable markdown memory with structured curation (ADD/UPDATE/DELETE/NOOP) — not summaries, not compression, but curated knowledge. Optionally git-trackable for team knowledge sharing.

---

## Target Audience

| Persona | Description | Primary Need |
|---------|-------------|-------------|
| **Solo AI Engineer** | Uses Claude Code daily on personal/side projects. Comfortable with CLI. Wants consistent results without babysitting the agent. | Structured workflow + automatic context management |
| **AI-Augmented Developer** | Software engineer adopting AI coding tools. Wants guardrails to avoid the "agent goes off the rails" problem. | Spec-driven discipline that prevents the agent from making wrong assumptions |
| **TDD Practitioner** | Developer who follows test-driven development and wants AI to fit into that workflow. | TDD integration where tests are generated before implementation |

---

## Feature List

### Must-Have (MVP — Milestone 1-3)

- [ ] **Memory Protocol** (`_memory-protocol.md`) — Shared instructions for ADD/UPDATE/DELETE/NOOP curation across all skills, with concrete exemplars. Lives in `.claude/skills/` alongside SKILL.md files (it's an instruction file, not memory data).
- [ ] **`.praxis/` directory structure** — `index.md`, `project-memory/`, `task-memory/`, `agent-memory/`, `archive/`, `_templates/`
- [ ] **Memory templates** — Strict templates for each memory file type (decisions, context, plan, lessons). Live in `.praxis/_templates/`.
- [ ] **`/kickoff`** — Initialize project: create `.praxis/` directory structure with templates, append SDD workflow conventions to CLAUDE.md. Idempotent — safe to re-run (verifies/repairs, doesn't overwrite). This is the single entry point for project setup regardless of install method.
- [ ] **`/profile`** — Write `# About Me` to CLAUDE.md (skill level, preferences, behaviors). Re-runnable.
- [ ] **`/explore`** — Research and clarify anything (technical, business, framework decisions). Auto-saves findings and decisions to `.praxis/`
- [ ] **`/plan-docs`** — Generate general plan + detailed implementation plans. Concise, source of truth. Saves to `.praxis/task-memory/`
- [ ] **`/gen-test`** — Generate TDD test cases from plan docs
- [ ] **`/implement`** — Implement code + tests, auto-create todo list, execute in order, save lessons learned
- [ ] **Graceful degradation** — Every skill detects missing prerequisites (no `.praxis/`? → guide to `/kickoff`. No plan? → offer to create one). Skills work in any order, not just the linear flow.

### Should-Have (v1.0 polish)

- [ ] **`/memory`** — View current memory state, manually trigger rebuild of `index.md`, prune old memories
- [ ] **Index.md auto-rebuild** — Reconstruct `index.md` from `.praxis/` directory scan as fallback when out of sync
- [ ] **Memory size guardrails** — Warn when memory files exceed ~200 lines, trigger consolidation
- [ ] **CLAUDE.md size check** — Warn when approaching ~150 line limit after `/profile` + `/kickoff` writes

### Nice-to-Have (Future)

- [ ] **Hook-based memory persistence** — Use `PreCompact`/`SessionEnd` hooks for automatic memory saves
- [ ] **Multi-agent support** — Adapt `.praxis/` and skills for Codex, Cursor, Gemini CLI
- [ ] **Memory metrics** — Track token usage per skill execution in `.praxis/metrics/`
- [ ] **Team memory** — Shared `.praxis/` across team members with merge-friendly markdown

### Distribution Strategy (Multi-Channel)

**Key principle: "Install the tool" and "set up the project" are separate steps.** Every distribution channel ends with "now run `/kickoff`." One consistent onboarding path.

| Channel | Command | What it does | Then what? | When to Build |
|---------|---------|-------------|------------|---------------|
| **npm CLI** (primary) | `npx praxis-kit` | Copies skills + `_memory-protocol.md` to `.claude/skills/` | Run `/kickoff` | Milestone 5 |
| **npm CLI update** | `npx praxis-kit --update` | Replaces SKILL.md + protocol files only (preserves `.praxis/` and CLAUDE.md) | Nothing — done | Milestone 5 |
| **Vercel Skills** (discovery) | `npx skills add github/praxis-kit` | Copies SKILL.md files to `.claude/skills/` | Run `/kickoff` | Milestone 5 |
| **Claude Code Plugin** (depth) | `/plugin install praxis-kit@marketplace` | Installs skills + hooks, with auto-updates | Run `/kickoff` | Future |
| **Manual copy** (fallback) | `git clone` + `cp` | Copies skills to `.claude/skills/` | Run `/kickoff` | Already supported |

---

## MVP Scope

**MVP delivers:** A working Claude Code skill kit where a developer can `/kickoff` a project, `/explore` decisions, `/plan-docs` an implementation, `/gen-test` test cases, and `/implement` code — all with automatic memory management that saves useful knowledge and loads relevant context per task. Skills handle nonlinear usage gracefully (e.g., `/implement` without `/plan-docs` offers to create a plan first).

**MVP does NOT include:**
- `/memory` command (users can read `.praxis/` files directly for v1)
- Hook-based memory persistence (explicit save at skill end instead)
- YAML frontmatter on memory files (use simpler in-body markers like `**Status:** active`)
- Claude Code Plugin distribution (deferred until hooks are added)
- Multi-agent support
- Memory metrics/analytics

**MVP installation:** `npx praxis-kit` installs skills to `.claude/skills/`, then user runs `/kickoff` to initialize the project. Two steps, clear separation: *install the tool* vs. *set up the project*. Manual copy remains as fallback.

**MVP naming convention:** Kebab-case for all skill directories: `kickoff`, `profile`, `explore`, `plan-docs`, `gen-test`, `implement`. Commands become `/kickoff`, `/profile`, `/explore`, `/plan-docs`, `/gen-test`, `/implement`.

---

## Architecture & Tech Stack

| Layer | Technology | Justification |
|-------|-----------|---------------|
| **Skills** | Claude Code Skills (`.claude/skills/*/SKILL.md`) | Native Claude Code integration. No external dependencies. Unified with slash commands since v2.1.3. |
| **Memory storage** | Markdown files in `.praxis/` directory | Human-readable, git-trackable, portable to other agents. Proven pattern (Anthropic, Manus, LangChain all use file-based memory). |
| **Memory protocol** | Shared `_memory-protocol.md` in `.claude/skills/`, referenced by all skills | Prevents instruction duplication across 6 SKILL.md files. Lives alongside skills (instruction file, not memory data). Single source of truth for curation rules. |
| **Memory retrieval** | `index.md` as structured pointer map + directory scan fallback | Lightweight (agent reads index in seconds). Self-healing (can rebuild from file system). Inspired by Manus's todo.md recitation pattern. |
| **User profile** | `# About Me` section in CLAUDE.md | Leverages Claude Code's native loading (CLAUDE.md is read every session). No separate profile system. |
| **Memory curation** | ADD/UPDATE/DELETE/NOOP framework (adapted from Mem0) | Research-proven: 26% accuracy boost, 90% token savings. Applied via LLM instructions in markdown, not programmatic vector DB. |
| **Memory templates** | Strict markdown templates with required sections per file type | Mitigates "curation quality varies wildly" risk by constraining free-form writing. Agent fills sections rather than inventing structure. |
| **Distribution** | npm package with CLI setup script (`npx praxis-kit`) + Vercel Skills (`npx skills add`) | CLI installs skills only (no `.praxis/`, no CLAUDE.md — that's `/kickoff`'s job). Vercel Skills handles discovery across 37+ agents. Same SKILL.md files serve both channels. `--update` flag for safe upgrades. |

### Repo Structure (single source, multi-channel)

`skills/` is the **single source of truth**. The CLI copies from here during install. No duplication.

```
praxis-kit/                           # GitHub repo
├── package.json                      # npm package config (bin → cli.js)
├── bin/
│   └── cli.js                        # npx praxis-kit setup script
├── skills/                           # Single source of truth for all channels
│   ├── _memory-protocol.md           # Shared memory management instructions
│   ├── kickoff/SKILL.md
│   ├── profile/SKILL.md
│   ├── explore/SKILL.md
│   ├── plan-docs/SKILL.md
│   ├── gen-test/SKILL.md
│   └── implement/SKILL.md
├── templates/                        # .praxis/ templates (copied by /kickoff)
│   ├── index.md
│   ├── decision.md
│   ├── context.md
│   ├── plan.md
│   ├── lessons.md
│   └── status.md
├── README.md
└── LICENSE
```

**How each channel uses this:**
- **`npx praxis-kit`** → CLI copies `skills/*` to `.claude/skills/` in user's project
- **`npx skills add`** → Vercel CLI reads `skills/` directly (standard Vercel format)
- **Manual copy** → User copies `skills/` to `.claude/skills/` themselves
- **All channels** → User then runs `/kickoff` to create `.praxis/` with templates

### Kit File Structure (what gets installed into the user's project)

```
project-root/
├── .claude/
│   └── skills/                        # ← Installed by npx praxis-kit (committed to git)
│       ├── _memory-protocol.md        # Shared memory management instructions
│       ├── kickoff/SKILL.md           # /kickoff — project initialization
│       ├── profile/SKILL.md           # /profile — user identity
│       ├── explore/SKILL.md           # /explore — research & clarify
│       ├── plan-docs/SKILL.md         # /plan-docs — implementation plans
│       ├── gen-test/SKILL.md          # /gen-test — TDD test cases
│       └── implement/SKILL.md         # /implement — code + tests
├── .praxis/                              # ← Created by /kickoff (gitignored by default)
│   ├── _templates/                    # Templates for memory files
│   │   ├── decision.md
│   │   ├── context.md
│   │   ├── plan.md
│   │   ├── lessons.md
│   │   └── status.md
│   ├── index.md                       # Memory index (rebuildable cache)
│   ├── project-memory/                # ← Optionally committed for team knowledge
│   │   ├── architecture.md
│   │   ├── requirements.md
│   │   └── decisions/
│   ├── task-memory/                   # Per-task working context (ephemeral)
│   ├── agent-memory/                  # Agent learnings (developer-local)
│   │   ├── lessons.md
│   │   └── patterns.md
│   └── archive/                       # Completed task memories
├── .gitignore                         # /kickoff adds: .praxis/ (with optional project-memory/ exception)
└── CLAUDE.md                          # Updated by /kickoff and /profile
```

### Git Behavior

**`.praxis/` is gitignored by default.** Agent memories, task context, and the index are ephemeral to the developer+agent pair — committing them would confuse team members.

**Exception: `project-memory/` can optionally be committed** for shared team knowledge (architecture decisions, requirements). `/kickoff` creates a `.gitignore` entry like:

```gitignore
# Praxis-kit memory (developer-local)
.praxis/*
# Uncomment to share project decisions with your team:
# !.praxis/project-memory/
```

**`.claude/skills/` should be committed** — these are the tool itself, version-controlled with the project.

### How Memory Works

#### How Memory Interacts with Claude Code's Context

There's no separate memory system running outside Claude Code. The `.praxis/` memory works **within** Claude Code's context window using its native tools:

- **"Load memory"** = Agent uses the **Read tool** to read `.praxis/` files → file contents enter the context window
- **"Save memory"** = Agent uses the **Write tool** to write `.praxis/` files → knowledge persists on disk for the next session
- **"Decide what's relevant"** = Agent reads the short `index.md` (~20 lines), then chooses which files to Read based on the user's request

The memory system doesn't expand Claude Code's context window — it **uses the context window more efficiently**. Instead of the agent exploring the entire codebase from scratch every session (slow, expensive, loads irrelevant files), it reads a small index, loads only the 2-3 curated files relevant to the current task, and gets to work with the right context already loaded.

#### Fully Automatic

Memory is **fully automatic** — the user just runs slash commands. All reading, saving, curating, and archiving happens behind the scenes, driven by instructions in each SKILL.md and the shared `_memory-protocol.md`.

#### The Memory Lifecycle (per skill execution)

```
User runs a skill (e.g., /explore how should we handle auth?)
        │
        ▼
┌─ 1. AUTO-LOAD ──────────────────────────────────────────┐
│  Agent reads index.md (structured pointer map)           │
│  Agent DECIDES which memory files are relevant:          │
│    → "auth relates to architecture and database choice"  │
│    → Loads project-memory/architecture.md                │
│    → Loads project-memory/decisions/2026-02-23-db.md     │
│    → Skips task-memory/unrelated-feature/ (not relevant) │
│  Only relevant context enters the conversation.          │
└──────────────────────────────────────────────────────────┘
        │
        ▼
┌─ 2. WORK ───────────────────────────────────────────────┐
│  Agent executes the skill's core purpose                 │
│  (research, planning, test generation, implementation)   │
│  with the right context already loaded.                  │
└──────────────────────────────────────────────────────────┘
        │
        ▼
┌─ 3. AUTO-SAVE & CURATE ────────────────────────────────┐
│  Agent applies ADD/UPDATE/DELETE/NOOP to each memory:    │
│                                                          │
│  ADD    → New finding: "JWT chosen for auth. Why:        │
│           stateless, fits microservices plan."            │
│  UPDATE → architecture.md: added auth section            │
│  DELETE → Removed dead-end exploration of OAuth2         │
│           (evaluated but rejected — no value keeping)    │
│  NOOP   → lessons.md unchanged (no new lessons yet)      │
│                                                          │
│  Saves ONLY curated knowledge:                           │
│    ✓ Specs, decisions with "why", key findings           │
│    ✗ Conversational fluff, dead-ends, redundant info     │
└──────────────────────────────────────────────────────────┘
        │
        ▼
┌─ 4. AUTO-INDEX ─────────────────────────────────────────┐
│  Agent updates index.md with new/changed entries         │
│  (mandatory final step in every skill)                   │
│  If index.md is missing → rebuilds from directory scan   │
└──────────────────────────────────────────────────────────┘
```

#### What's Automatic vs. Manual

| Action | Who | When |
|--------|-----|------|
| **Load relevant memories** | Agent (auto) | Start of every skill — reads `index.md`, decides what to load |
| **Save new knowledge** | Agent (auto) | End of every skill — saves findings, decisions, plans |
| **Curate (ADD/UPDATE/DELETE/NOOP)** | Agent (auto) | Part of save step — decides what's worth keeping |
| **Archive completed tasks** | Agent (auto) | When `/implement` finishes — moves to `archive/`, updates index |
| **Rebuild index.md** | Agent (auto) | When `index.md` is missing or stale — scans `.praxis/` directories |
| **Correct wrong memories** | Human (manual) | Only if agent saved something incorrect — edit `.praxis/` files directly |
| **Run skills** | Human (manual) | User decides when to `/explore`, `/plan-docs`, etc. Skills handle any order gracefully. |
| **Install skills** | Human (one-time) | `npx praxis-kit` copies skills to `.claude/skills/` |
| **Initialize project** | Human (one-time) | Run `/kickoff` once to create `.praxis/` structure + update CLAUDE.md |

#### Why This Works (research-backed)

- **Anthropic's guidance:** "Keep lightweight identifiers, load data on demand" — `index.md` as a pointer map does exactly this
- **Manus's pattern:** `todo.md` as a recitation point so the agent knows what's relevant — `index.md` serves the same role
- **Mem0's research:** Selective retrieval beats full-context dumps — 90% token savings, 26% accuracy boost
- **Key insight:** `index.md` is short and structured (one-line summaries with links), so the agent scans it in seconds and makes a good relevance decision without burning many tokens

---

### Key Design Decisions

1. **index.md is a rebuildable cache, not source of truth.** If it's missing or stale, skills scan `.praxis/` directories to reconstruct it. This eliminates the single biggest point of failure identified in the challenge phase.

2. **Simple in-body metadata instead of YAML frontmatter.** Instead of `---\nstatus: active\n---`, use `**Status:** active | **Updated:** 2026-02-23` in the markdown body. LLMs handle this more reliably than structured YAML.

3. **Templates constrain free-form writing.** Each memory file type has a strict template with required sections. The agent fills sections rather than inventing structure. This mitigates the "curation quality varies" risk.

4. **Memory protocol is a separate file, not embedded in skills.** `_memory-protocol.md` is read by skills at runtime. This means: one place to maintain curation rules, smaller SKILL.md files, and consistent behavior across all 6 commands.

5. **Decision files use timestamp-based naming.** `2026-02-23-database-choice.md` instead of `001-database-choice.md`. Avoids numbering conflicts in concurrent usage.

6. **"Install the tool" and "set up the project" are separate steps.** `npx praxis-kit` (or Vercel Skills, or manual copy) only installs skill files to `.claude/skills/`. `/kickoff` handles all project-specific initialization (`.praxis/`, CLAUDE.md, `.gitignore`). This means every distribution channel converges on the same `/kickoff` onboarding experience. No overlap, no confusion.

7. **Kebab-case everywhere.** All skill directories use kebab-case: `plan-docs`, `gen-test`. This is the Vercel Skills standard and works in Claude Code. Consistent naming across all distribution channels. Commands: `/kickoff`, `/profile`, `/explore`, `/plan-docs`, `/gen-test`, `/implement`.

8. **`.praxis/` is gitignored by default.** Agent memories are developer-local, not project artifacts. `project-memory/` (architecture, decisions) can optionally be committed for team knowledge sharing. Skills (`.claude/skills/`) are committed.

9. **Skills degrade gracefully.** Every skill checks for prerequisites and guides the user if something is missing (no `.praxis/`? → run `/kickoff`. No plan? → offer to create one). The workflow is recommended, not enforced.

---

## Milestones

### Milestone 1: Foundation — Memory Protocol + `/kickoff` + `/profile`

**Deliverable:** A working memory protocol and two skills that initialize the kit for any project. After this milestone, a developer can install skills (manually for now), `/kickoff` a project, and `/profile` themselves. The `.praxis/` directory with all templates is ready.

Tasks:
- [ ] **Design the memory protocol** — Write `skills/_memory-protocol.md` with:
  - ADD/UPDATE/DELETE/NOOP decision framework with 3-4 concrete exemplars each
  - In-body metadata format (`**Status:** active | **Updated:** 2026-02-23`)
  - Per-file-type curation rules (decisions: rarely delete, update when changed; context: prune dead-ends; lessons: consolidate over time)
  - index.md update procedure (mandatory final step + rebuild-from-scan fallback)
  - Explicit "SAVE this / PRUNE this" examples for curated knowledge quality
- [ ] **Create memory file templates** — Write `templates/decision.md`, `context.md`, `plan.md`, `lessons.md`, `status.md` with required sections (these get copied to `.praxis/_templates/` by `/kickoff`)
- [ ] **Design index.md format** — Structured, scannable map with sections: Active Tasks, Project Knowledge, Recent Decisions, Agent Lessons
- [ ] **Build `/kickoff` SKILL.md** — The single entry point for project setup. Instructions to:
  - Check if `.praxis/` already exists — if yes, verify/repair rather than overwrite (idempotent)
  - Create `.praxis/` directory structure with all subdirectories
  - Copy templates from the repo's `templates/` (or bundled in skill) into `.praxis/_templates/`
  - Initialize empty `index.md`, `architecture.md`, `requirements.md`, `lessons.md`
  - Check if CLAUDE.md exists; if not, guide user to create one
  - Append spec-driven workflow conventions to CLAUDE.md (keep it under 30 lines of kit content, check if section already exists to avoid duplicates)
  - Add `.praxis/` to `.gitignore` (with commented-out `!.praxis/project-memory/` exception)
- [ ] **Build `/profile` SKILL.md** — Instructions to:
  - Ask user about skill level, preferred languages/frameworks, working style, communication preferences
  - Write or update `# About Me` section in CLAUDE.md (check if it exists first — idempotent)
  - Keep profile section under 15 lines
- [ ] **Test manually** — Run `/kickoff` + `/profile` on 2 different project types (web app, CLI tool). Verify:
  - `.praxis/` structure is correct
  - CLAUDE.md output is clean (no duplicates on re-run)
  - `.gitignore` entry is added
  - index.md format is correct
  - Re-running `/kickoff` doesn't destroy existing data

---

### Milestone 2: Explore Phase — `/explore` with Memory Integration

**Deliverable:** A working `/explore` skill that researches/clarifies any topic and auto-saves curated findings to `.praxis/`. This is the first skill that exercises the full memory read/write/prune cycle.

**Depends on:** Milestone 1

Tasks:
- [ ] **Build `/explore` SKILL.md** — Instructions to:
  - **Prerequisite check:** If `.praxis/` doesn't exist, tell user to run `/kickoff` first
  - Read `index.md` to understand current project state (or rebuild if missing)
  - Load relevant `project-memory/` and `task-memory/` based on user's exploration topic
  - Conduct exploration (web search, codebase analysis, technical research, business clarification — whatever the user asks)
  - At completion, execute memory protocol:
    - ADD new findings to `task-memory/<task>/context.md` using template
    - ADD/UPDATE decisions to `project-memory/decisions/<timestamp>-<name>.md`
    - DELETE dead-end explorations from context
    - UPDATE `index.md`
  - Reference `_memory-protocol.md` for curation rules
- [ ] **Test memory curation quality** — Run `/explore` 5+ times across different topics. Evaluate:
  - Does it save the right things? (specs, decisions with "why", key findings)
  - Does it prune the right things? (conversational fluff, dead-end explorations)
  - Does index.md stay in sync?
  - Are templates followed consistently?
- [ ] **Iterate on memory protocol** — Based on testing, refine exemplars, adjust curation rules, fix any template issues
- [ ] **Test index.md rebuild** — Delete index.md, run `/explore`, verify the skill reconstructs it from directory scan

---

### Milestone 3: Plan Phase — `/plan-docs` with Memory Integration

**Deliverable:** A working `/plan-docs` skill that generates implementation-ready plans from exploration findings, reading from and writing to `.praxis/`.

**Depends on:** Milestone 2

Tasks:
- [ ] **Build `/plan-docs` SKILL.md** — Instructions to:
  - **Prerequisite check:** If `.praxis/` doesn't exist → guide to `/kickoff`. If no exploration context exists for this task → offer to proceed without it or run `/explore` first
  - Read `index.md` to find relevant exploration context
  - Load `task-memory/<task>/context.md` and `project-memory/` for full background
  - Generate two artifacts:
    - **General plan**: High-level approach, architecture, key decisions (concise, ~1-2 pages)
    - **Detailed plan**: Step-by-step implementation tasks, dependencies, specific files/functions to create/modify (implementation-ready)
  - Save to `task-memory/<task>/plan.md` using template
  - Prune draft plans (keep only final version)
  - UPDATE `index.md`
- [ ] **Test plan quality** — Run `/explore` → `/plan-docs` on a real feature. Evaluate:
  - Is the plan actually implementation-ready? (specific enough to code from)
  - Does it reference exploration findings correctly?
  - Is it concise (no unrelated content)?
- [ ] **Test memory chain** — Verify `/plan-docs` correctly reads what `/explore` saved. Full pipeline: `/kickoff` → `/explore` → `/plan-docs` works end-to-end.
- [ ] **Test graceful degradation** — Run `/plan-docs` without running `/explore` first. Verify it offers to proceed without context or suggests running `/explore`.

---

### Milestone 4: Code Phase — `/gen-test` + `/implement`

**Deliverable:** Working `/gen-test` and `/implement` skills that complete the Explore → Plan → Code loop with TDD and auto-managed task execution.

**Depends on:** Milestone 3

Tasks:
- [ ] **Build `/gen-test` SKILL.md** — Instructions to:
  - **Prerequisite check:** If no plan exists → offer to create one with `/plan-docs` or proceed with user-provided instructions
  - Read `task-memory/<task>/plan.md` for implementation details
  - Generate test cases following TDD (test-first approach)
  - Write tests to the appropriate location in the codebase (not in `.praxis/`)
  - Focus on: unit tests for core logic, integration tests for critical paths
  - No memory write (tests live in codebase, not memory)
- [ ] **Build `/implement` SKILL.md** — Instructions to:
  - **Prerequisite check:** If no plan exists → offer to create one with `/plan-docs` or proceed with user instructions. If no `.praxis/` → guide to `/kickoff`.
  - Read `task-memory/<task>/plan.md` for implementation steps
  - Read `agent-memory/lessons.md` and `agent-memory/patterns.md` for past learnings
  - Auto-create a todo list (using Claude Code's task system) from the plan
  - Execute tasks in order, running tests after each step
  - At completion, execute memory protocol:
    - ADD lessons learned to `agent-memory/lessons.md`
    - ADD reusable patterns to `agent-memory/patterns.md`
    - UPDATE `task-memory/<task>/status.md` to mark complete
    - Move completed task memory to `archive/<task>/`
    - UPDATE `index.md`
- [ ] **Test TDD flow** — Run full pipeline: `/explore` → `/plan-docs` → `/gen-test` → `/implement`. Verify:
  - Tests are generated before implementation
  - Implementation follows the plan
  - Todo list executes in correct order
  - Tests pass after implementation
- [ ] **Test memory archiving** — Verify completed tasks move to `archive/` and index.md is updated

---

### Milestone 5: Packaging, Integration Testing + Release

**Deliverable:** A battle-tested, packaged kit with `npx praxis-kit` one-command installation, published to npm and skills.sh.

**Depends on:** Milestone 4

Tasks:
- [ ] **Build the npm CLI setup script** (`bin/cli.js`) — The `npx praxis-kit` entry point that:
  - Copies SKILL.md files + `_memory-protocol.md` from `skills/` to `.claude/skills/` in the current project
  - Adds version comment to each installed file (`<!-- praxis-kit v1.0.0 -->`) for upgrade detection
  - Prints getting-started message: "Now run `/kickoff` to initialize your project"
  - **Does NOT** create `.praxis/`, modify CLAUDE.md, or touch `.gitignore` (that's `/kickoff`'s job)
  - Supports `--update` flag: replaces SKILL.md + protocol files only (preserves `.praxis/` and CLAUDE.md)
  - Supports `--help` flag
  - v1 scope: Claude Code only (skip multi-agent detection — add in v1.1)
- [ ] **Set up package.json** — npm package config with:
  - `name: "praxis-kit"`, `bin: { "praxis-kit": "./bin/cli.js" }`
  - Zero runtime dependencies (Node.js `fs` + `path` only)
  - `files` array to include only `bin/`, `skills/`, `templates/`
- [ ] **Structure repo for Vercel Skills** — Ensure `skills/` directory follows the Vercel Skills format so `npx skills add github/praxis-kit` works out of the box
- [ ] **Test distribution channels**:
  - Fresh `npx praxis-kit` on empty project → then `/kickoff` → verify everything works
  - Fresh `npx skills add` on empty project → then `/kickoff` → verify everything works
  - `npx praxis-kit --update` on existing project → verify `.praxis/` and CLAUDE.md untouched
  - Install on project that already has CLAUDE.md with custom content → verify no corruption
- [ ] **Dogfood on 3 project types**:
  - Web application (e.g., Next.js + database)
  - CLI tool (e.g., Node.js/Python command-line utility)
  - Library/package (e.g., npm package or Python library)
- [ ] **Stress test memory system**:
  - Run 10+ tasks across a single project — verify memory doesn't bloat
  - Test multi-task switching — start task A, switch to task B, return to task A
  - Test memory correction — manually edit `.praxis/` files, verify skills adapt
  - Test index.md rebuild after corruption
- [ ] **Measure CLAUDE.md budget** — Document exactly how many lines `/profile` + `/kickoff` consume
- [ ] **Write README.md** — Installation guide (featuring `npx praxis-kit`), quick start, skill reference, memory architecture explanation
- [ ] **Write CLAUDE.md for Praxis-kit repo itself** — Use the kit to build the kit's own documentation
- [ ] **Publish to npm** — `npm publish` the praxis-kit package
- [ ] **Publish to GitHub** — Public `praxis-kit` repo with examples
- [ ] **Verify Vercel Skills discovery** — Confirm the kit appears on [skills.sh](https://skills.sh/) after installs
- [ ] **Submit to awesome-claude-code and awesome-claude-skills** — Get listed for discoverability

---

## Risks & Mitigations

| Risk | Severity | Mitigation Strategy in This Plan |
|------|----------|----------------------------------|
| **index.md goes out of sync** | High | index.md is a rebuildable cache. Every skill has rebuild-from-scan fallback. Mandatory update as final step in memory protocol. |
| **SKILL.md instruction overload** | High | Memory protocol extracted to shared `_memory-protocol.md`. Each SKILL.md focuses on phase workflow + "follow memory protocol." |
| **Curation quality varies** | Medium | Strict templates constrain free-form writing. Memory protocol includes 3-4 concrete SAVE/PRUNE exemplars per operation type. |
| **Inconsistent metadata formatting** | Medium | Using simple in-body markers (`**Status:** active`) instead of YAML frontmatter. More reliable for LLM generation. |
| **Memory bloat over time** | Medium | Completed tasks auto-archive. index.md capped to recent entries. v1.0 adds size-check guardrails. |
| **AI DevKit adds curated memory** | High | Ship the memory protocol as a standalone, well-documented reference. Go deep on curation quality with exemplars. Build community early. |
| **Prompt brittleness across projects** | Medium | Dogfood across 3 project types before release. Iterate on prompts based on failures. |
| **npm package name squatting** | Low | Register `praxis-kit` on npm early (even as placeholder `0.0.1`). Check for name conflicts before committing. |
| **Vercel Skills ecosystem changes** | Low | Keep skills format simple (just SKILL.md with frontmatter). Also support manual copy as fallback. Don't depend on any single distribution channel. |
| **Stale skills after updates** | Medium | Version comment in installed SKILL.md files. `--update` flag replaces only skill files. Document upgrade process in README. Claude Code Plugin channel (future) adds auto-updates. |
| **Users skip workflow steps** | Medium | Every skill checks prerequisites and guides gracefully (no plan? → offer to create one). Workflow is recommended, not enforced. |
| **CLAUDE.md write conflicts** | Medium | All writes are idempotent: read current content, check if section exists, update in place or append. `/kickoff` and `/profile` both follow this pattern. |

---

## Open Questions

- [x] **What should the kit be called?** → **Praxis-kit** (*praxis* = practical application of theory → specs become code)
- [x] **Global vs. project-local skill installation?** → **Project-local by default** (`npx praxis-kit` installs to `.claude/skills/` in the current project). This keeps skills version-controlled with the project. Users who want global can manually copy to `~/.claude/skills/`.
- [x] **How to distribute the kit?** → **Multi-channel**: `npx praxis-kit` (primary, complete setup), Vercel Skills (discovery), Claude Code Plugin (future, when hooks are added). See Distribution Strategy section.
- [x] **Should `npx praxis-kit` replace `/kickoff`?** → **No.** CLI installs skills only. `/kickoff` handles all project-specific initialization (`.praxis/`, CLAUDE.md, `.gitignore`). Clear separation: "install the tool" vs. "set up the project." Every distribution channel converges on `/kickoff`.
- [x] **Skill naming convention?** → **Kebab-case everywhere.** `plan-docs`, `gen-test`. Consistent across Vercel Skills, Claude Code, and CLI. Commands: `/plan-docs`, `/gen-test`.
- [x] **Should `.praxis/` be committed to git?** → **Gitignored by default.** Agent memories are developer-local. `project-memory/` can optionally be committed for team knowledge. `.claude/skills/` should be committed.
- [ ] **How to handle `/explore` for non-task-specific research?** Not all exploration maps to a specific task (e.g., "what database should I use for this project?"). Should this go to `project-memory/` directly instead of `task-memory/`?
- [ ] **Should `/kickoff` run `/profile` automatically if no `# About Me` exists?** Could reduce onboarding to a single command. Or keep them separate for clarity.
- [ ] **License choice?** MIT (maximum adoption) vs. Apache 2.0 (patent protection) vs. something else.

---

## First Steps

Start here — these are the concrete actions to begin building immediately:

1. **Create the repo with single-source structure.** Initialize `praxis-kit` on GitHub with:
   - `skills/` directory (single source of truth) with kebab-case SKILL.md dirs for all 6 commands
   - `templates/` directory for `.praxis/` memory file templates
   - `bin/cli.js` placeholder for the `npx praxis-kit` setup script
   - `package.json` with `name: "praxis-kit"` and `bin` entry
   - Register `praxis-kit` on npm early (placeholder `0.0.1`)

2. **Write `skills/_memory-protocol.md` first.** This is the foundation. Include:
   - ADD/UPDATE/DELETE/NOOP framework with exemplars
   - In-body metadata format
   - index.md update/rebuild procedure
   - SAVE vs. PRUNE exemplars for curated knowledge
   - Test it manually by giving Claude Code the protocol and a mock `.praxis/` directory

3. **Write memory file templates.** Create `templates/decision.md`, `context.md`, `plan.md`, `lessons.md`, `status.md`. Each should have required sections that constrain the agent's writing.

4. **Build `/kickoff` and `/profile`.** `/kickoff` is the most important skill — it's the universal onboarding path. Make it idempotent (safe to re-run). Test that it creates `.praxis/`, updates CLAUDE.md without duplicates, and adds `.gitignore` entry.

5. **Build `/explore` and test the full memory cycle.** This is the first real test of whether the memory protocol works. Run it 5+ times, evaluate curation quality, iterate.

6. **Build `npx praxis-kit` CLI.** Once skills are stable, write `bin/cli.js` — a simple ~100-line script that copies skills to `.claude/skills/` and tells the user to run `/kickoff`. Test on a fresh project. Publish to npm.

---

*To iterate on this plan, run `/review plan`. To revisit earlier phases, run `/review` with the phase name.*
