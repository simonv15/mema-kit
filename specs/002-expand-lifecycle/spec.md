# Feature Specification: Full AI-Assisted Development Lifecycle

**Feature Branch**: `002-expand-lifecycle`
**Created**: 2026-02-27
**Status**: Draft
**Input**: Expand mema-kit from a memory protocol kit into a full AI-assisted development lifecycle tool — merging brainstormer's discovery phases into mema-kit, rationalizing skills to 12 under the `mema.` namespace, restructuring `.mema/` to support both product discovery and per-feature tracking, and enabling end-to-end workflow from vague idea to shipped code.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Build a New Project From Scratch (Priority: P1)

A developer has a vague idea — "something like Uber for dog walkers, maybe" — and no codebase yet. They open mema-kit and run through the discovery workflow to turn that idea into a structured project plan, then pick the first feature and implement it, all without leaving their development environment.

**Why this priority**: This is the headline scenario that differentiates mema-kit from every other AI coding tool. Existing tools assume you know what to build. This skill set starts before that.

**Independent Test**: Can be fully tested by starting from an empty directory, running the discovery workflow end-to-end, and confirming a structured project plan exists in `.mema/product/` and at least one feature directory exists under `.mema/features/` — with no implementation code written yet.

**Acceptance Scenarios**:

1. **Given** an empty project directory, **When** the user runs `/mema.seed` with a raw idea, **Then** the idea is captured in `.mema/product/seed.md` and the user is guided toward `/mema.clarify`
2. **Given** a seed is saved, **When** the user runs `/mema.clarify`, **Then** Claude asks 3–5 targeted questions and saves the clarified intent to `.mema/product/clarify.md`
3. **Given** clarification is complete, **When** the user runs `/mema.research`, **Then** Claude searches the web for competitors, market context, and technical options, saving findings to `.mema/product/research.md`
4. **Given** research is complete, **When** the user runs `/mema.challenge`, **Then** Claude stress-tests the idea and saves risks and assumptions to `.mema/product/challenge.md`
5. **Given** all discovery phases are complete, **When** the user runs `/mema.roadmap`, **Then** a prioritized feature list is saved to `.mema/product/roadmap.md`, with each feature allocated a numbered directory under `.mema/features/`

---

### User Story 2 - Add a Feature to an Existing Project (Priority: P2)

A developer has an existing codebase. They want to add a new feature. They pick it from the roadmap (or describe it fresh), run through the specification and implementation workflow, and ship it — with full memory of the project's architecture and past decisions informing every step.

**Why this priority**: This is the day-to-day use case for most developers. Discovery is done once; feature implementation happens continuously.

**Independent Test**: Can be fully tested on any existing project by running `/mema.specify` for a feature and confirming a spec exists at `.mema/features/NNN-feature-name/spec.md`, independent of whether the discovery phases were ever run.

**Acceptance Scenarios**:

1. **Given** an existing project with a roadmap, **When** the user runs `/mema.specify`, **Then** Claude presents the feature list from `roadmap.md` and asks which feature to specify; a spec is created at `.mema/features/NNN-name/spec.md`
2. **Given** an existing project without a roadmap, **When** the user runs `/mema.specify "add search functionality"`, **Then** Claude generates a spec directly from the description, creating `.mema/features/001-add-search/spec.md`
3. **Given** a feature spec exists, **When** the user runs `/mema.plan`, **Then** a technical implementation plan is saved to `.mema/features/NNN-name/plan.md`, informed by `project/architecture.md` and past decisions
4. **Given** a plan exists, **When** the user runs `/mema.tasks`, **Then** an ordered task list is saved to `.mema/features/NNN-name/tasks.md`
5. **Given** tasks exist, **When** the user runs `/mema.implement`, **Then** Claude executes one task at a time, updating `status.md` after each step and saving lessons learned to `agent/lessons.md`

---

### User Story 3 - Resume Work Across Sessions (Priority: P3)

A developer returns to a project after a day or a week with no context in their current session. They run a single command to reload all relevant context — where they were, what decisions were made, what's next — and continue without re-explaining anything.

**Why this priority**: Cold-start friction is the most common failure mode of AI-assisted development. Without this, every session starts from zero.

**Independent Test**: Can be fully tested by starting a new session, running `/mema.recall`, and verifying the output includes: project identity, active features with status, and the immediate next action — without any additional user input.

**Acceptance Scenarios**:

1. **Given** a project with memory, **When** the user runs `/mema.recall`, **Then** Claude loads the index and prints a summary covering project identity, active features, recent decisions, and what to run next
2. **Given** a feature is in-progress, **When** the user runs `/mema.recall`, **Then** that feature's current status and next task are prominently surfaced at the top
3. **Given** no `.mema/` directory exists, **When** the user runs `/mema.recall`, **Then** Claude suggests running `/mema.onboard` (existing project) or `/mema.seed` (new idea)

---

### User Story 4 - Onboard an Existing Codebase (Priority: P4)

A developer has an existing project without mema-kit memory. They want to start using the lifecycle workflow without disrupting their existing code. A single bootstrap command scans the project and populates the new memory structure.

