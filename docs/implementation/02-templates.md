# 02 — Memory File Templates

**Produces:** `templates/decision.md`, `templates/context.md`, `templates/plan.md`, `templates/lessons.md`, `templates/status.md`, `templates/index.md`
**Milestone:** 1
**Dependencies:** 01-memory-protocol (templates enforce the metadata format and curation rules defined there)

---

## What Templates Do

Templates are strict markdown structures that the agent fills in when creating new memory files. They live in two places:

1. **`templates/` in the praxis-kit repo** — The source files, version-controlled.
2. **`.praxis/_templates/` in the user's project** — Copied there by `/kickoff`. The agent reads these when creating new memory files.

### Why strict templates?

**Decision: Constrain the agent's writing with required sections rather than letting it write free-form.**

Reasoning:
- The biggest risk with agent-curated memory is **quality inconsistency**. Without templates, the agent might write a decision as a single paragraph one time and as a detailed analysis another time. Or it might forget to include the reasoning. Or it might invent a different structure each time.
- Templates solve this by giving the agent a fill-in-the-blanks structure. It's much easier for an LLM to fill sections than to invent a good structure from scratch.
- Templates also make the output predictable for humans reading `.praxis/` files — you always know where to find the "why" in a decision file.
- The templates include brief placeholder comments (like `<!-- Why this decision was made -->`) that guide the agent on what belongs in each section. These comments are invisible in rendered markdown but visible when the agent reads the raw file.

Alternative considered: No templates — just let the agent write free-form markdown guided by the memory protocol's instructions. Rejected because testing showed free-form generation produces inconsistent quality, especially for decisions where the "why" is often omitted under time pressure.

### Why HTML comments for placeholders instead of example text?

**Decision: Use `<!-- description -->` comments, not `[Write your reasoning here]` placeholder text.**

Reasoning:
- HTML comments are invisible in rendered markdown. If the agent accidentally leaves a placeholder, it doesn't clutter the rendered output.
- Bracket placeholders (`[Like this]`) can be confused with actual content, especially by LLMs. An agent might leave `[reasoning]` in the file thinking it's a valid section.
- HTML comments are the standard way to include invisible guidance in markdown files.

---

## Template Designs

### design principles applied to all templates

