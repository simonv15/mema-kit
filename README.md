# Praxis-kit

Spec-driven development kit for Claude Code that adds structured workflow and intelligent memory management via slash commands.

**What it does:** Six commands guide you through Explore → Plan → Code. The agent automatically loads relevant context, saves curated knowledge, and prunes noise between sessions.

**Key differentiator:** A `.praxis/` memory system that persists project architecture, decisions (with reasoning), task context, and agent-learned lessons as curated markdown. Each new session starts with the right context already loaded — no re-explaining, no expensive codebase exploration.

## Install

```bash
# 1. Install skills into your project
npm install praxis-kit

# 2. Open Claude Code and initialize
claude
> /kickoff
```

`/kickoff` creates the `.praxis/` memory structure, updates CLAUDE.md, and configures `.gitignore`.

**Alternative installs** (all end with "run `/kickoff`"):

```bash
npx praxis-kit                       # One-off install without adding to package.json
npx skills add github/praxis-kit     # Via Vercel Skills
```

## Workflow

```
/kickoff → /profile → /explore → /plan-docs → /gen-test → /implement
                        ↑                                      │
                        └──────── loop as needed ──────────────┘
```

| Command | Purpose |
|---------|---------|
| `/kickoff` | Initialize project — creates `.praxis/`, updates CLAUDE.md |
| `/profile` | Set your skill level, preferences, communication style |
| `/explore` | Research and clarify — tech decisions, frameworks, business logic |
| `/plan-docs` | Generate implementation-ready plans from exploration findings |
| `/gen-test` | Generate TDD test cases from plans (tests first, code second) |
| `/implement` | Implement code following the plan, running tests at each step |

Every command is **idempotent** — safe to re-run. Steps can be skipped; each skill checks prerequisites and guides you if something's missing.

## How Memory Works

Praxis-kit uses a `.praxis/` directory in your project to persist knowledge between sessions:

```
.praxis/
├── index.md             # Memory map — agent reads this first
├── project-memory/      # Architecture, requirements, decisions
├── task-memory/         # Per-task context, plans, active work
├── agent-memory/        # Lessons learned, reusable patterns
└── archive/             # Completed task memories
```

- **Auto-load**: Each command reads `index.md` and loads only the files relevant to your current task.
- **Auto-save**: After work, the agent curates findings into the right memory files.
- **Auto-prune**: Noise is removed; only actionable knowledge is kept.
- **Self-healing**: If `index.md` gets out of sync, the next command rebuilds it from the directory structure.

Memory is just markdown. Open any file to see what the agent knows. Edit directly if something's wrong.

## Updating

```bash
npx praxis-kit --update
```

Updates skill files only. Never touches `.praxis/`, CLAUDE.md, or `.gitignore`.

## Requirements

- Node.js >= 16.7.0
- [Claude Code](https://claude.ai/code)

## Documentation

See [docs/guide.md](docs/guide.md) for the full usage guide with a worked example.

## Links

- [npm package](https://www.npmjs.com/package/praxis-kit)
- [GitHub repository](https://github.com/simonv15/praxis-kit)

## License

MIT
