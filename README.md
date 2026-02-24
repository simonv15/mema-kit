# Praxis-kit

Praxis-kit is a spec-driven development kit for Claude Code that adds structured workflow and intelligent memory management via slash commands.

**What it does:** Six commands guide you through Explore → Plan → Code — `/kickoff`, `/profile`, `/explore`, `/plan-docs`, `/gen-test`, `/implement`. The agent automatically loads relevant context, saves curated knowledge, and prunes noise between sessions.

**Key differentiator:** A `.praxis/` memory system that persists project architecture, decisions (with reasoning), task context, and agent-learned lessons as curated markdown. Each new session starts with the right context already loaded — no re-explaining, no expensive codebase exploration.

**Install:** `npx praxis-kit` → `/kickoff`. That's it.
