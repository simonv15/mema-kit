# mema-kit

Full AI-assisted development lifecycle kit for Claude Code. From vague idea to shipped code — without switching tools.

**What it does:** Twelve built-in skills cover the entire development lifecycle: brainstorm and validate ideas, break them into features, plan and implement each feature, and persist curated knowledge across every session in a `.mema/` memory directory.

**Key differentiator:** The memory protocol (AUTO-LOAD → WORK → AUTO-SAVE & CURATE → AUTO-INDEX) connects every phase. Skills read what previous skills wrote — a spec references research findings, a plan references architecture decisions, an implementation references the plan. Context compounds instead of resetting.

## Quick Start

### New project (starting from an idea)

```bash
npx mema-kit          # install skills
claude
> /mema.seed          # capture your idea
> /mema.clarify       # refine with Q&A
> /mema.research      # find what exists (uses web search)
> /mema.challenge     # stress-test assumptions
> /mema.roadmap       # create prioritized feature list
> /mema.specify 001   # spec the first feature
> /mema.plan 001      # technical design
> /mema.tasks 001     # generate task list
> /mema.implement 001 # build it, one task at a time
```

### Existing project (starting from code)

```bash
npx mema-kit          # install skills
claude
> /mema.onboard       # scan project, create .mema/, populate memory
> /mema.specify       # spec a feature
> /mema.plan          # technical design
> /mema.tasks         # generate task list
> /mema.implement     # build it
```

### Every new session

```
> /mema.recall        # reload context — active features, stack, next action
```

## Built-in Skills

### Discovery (new projects)

| Command | Purpose |
|---------|---------|
| `/mema.seed` | Capture a raw idea → `product/seed.md` |
| `/mema.clarify` | Refine with targeted Q&A → `product/clarify.md` |
| `/mema.research` | Web search: competitors, market, tech options → `product/research.md` |
| `/mema.challenge` | Stress-test: assumptions, risks, blind spots → `product/challenge.md` |
| `/mema.roadmap` | Synthesize into prioritized feature list → `product/roadmap.md` |

### Feature Workflow

| Command | Purpose |
|---------|---------|
| `/mema.specify` | Feature spec (what + why) → `features/NNN-name/spec.md` |
| `/mema.plan` | Technical design → `features/NNN-name/plan.md` |
| `/mema.tasks` | Ordered task list → `features/NNN-name/tasks.md` |
| `/mema.implement` | Execute one task at a time, track progress |

### Utilities

| Command | Purpose |
|---------|---------|
| `/mema.onboard` | Bootstrap memory for an existing project (also migrates old mema-kit structure) |
| `/mema.recall` | Load memory into current session — shows active features first |
| `/mema.create-skill` | Generate a new memory-aware skill with the correct lifecycle phases |

## How Memory Works

```
.mema/
├── index.md               # Pointer map — read first
├── product/               # Discovery phase outputs
│   ├── seed.md
│   ├── clarify.md
│   ├── research.md
│   ├── challenge.md
│   └── roadmap.md
├── features/              # One directory per feature
│   └── 001-feature-name/
│       ├── spec.md        # What + why
│       ├── plan.md        # Technical design
│       ├── tasks.md       # Implementation task list
│       └── status.md      # Progress tracking
├── project/               # Stable project knowledge
│   ├── architecture.md
│   ├── requirements.md
│   ├── structure.md
│   └── decisions/
├── agent/                 # Cross-session knowledge
│   ├── lessons.md
│   └── patterns.md
└── archive/               # Completed features
```

Memory is just markdown. Open any file to see what the agent knows. Edit directly if something's wrong.

## The Memory Protocol

Every skill follows four phases defined in `_memory-protocol.md`:

1. **AUTO-LOAD** — Read `index.md`, load only relevant files
2. **WORK** — Execute with loaded context
3. **AUTO-SAVE & CURATE** — ADD / UPDATE / DELETE / NOOP for each piece of knowledge
4. **AUTO-INDEX** — Update `index.md` to reflect changes

The protocol is shared across all skills (never duplicated). Any skill you build can plug into it — not just the twelve that ship with mema-kit.

## Building Your Own Skills

```
> /mema.create-skill

Name: review
Purpose: Review code changes for quality and consistency
Complexity: standard
```

Creates `.claude/skills/review/SKILL.md` with the full 4-phase memory lifecycle. Three complexity levels:

- **Simple** (3 phases) — Read-only skills: code review, linting, quick lookups
- **Standard** (4 phases) — Most skills that read and write memory
- **Advanced** (4 phases + task management) — Multi-step workflows with archiving

## Updating

```bash
npx mema-kit --update
```

Updates skill files only. Never touches `.mema/`, CLAUDE.md, or `.gitignore`.

If upgrading from an earlier version of mema-kit (with `project-memory/`, `agent-memory/`, `task-memory/` directories), run `/mema.onboard` after updating — it migrates the old structure automatically.

## Requirements

- Node.js >= 16.7.0
- [Claude Code](https://claude.ai/code)

## Documentation

See [docs/guide.md](docs/guide.md) for the full usage guide with worked examples.

## Links

- [npm package](https://www.npmjs.com/package/mema-kit)
- [GitHub repository](https://github.com/simonv15/mema-kit)

## License

MIT
