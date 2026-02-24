# 05 — Explore Skill

**Produces:** `skills/explore/SKILL.md`
**Milestone:** 2
**Dependencies:** 01-memory-protocol, 02-templates, 03-kickoff-skill (`.praxis/` must exist)

---

## What This Skill Does

`/explore` is the research command. The user asks a question — technical, architectural, business-related, anything — and the agent researches it thoroughly, then **auto-saves curated findings to `.praxis/`**.

This is the first skill that exercises the **full memory lifecycle**: load existing context → do work → save curated knowledge → update index. Getting `/explore` right is critical because it sets the pattern for all subsequent skills.

Example usage:
```
/explore what tech stack should I use for a task manager REST API?
/explore how should we handle authentication?
/explore what's the best testing strategy for Fastify routes?
```

---

## Key Design Decisions

### 1. Where exploration output goes: project-memory vs. task-memory

**Decision: The agent decides based on the scope of the exploration.**

This is the trickiest routing decision in the entire system. Some explorations are project-wide ("what database should we use?") and belong in `project-memory/`. Others are task-specific ("how should the user endpoint handle pagination?") and belong in `task-memory/`.

Rules for the agent:

| Exploration scope | Where it goes | Examples |
|-------------------|--------------|----------|
| **Project-wide** (affects the whole project, not one task) | `project-memory/` | Tech stack, auth strategy, database choice, deployment approach, coding conventions |
| **Task-specific** (relates to a specific feature or task) | `task-memory/<task-name>/` | API endpoint design, component structure, specific algorithm choice |
| **Both** (project-wide decision discovered during task work) | Decision in `project-memory/decisions/`, context in `task-memory/` | "While exploring the user API, we decided the whole project should use JWT" — decision goes to project-memory, task context stays in task-memory |

Reasoning:
- Project-wide knowledge (architecture, tech stack) is relevant to many future tasks. Storing it in `project-memory/` ensures it shows up in the index for any task.
- Task-specific context (exploration for one feature) is only relevant to that task. Storing it in `task-memory/<task>/` keeps it scoped and easy to archive later.
- The "both" case is common: you're exploring a task and discover a project-wide insight. The skill handles this by writing to both locations.

### 2. How to name task directories

**Decision: Use a short kebab-case name derived from the user's request.**

Reasoning:
- The user says "/explore how should the user CRUD endpoints work?" — the task name becomes `user-crud` or `user-endpoints`.
- Kebab-case is consistent with the skill naming convention.
- Short names (2-3 words) keep directory paths readable and index entries scannable.
- The agent picks the name by extracting the core noun from the user's request. If ambiguous, it asks the user.
- If a task directory with that name already exists (from a previous `/explore` or `/plan-docs`), the agent adds to the existing directory instead of creating a new one. This is how multi-session context accumulates.

### 3. Decision files: when to create them

**Decision: Create a decision file whenever the exploration leads to a concrete choice.**

Reasoning:
- Not every exploration produces a decision. "Explore how pagination works in Fastify" might produce context (findings) but no decision (nothing was chosen).
- But "Explore what database to use" almost always produces a decision. The agent should create a `decision.md` file using the template when a clear choice is made.
- The heuristic: if the exploration's conclusion is "we should use X because Y", that's a decision. If the conclusion is "here are the options and their trade-offs", that's context (the decision hasn't been made yet).
- Decision files go in `project-memory/decisions/` with timestamp naming: `YYYY-MM-DD-short-name.md`.

### 4. How deep to explore

**Decision: The agent explores thoroughly but stays focused on the user's question.**

Reasoning:
- A shallow exploration ("use PostgreSQL") isn't valuable — it doesn't capture the reasoning.
- An unbounded exploration ("let me also research caching, load balancing, and deployment") wastes tokens and goes beyond what the user asked.
- The sweet spot: answer the user's question with enough depth to make a decision. Compare 2-4 options, analyze trade-offs, make a recommendation with reasoning.
- If the exploration reveals related questions ("you need auth, but we haven't decided on auth yet"), note them in the "Open Questions" section of the context file rather than exploring them immediately. The user can run `/explore` again for those.