**Why this priority**: Most developers won't start with mema-kit from day one. Onboarding existing projects is essential for adoption.

**Independent Test**: Can be fully tested on any existing codebase by running `/mema.onboard` and confirming `.mema/project/architecture.md` and `.mema/index.md` are created with accurate, project-specific content — not placeholder text.

**Acceptance Scenarios**:

1. **Given** an existing project, **When** the user runs `/mema.onboard`, **Then** Claude scans the project and populates `project/architecture.md`, `project/requirements.md`, and `index.md` with real content
2. **Given** `/mema.onboard` has already been run, **When** it is run again, **Then** Claude updates stale entries and leaves accurate ones unchanged
3. **Given** a project with existing documentation, **When** `/mema.onboard` runs, **Then** the generated memory reflects the actual documented architecture, not generic defaults

---

### Edge Cases

- What happens when a user runs `/mema.research` without running `/mema.seed` first? — Skill warns and offers to accept an inline description or run seed first.
- What happens when `/mema.research` cannot access the web? — Skill informs the user, offers to proceed using training knowledge, and notes the limitation in `research.md`.
- What happens when the implementation diverges from the spec? — `/mema.implement` notes the divergence in `status.md` and prompts the user to update the spec or the plan before continuing.
- What happens when `.mema/features/` has dozens of features? — `/mema.recall` surfaces only active features; completed ones live in `archive/`.
- What happens when a user skips discovery and goes straight to `/mema.specify`? — Fully supported; discovery is optional for users who already know what to build.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST support an unbroken workflow from raw idea to shipped code without the user switching tools.
- **FR-002**: All discovery phase outputs MUST be saved to `.mema/product/` and be readable by all downstream skills.
- **FR-003**: Each feature MUST have a self-contained numbered directory under `.mema/features/` containing spec, plan, tasks, and status.
- **FR-004**: `/mema.specify` MUST work both when a roadmap exists (presenting feature choices) and when it does not (accepting a fresh description directly).
- **FR-005**: `/mema.recall` MUST restore working context in a single command, surfacing the active feature and next action without requiring additional input.
- **FR-006**: `/mema.research` MUST use real-time web search to gather competitor, market, and technical information.
- **FR-007**: All 12 skills MUST be in the `mema.` namespace and distributed via `npx mema-kit`.
- **FR-008**: Every skill MUST follow the 4-phase memory lifecycle (AUTO-LOAD → WORK → AUTO-SAVE & CURATE → AUTO-INDEX).
- **FR-009**: `/mema.onboard` MUST produce the same `.mema/` directory structure whether run on a new or existing project.
- **FR-010**: Completed features MUST be archivable — moved from `.mema/features/` to `.mema/archive/` with lessons and patterns preserved in `agent/`.

### Key Entities

- **Product Memory** (`product/`): Discovery phase outputs. Files: `seed.md`, `clarify.md`, `research.md`, `challenge.md`, `roadmap.md`. Written once per project during discovery; may be updated via re-running individual skills.
- **Feature** (`features/NNN-name/`): Self-contained unit of work. Files: `spec.md`, `plan.md`, `tasks.md`, `status.md`. Numbered sequentially. Status progresses: `pending` → `in-progress` → `complete`.
- **Project Knowledge** (`project/`): Stable facts about the codebase. Files: `architecture.md`, `requirements.md`, `decisions/YYYY-MM-DD-name.md`. Updated when the codebase changes.
- **Agent Knowledge** (`agent/`): Cross-project, cross-session knowledge. Files: `lessons.md`, `patterns.md`. Accumulates over time across projects.
- **Index** (`index.md`): Rebuildable pointer map across all memory sections. Never the source of truth — rebuilt from directory scan if missing.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A developer with a vague idea can produce a prioritized feature list in a single session — measured by completing the full discovery workflow (seed → roadmap) without switching tools or writing any code.
- **SC-002**: A developer can identify their next action after any interruption in under 60 seconds — measured from running `/mema.recall` to knowing what to run next.
- **SC-003**: All 12 skills install and are ready to use from a single `npx mema-kit` command — zero additional setup required.
- **SC-004**: Context from earlier phases is demonstrably reflected in later phases — specs reference research findings; plans reference architecture decisions; implementations reference plan tasks.
- **SC-005**: Re-running any skill produces the same end state as running it once — zero data loss or duplication on second run.

## Assumptions

- Web search is available within Claude Code and treated as a hard requirement for `/mema.research`.
- The `mema.` namespace prefix applies to all 12 skills without exception.
- `.mema/` remains gitignored by default; `project/` is optionally committed by the user; `.claude/skills/` is always committed.
- `/mema.onboard` on a brand-new empty directory creates the directory structure only — it does not trigger discovery (that is `/mema.seed`'s job).
- brainstormer's `/review` skill is intentionally omitted — idempotency (Constitution Principle III) means any skill can be re-run to update its output.
- The 12-skill count is a ceiling, not a floor — adding a 13th skill requires explicit justification against Principle V (Simplicity).
