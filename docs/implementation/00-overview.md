# Implementation Plans — Overview

This directory contains detailed implementation plans for every component of Praxis-kit. Each plan includes the reasoning behind decisions, gentle explanations of how things work, and clear step-by-step instructions to build it.

---

## Reading Order & Dependencies

The plans are numbered to reflect build order. Later plans depend on earlier ones.

```
01-memory-protocol ──┐
                     ├──→ 03-kickoff-skill ──→ 04-profile-skill
02-templates ────────┘           │
                                 ▼
                         05-explore-skill
                                 │
                                 ▼
                         06-plan-docs-skill
                                 │
                                 ▼
                    ┌────────────┴────────────┐
                    ▼                         ▼
            07-gen-test-skill         08-implement-skill
                    │                         │
                    └────────────┬────────────┘
                                 ▼
                         09-cli-packaging
```

### What each plan covers

| # | Plan | Milestone | What it produces |
|---|------|-----------|-----------------|
| 01 | [Memory Protocol](./01-memory-protocol.md) | M1 | `skills/_memory-protocol.md` — the shared curation rules all skills reference |
| 02 | [Templates](./02-templates.md) | M1 | `templates/*.md` — the strict templates for every memory file type |
| 03 | [Kickoff Skill](./03-kickoff-skill.md) | M1 | `skills/kickoff/SKILL.md` — project initialization |
| 04 | [Profile Skill](./04-profile-skill.md) | M1 | `skills/profile/SKILL.md` — user profile setup |
| 05 | [Explore Skill](./05-explore-skill.md) | M2 | `skills/explore/SKILL.md` — research & clarify |
| 06 | [Plan-Docs Skill](./06-plan-docs-skill.md) | M3 | `skills/plan-docs/SKILL.md` — implementation plans |
| 07 | [Gen-Test Skill](./07-gen-test-skill.md) | M4 | `skills/gen-test/SKILL.md` — TDD test generation |
| 08 | [Implement Skill](./08-implement-skill.md) | M4 | `skills/implement/SKILL.md` — code + tests + lessons |
| 09 | [CLI & Packaging](./09-cli-packaging.md) | M5 | `bin/cli.js` + `package.json` — npm distribution |

### How to use these plans

1. **Read plans 01 and 02 first.** They define the foundation (curation rules + file templates) that every skill depends on.
2. **Build in milestone order.** Each milestone produces testable output before moving to the next.
3. **Each plan is self-contained.** You can read any plan independently — it includes all context and reasoning you need. But the implementation instructions assume earlier components exist.
4. **Plans include the actual file content.** Most plans contain the complete content of the file they produce, ready to copy. Some include pseudo-code for logic sections.

### Milestone map

- **Milestone 1** (Plans 01–04): Foundation. After this, a developer can install skills, `/kickoff` a project, and `/profile` themselves. The `.praxis/` directory with all templates is ready.
- **Milestone 2** (Plan 05): Explore phase. The first skill that exercises the full memory read/write/prune cycle. This is the real test of whether the memory protocol works.
- **Milestone 3** (Plan 06): Plan phase. Generates implementation-ready plans from exploration findings.
- **Milestone 4** (Plans 07–08): Code phase. Completes the Explore → Plan → Code loop with TDD and auto-managed task execution.
- **Milestone 5** (Plan 09): Packaging. `npx praxis-kit` one-command installation, npm publish, Vercel Skills.

### A note on SKILL.md files

Every SKILL.md follows a consistent structure mandated by Claude Code's skill system:

```markdown
---
description: Short description shown in /skills list
---

# Skill Name

[Instructions for the agent — what to do when the user invokes this command]
```

The YAML frontmatter `description` is required by Claude Code. Everything after the frontmatter is the agent's instruction set — written in natural language, addressing Claude directly ("you should", "read the file", "check if X exists").

SKILL.md files are essentially **prompt engineering documents**. They tell Claude Code how to behave when the user runs a slash command. The quality of these instructions directly determines the quality of the agent's output.