### 5. Handling the first exploration (no prior context)

**Decision: When index.md is empty or has only starter entries, proceed normally — the skill works without prior context.**

Reasoning:
- The first `/explore` in a new project has no context to load. The index has only the empty starter entries from `/kickoff`.
- This is fine — the agent simply skips the loading phase and proceeds directly to research.
- After the first exploration, the index has entries and future explorations can load context.
- There's no special "first run" logic needed. The skill's loading phase naturally handles "nothing relevant found" by loading nothing.

### 6. What tools the agent should use for research

**Decision: Let the agent use all available tools — web search, codebase reading, file exploration — without prescribing a specific research method.**

Reasoning:
- Different explorations need different tools. "What database to use?" benefits from web search. "How is auth currently implemented?" benefits from codebase reading. "What testing patterns does this framework support?" benefits from both.
- Prescribing a specific research method would limit the agent's effectiveness. Instead, we tell it the goal (research the topic thoroughly) and let it choose the right tools.
- The SKILL.md should mention that all tools are available (so the agent doesn't self-limit) but not mandate any specific ones.

---

## Implementation Guide

### Step 1: Create the SKILL.md file structure

```
skills/
└── explore/
    └── SKILL.md
```

### Step 2: Write the SKILL.md

The skill has four phases matching the memory lifecycle:
1. **AUTO-LOAD** — read index, load relevant context
2. **WORK** — research the user's question
3. **AUTO-SAVE** — save findings and decisions to `.praxis/`
4. **AUTO-INDEX** — update index.md

### Step 3: Test the memory cycle

Run `/explore` 3-5 times on different topics. Verify:
- Context files are saved with the correct template format
- Decision files are created when appropriate
- The index is updated after each run
- The second exploration loads context from the first
- Dead-end explorations are pruned (not accumulated)

### Step 4: Test the routing logic

Verify that project-wide explorations go to `project-memory/` and task-specific explorations go to `task-memory/`.

---

## Full SKILL.md Content

```markdown
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
```

---

## Design Notes

### Why the agent briefs the user on loaded context

The "I see we're using Fastify + PostgreSQL" briefing serves two purposes:
1. **Transparency.** The user sees what context the agent loaded, so they can correct mistakes ("actually we switched to Express").
2. **Priming.** By stating the context aloud, the agent "commits" to using it in its research, reducing the chance it ignores loaded context and researches from scratch.

### Why not ask the user to confirm what to save?

The save step is automatic — the agent decides what to save based on the curation rules, without asking the user "should I save this?" Reasoning:
- Asking for confirmation on every save breaks the flow. The user would have to review memory files they don't care about.
- The memory protocol's rules are deterministic enough that the agent consistently makes good decisions.
- If the agent saves something wrong, the user can edit `.praxis/` files directly. This is the "correct wrong memories is manual" design from the plan.
- The brief "Saved to memory: ..." summary gives the user visibility without requiring action.

### How multi-session exploration works

Session 1: `/explore what database to use?` → saves tech-stack decision
Session 2: `/explore how to handle auth?` → loads tech-stack decision (relevant), explores auth with that context, saves auth decision
Session 3: `/explore what testing framework?` → loads tech-stack + auth decisions (both relevant to testing), explores with full context

Each session builds on the previous one. The index grows, and each new exploration automatically gets richer context. This is the compounding value of the memory system.

### The "relates to" section in context.md

The context template has a "Relates To" section for cross-references between memory files. This helps the agent build a mental model of how knowledge connects:
- `context.md` for user-auth relates to `decisions/2026-02-23-tech-stack.md`
- This tells future sessions that auth and tech stack are connected — changing one might affect the other

Cross-references are light-touch (just file paths, not bidirectional links). The agent maintains them as part of the save step, adding links when relationships are obvious.
