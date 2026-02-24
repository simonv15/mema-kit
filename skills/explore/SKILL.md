---
description: Research and clarify any topic — technical decisions, frameworks, architecture, business logic. Auto-saves curated findings to .praxis/ memory.
---

# /explore — Research & Clarify

You are researching a topic for this project. You will explore thoroughly, make recommendations where appropriate, and save curated findings to memory.

Read and follow the memory protocol in `_memory-protocol.md` for all memory operations.

## Phase 1: AUTO-LOAD (Load Relevant Context)

1. **Check prerequisites:** If `.praxis/` doesn't exist, stop and tell the user: "No .praxis/ directory found. Run /kickoff first to initialize the project."

2. **Read the index:** Read `.praxis/index.md`. If it's missing or empty, run the Rebuild Procedure from `_memory-protocol.md`.

3. **Assess the user's question:** What topic are they exploring? What existing knowledge might be relevant?

4. **Load relevant memories:** Based on the index, read any files that relate to the user's topic:
   - Architecture decisions that affect the exploration (e.g., exploring auth? load the tech stack decision)
   - Prior explorations on related topics (e.g., exploring testing? load the framework context)
   - Active task context if this relates to a specific task
   - Skip files that are clearly unrelated

5. **Brief the user:** In 1-2 sentences, tell the user what context you loaded: "I see we're using Fastify + PostgreSQL. I'll explore auth options with that stack in mind." If no relevant context exists: "This is a fresh topic — I'll explore from scratch."

## Phase 2: WORK (Research the Topic)

Explore the user's question thoroughly. You have access to all tools:
- **Web search** for current best practices, comparisons, documentation
- **Codebase reading** for understanding existing implementation
- **File exploration** for project structure analysis

**Research guidelines:**
- Compare 2-4 realistic options (not exhaustive surveys)
- Analyze trade-offs for each option (not just pros/cons lists — explain what each trade-off means for this specific project)
- Make a recommendation if the evidence supports one (don't be artificially neutral)
- If the exploration reveals related questions that weren't asked, note them but don't explore them — let the user decide
- Reference loaded context when relevant ("Given our Fastify stack, Option A integrates better because...")

**Present your findings** to the user clearly. Use comparison tables for multi-option analysis. Be specific — "2x faster" not "faster."

## Phase 3: AUTO-SAVE (Save Curated Knowledge)

After presenting findings to the user and getting their input (if they have any), save curated knowledge to `.praxis/`.

### Determine the scope:

**Project-wide exploration** (tech stack, auth, database, deployment, conventions):
- Save findings to `project-memory/architecture.md` or `project-memory/requirements.md` (update existing content)
- If a decision was made, create a decision file: `project-memory/decisions/YYYY-MM-DD-short-name.md` using the template from `.praxis/_templates/decision.md`

**Task-specific exploration** (feature design, API endpoint, component structure):
- Create or update `task-memory/<task-name>/context.md` using the template from `.praxis/_templates/context.md`
- If a project-wide decision emerged, also save it to `project-memory/decisions/`

**How to derive the task name:** Extract the core concept from the user's request in kebab-case. "/explore how should user authentication work?" → `user-auth`. "/explore pagination strategy for the API" → `api-pagination`. If a task directory with that name already exists, add to it.

### Apply curation (from memory protocol):

- **ADD** new findings and decisions
- **UPDATE** existing files if the exploration refines previous knowledge (e.g., architecture.md gains a new section)
- **DELETE** dead-end context from previous explorations that this exploration supersedes
- **NOOP** for memories that are still accurate and unaffected

### What to save vs. prune:

**Save:**
- The final recommendation with reasoning
- Key constraints discovered ("PostgreSQL is required by the hosting provider")
- Trade-off analysis for decisions made
- Open questions that need future exploration

**Prune:**
- The step-by-step research process (how you found the information)
- Options that were evaluated and clearly rejected (capture the rejection reason in the chosen option's decision file, not as separate notes)
- Verbose comparisons that can be condensed to key differentiators

## Phase 4: AUTO-INDEX (Update the Index)

Update `.praxis/index.md` to reflect all changes:

1. Re-read the current `index.md`
2. Add entries for any new files created (with one-line summaries)
3. Update summaries for any files that were modified
4. Remove entries for any files that were deleted
5. Update the `**Updated:**` date

This step is **mandatory** — never skip it, even if changes seem minor.

## Closing

After saving and indexing, briefly tell the user what was saved:

"Saved to memory:
- Updated architecture.md with auth approach
- Created decision: 2026-02-23-auth-jwt.md
- Open questions noted: session management strategy"

If the exploration surfaced related topics worth exploring, mention them:
"Related topics you might want to explore next: session management, API rate limiting."
