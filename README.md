# mema-kit

Memory protocol kit for Claude Code skills. Give any skill persistent, curated memory across sessions.

**What it does:** A `.mema/` directory in your project stores architecture decisions, requirements, lessons learned, and reusable patterns as curated markdown. Skills automatically load relevant context at the start of each session and save curated knowledge when done.

**Key differentiator:** The memory protocol (AUTO-LOAD → WORK → AUTO-SAVE & CURATE → AUTO-INDEX) is a reusable pattern. Any skill you build can plug into it — not just the three that ship with mema-kit.

## Quick Start

```bash
# 1. Install skills into your project
npx mema-kit

# 2. Open Claude Code and bootstrap memory
claude
> /mema.onboard

# 3. Next session: load memory into context
> /mema.recall
```

`/mema.onboard` scans your project, creates the `.mema/` memory structure, populates initial architecture and requirements docs, and configures CLAUDE.md and `.gitignore`. `/mema.recall` loads that memory into any future session.

## Built-in Skills

| Command | Purpose |
|---------|---------|
| `/mema.onboard` | Bootstrap memory for a project — scans codebase, creates `.mema/`, populates initial knowledge |
| `/mema.recall` | Load project memory into the current session — instant context on cold start |
| `/mema.create-skill` | Generate a new memory-aware skill with the correct lifecycle phases |

## How Memory Works

mema-kit uses a `.mema/` directory in your project to persist knowledge between sessions:

```
.mema/
├── index.md             # Memory map — agent reads this first
├── project-memory/      # Architecture, requirements, decisions
│   └── decisions/       # Individual decision records with reasoning
├── task-memory/         # Per-task context, plans, active work
├── agent-memory/        # Lessons learned, reusable patterns
└── archive/             # Completed task memories
```

- **Auto-load**: Skills read `index.md` and load only the files relevant to the current task.
- **Auto-save**: After work, the agent curates findings into the right memory files.
- **Auto-prune**: Noise is removed; only actionable knowledge is kept.
- **Self-healing**: If `index.md` gets out of sync, the next skill rebuilds it from the directory structure.

Memory is just markdown. Open any file to see what the agent knows. Edit directly if something's wrong.

## The Memory Protocol

Every memory-aware skill follows four phases:

1. **AUTO-LOAD** — Read `index.md`, decide what's relevant, load only those files
2. **WORK** — Execute the skill's core purpose with loaded context
3. **AUTO-SAVE & CURATE** — For each piece of knowledge, decide: ADD / UPDATE / DELETE / NOOP
4. **AUTO-INDEX** — Update `index.md` to reflect all changes

The protocol is defined in `_memory-protocol.md` and shared across all skills (never duplicated). See [docs/guide.md](docs/guide.md) for the full protocol reference.

## Building Your Own Skills

Use `/mema.create-skill` to generate memory-aware skills:

```
> /mema.create-skill

Skill name: review
Purpose: Review code changes for quality and consistency
Complexity: standard
```

This creates `.claude/skills/review/SKILL.md` with the full 4-phase memory lifecycle wired in. Three complexity levels are available:

- **Simple** (3 phases) — Read-only skills like code review, linting
- **Standard** (4 phases) — Most skills that read and write memory
- **Advanced** (4 phases + task management) — Multi-step workflows with archiving

## Updating

```bash
npx mema-kit --update
```

Updates skill files only. Never touches `.mema/`, CLAUDE.md, or `.gitignore`.

## Requirements

- Node.js >= 16.7.0
- [Claude Code](https://claude.ai/code)

## Documentation

See [docs/guide.md](docs/guide.md) for the full usage guide with worked examples and protocol reference.

## Links

- [npm package](https://www.npmjs.com/package/mema-kit)
- [GitHub repository](https://github.com/simonv15/mema-kit)

## License

MIT