1. **Metadata first.** Every template starts with a title and the in-body metadata line. This ensures the agent always writes metadata (it's part of the template, not a separate instruction to remember).
2. **Sections are required but content is flexible.** The section headings are fixed, but what the agent writes within them can vary by context.
3. **Templates are short.** Each template is under 30 lines. Longer templates would be harder for the agent to fill consistently, and the filled files would bloat the context window.
4. **No YAML frontmatter.** Consistent with the metadata decision in the memory protocol.

---

### Template 1: `decision.md`

**Purpose:** Records a decision with full reasoning. This is the most important template — decisions persist longest and are loaded most often.

**Design decisions:**

- **"Options Considered" section is required.** Even if the user has a clear preference, documenting what was evaluated (and rejected) prevents future sessions from re-exploring the same options. This is the single biggest context-savings feature — without it, the agent would re-research decisions already made.
- **"Consequences" section captures trade-offs.** Every decision has downsides. Recording them helps future sessions understand constraints and avoid surprise ("we chose SQLite for simplicity, knowing we'll need to migrate to PostgreSQL for multi-user").
- **File naming convention: `YYYY-MM-DD-short-name.md`** (e.g., `2026-02-23-tech-stack.md`). Timestamps avoid numbering conflicts. Short names make the index scannable.

```markdown
# [Decision Title]

**Status:** active | **Updated:** YYYY-MM-DD

## Context
<!-- What situation or question prompted this decision? What problem are we solving? -->

## Decision
<!-- What was decided? Be specific and concrete. -->

## Options Considered
<!-- What alternatives were evaluated? For each: name, brief description, and why it was chosen or rejected. -->

### Option A: [Name]
<!-- Brief description. Why chosen/rejected. -->

### Option B: [Name]
<!-- Brief description. Why chosen/rejected. -->

## Reasoning
<!-- Why this option was selected. What factors mattered most? What trade-offs were accepted? -->

## Consequences
<!-- What are the implications? What does this enable or constrain? Any known trade-offs or risks? -->
```

---

### Template 2: `context.md`

**Purpose:** Records exploration findings and research context for a task. This is the most frequently pruned file type — context accumulates fast and much of it becomes irrelevant once decisions are made.

**Design decisions:**

- **"Key Findings" is a bullet list, not prose.** Bullets are scannable. When the agent loads context in a future session, it needs to quickly extract the relevant facts, not read paragraphs.
- **"Open Questions" tracks what's unresolved.** This is critical for multi-session work. When a user returns to a task after a break, the agent immediately sees what's still pending — no guessing, no re-exploration.
- **No "Sources" section.** Sources (URLs, docs) are ephemeral and often break. If a specific source is critical, it should be mentioned inline in the findings. A dedicated section would encourage hoarding links that provide no future value.

```markdown
# [Topic] — Exploration Context

**Status:** active | **Updated:** YYYY-MM-DD

## Summary
<!-- 2-3 sentence overview of what was explored and the key takeaway. -->

## Key Findings
<!-- Bullet list of important facts, constraints, or insights discovered. Be specific and concise. -->

-
-
-

## Open Questions
<!-- What remains unresolved? What needs further exploration or a decision? -->

-
-

## Relates To
<!-- Links to related memory files (decisions, other context, plans). Use relative paths. -->

-
```

---

### Template 3: `plan.md`

**Purpose:** Records an implementation-ready plan for a task. This is the file `/gen-test` and `/implement` read as their primary input.

**Design decisions:**

- **Two-part structure: General Plan + Detailed Plan.** The general plan gives the big picture (architecture, approach, key decisions). The detailed plan is a step-by-step task list with specific files and functions. Separating them lets the agent load the right level of detail for the current need — `/gen-test` needs the general plan for test design, `/implement` needs the detailed plan for task execution.
- **Detailed plan uses a numbered task list with checkboxes.** Numbered for ordering (dependencies matter), checkboxes for progress tracking during `/implement`. The agent checks off tasks as it completes them.
- **Each task specifies the file(s) it touches.** This is what makes the plan "implementation-ready" — the agent doesn't have to figure out where code goes, the plan tells it explicitly.
- **"Dependencies" section is between tasks, not a separate block.** Each task can note what it depends on (e.g., "Step 3 requires Step 1 complete"). This is simpler than a separate dependency graph and sufficient for the typical 5-10 step plan.

```markdown
# [Task Name] — Implementation Plan

**Status:** active | **Updated:** YYYY-MM-DD

## General Plan
<!-- High-level approach: architecture decisions, component design, data flow. Keep it to 1-2 paragraphs or a short list. This should answer "what are we building and how does it fit together?" -->

## Detailed Plan
<!-- Step-by-step implementation tasks. Each step should be specific enough to implement directly. -->

### Step 1: [Action]
<!-- What to do, which files to create/modify, any dependencies on prior steps. -->
- Files: `path/to/file.ts`
- Details:

### Step 2: [Action]
- Files: `path/to/file.ts`
- Details:

### Step 3: [Action]
- Files: `path/to/file.ts`
- Details:

## Out of Scope
<!-- What this plan explicitly does NOT cover. Prevents scope creep during implementation. -->

-
```

---

### Template 4: `lessons.md`

**Purpose:** Records agent-learned lessons and reusable patterns. This file grows over time and gets consolidated periodically. It's read at the start of `/implement` so the agent avoids past mistakes.

**Design decisions:**

- **Single file (not one-per-lesson).** Lessons are small — typically one sentence plus an example. Creating a separate file for each lesson would bloat the directory and the index. A single file with entries under headers is more efficient.
- **Each lesson has a "Context" line.** "Drizzle needs explicit type casting" is more useful with context: "Discovered during task-crud implementation when PostgreSQL ENUM columns returned strings instead of typed values." The context helps the agent judge relevance in future sessions.
- **Patterns are separate from lessons.** Lessons are "things that went wrong or surprised me." Patterns are "reusable approaches that worked well." The distinction matters because patterns are loaded proactively (apply them) while lessons are loaded defensively (avoid them).

```markdown
# Agent Lessons

**Updated:** YYYY-MM-DD

<!-- Lessons learned during development. Each entry is a mistake, surprise, or hard-won insight that future sessions should know about. -->

## Lessons

### [Short Title]
<!-- One-sentence lesson. -->
- **Context:** <!-- When/how this was discovered. -->
- **Example:** <!-- Concrete code example or scenario if applicable. -->

---

<!-- Add new lessons above this line. When entries exceed ~30, consolidate related lessons under grouped headers. -->
```

**And for patterns (separate file, same directory):**

```markdown
# Agent Patterns

**Updated:** YYYY-MM-DD

<!-- Reusable patterns and approaches that worked well. Load these during /implement to apply proven solutions. -->

## Patterns

### [Pattern Name]
<!-- What this pattern solves and when to use it. -->
- **Structure:** <!-- How the pattern is organized (e.g., file layout, function signatures). -->
- **Example:** <!-- Concrete usage example. -->

---

<!-- Add new patterns above this line. -->
```

---

### Template 5: `status.md`

**Purpose:** Tracks a task's completion state. Created when a task starts, updated during `/implement`, used for archiving decisions.

**Design decisions:**

- **Minimal file.** Status doesn't need much — the task name, current state, and a list of completed/remaining steps. Keeping it small means the agent can check task state without loading a heavy file.
- **Completion checklist mirrors the plan.** The status file's checklist is derived from `plan.md`'s detailed steps. This provides a clear "done/not-done" view without duplicating the full plan details.
- **"Completed Date" is recorded.** This tells the archiving logic (in `/implement`) when the task finished, and helps with chronological ordering in the archive.

```markdown
# [Task Name] — Status

**Status:** active | **Updated:** YYYY-MM-DD

## Progress
<!-- Check off steps as they complete. These should mirror the plan's detailed steps. -->

- [ ] Step 1: [description]
- [ ] Step 2: [description]
- [ ] Step 3: [description]

## Notes
<!-- Any blockers, deviations from plan, or important observations during implementation. -->

## Completed
<!-- Date when all steps finished. Leave empty until done. -->
**Completed:**
```

---

### Template 6: `index.md` (initial state)

**Purpose:** This is not placed in `_templates/` — it's created directly by `/kickoff` as the initial `.praxis/index.md`. It's the empty starting state of the memory index.

**Design decisions:**

- **Pre-populated with section headers.** An empty file would give the agent no structure to follow. By including the four section headers (Active Tasks, Project Knowledge, Recent Decisions, Agent Lessons), we guide the agent on how to organize entries.
- **Includes a comment explaining the format.** The first time `/explore` runs, the agent needs to know how to add entries. The comment in the initial index shows the expected format.
- **Pre-includes architecture.md and requirements.md entries.** `/kickoff` creates these empty files, so the index should reference them from the start. This prevents the agent from thinking the project has no knowledge base yet.

```markdown
# Memory Index

**Updated:** YYYY-MM-DD

<!-- Format: - `file-path` — one-line summary -->

## Active Tasks

## Project Knowledge
- `project-memory/architecture.md` — Project architecture (not yet documented)
- `project-memory/requirements.md` — Project requirements (not yet documented)

## Recent Decisions

## Agent Lessons
```

---

## Implementation Guide

### Step 1: Create the `templates/` directory in the repo

```
praxis-kit/
└── templates/
    ├── decision.md
    ├── context.md
    ├── plan.md
    ├── lessons.md
    ├── patterns.md
    └── status.md
```

Note: `index.md` is NOT in `templates/` — it's generated by `/kickoff` directly because its initial content depends on the creation date.

### Step 2: Write each template file

Copy the template content from the sections above. Remove the design-commentary HTML comments (the ones that explain why the template is designed this way) and keep only the placeholder HTML comments (the ones that guide the agent on what to write).

For example, in `decision.md`, keep `<!-- What situation or question prompted this decision? -->` but remove the surrounding explanation about why the section exists.

### Step 3: Verify template quality

For each template, check:
1. **Does it have the metadata line?** (`**Status:** active | **Updated:** YYYY-MM-DD`)
2. **Are all sections required?** (no optional sections — the agent fills all of them)
3. **Are placeholder comments clear?** (a new Claude session should understand what to write in each section without external context)
4. **Is it under 30 lines?** (shorter templates are filled more consistently)

### Step 4: Test with an LLM

Give Claude a template and a scenario (e.g., "You decided to use PostgreSQL over SQLite for a REST API. Fill in this decision template."). Check:
- Does it fill every section?
- Does it write the metadata correctly?
- Is the "Options Considered" section actually listing alternatives?
- Is the "Reasoning" section explaining "why" rather than restating "what"?

---

## Design Notes

### Why no `architecture.md` or `requirements.md` template?

These two files are created by `/kickoff` as **near-empty starter files** (just a title and metadata line), not from templates. Reason: architecture and requirements are highly project-specific. A template with generic sections ("Frontend", "Backend", "Database") would either be wrong for most projects (not all have a frontend) or so generic it adds no value.

Instead, `/explore` fills these files organically as the user explores their project's architecture and requirements. The first `/explore` call might write "Node.js + Fastify + PostgreSQL" into architecture.md. A second call adds the auth approach. The file grows naturally to match the actual project.

### Why `patterns.md` is separate from `lessons.md`

Both live in `agent-memory/`, but they serve different purposes:
- **Lessons** = "things that went wrong or surprised me" — loaded defensively
- **Patterns** = "approaches that worked well" — loaded proactively

An agent implementing a new feature should apply known patterns (proactive) and avoid known pitfalls (defensive). Keeping them in separate files lets the agent load one without the other when only one is relevant.

### Why templates don't include example content

Earlier drafts included example content (e.g., "**Decision:** Use PostgreSQL for the database layer"). This was removed because:
1. LLMs sometimes leave example content in the output, mixing real data with template examples
2. Example content implies a specific project type (web API), which could bias the agent's writing for other project types (CLI tools, libraries)
3. The placeholder comments provide sufficient guidance without polluting the output
