# Tasks: Full AI-Assisted Development Lifecycle

**Input**: Design documents from `/specs/002-expand-lifecycle/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅, quickstart.md ✅

**Tests**: Not requested — skills are markdown instructions, verified by manual invocation.

**Organization**: Tasks grouped by user story. US3 (recall) and US4 (onboard) are in the Foundational phase because updated existing skills are prerequisites for testing new ones.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no write conflicts)
- **[Story]**: US1 = new project from scratch, US2 = add a feature, US3 = resume work, US4 = onboard existing

---

## Phase 1: Setup

**Purpose**: Confirm baseline before any edits — avoid assumptions about what currently exists.

- [x] T001 Scan `skills/`, `templates/`, and `bin/cli.js` to confirm baseline: 5 skills present, `templates/project-memory/` + `templates/agent-memory/` + `templates/task-memory/` exist, no `templates/product/` or `templates/features/` directories

---

## Phase 2: Foundational — Blocking Prerequisites

**Purpose**: Protocol update + template restructure + CLI update + updated existing skills. All must be complete before any new skill can be written or tested.

**⚠️ CRITICAL**: T002 must complete before T003–T012. T003/T004/T005 should complete before T008/T010/T011.

- [x] T002 Update `skills/_memory-protocol.md` — replace all `project-memory/` → `project/`, `task-memory/` → `features/`, `agent-memory/` → `agent/` throughout; rewrite the index format section to show the new 4-section format: Active Features / Product Discovery / Project Knowledge / Agent Knowledge (see data-model.md for exact format)
- [x] T003 [P] Create `templates/product/` directory with 5 template files: `seed.md`, `clarify.md`, `research.md`, `challenge.md`, `roadmap.md` — each with title heading, in-body metadata (`**Status:** active | **Updated:** YYYY-MM-DD`), and 2–3 placeholder section headings matching their purpose
- [x] T004 [P] Create `templates/features/feature/` directory with 4 template files: `spec.md` (purpose + scenarios + requirements), `plan.md` (technical design), `tasks.md` (ordered checklist), `status.md` (status field: `pending`/`in-progress`/`complete`, progress log section)
- [x] T005 [P] Rename `templates/project-memory/` → `templates/project/` and `templates/agent-memory/` → `templates/agent/` — move all existing files into the renamed directories; remove `templates/task-memory/` (replaced by `templates/features/`)
- [x] T006 [P] Update `templates/index.md` — rewrite to the 4-section format (Active Features, Product Discovery, Project Knowledge, Agent Knowledge) per the example in `specs/002-expand-lifecycle/data-model.md`
- [x] T007 [P] Update `bin/cli.js` — add 7 new skill directory names to the copy list: `mema.seed`, `mema.clarify`, `mema.research`, `mema.challenge`, `mema.roadmap`, `mema.specify`, `mema.tasks`
- [x] T008 Update `skills/mema.onboard/SKILL.md` — (a) update `.mema/` creation to use new structure: `product/`, `features/`, `project/`, `agent/` directories; (b) add migration step: if `project-memory/` exists rename to `project/`; if `agent-memory/` exists rename to `agent/`; if `task-memory/` exists rename to `features/`; inform user of each migration; (c) NOOP on already-migrated structure; (d) update all internal path references
- [x] T009 [P] Update `skills/mema.recall/SKILL.md` — (a) add Active Features section at top: scan `features/*/status.md` for non-complete features, display name + status + next task for each; (b) update all path references (`project-memory/` → `project/`, `agent-memory/` → `agent/`); (c) update fallback: if no `.mema/` suggest `/mema.onboard` for existing projects or `/mema.seed` for new ideas; (d) full mode: load `product/roadmap.md` summary if exists
- [x] T010 [P] Update `skills/mema.plan/SKILL.md` — change scope from "break goal into specs" to feature-level technical design: (a) AUTO-LOAD: read `index.md`, `features/NNN/spec.md` (ask user which feature if multiple in-progress), `project/architecture.md`, `project/decisions/`, `agent/lessons.md`; (b) WORK: produce technical design (approach, data entities, key decisions, file structure) for the selected feature; (c) AUTO-SAVE: write to `features/NNN/plan.md`; guard: if spec.md missing, prompt to run `/mema.specify` first
- [x] T011 [P] Update `skills/mema.implement/SKILL.md` — (a) change input: read `features/NNN/tasks.md` instead of `task-memory/[name]/plan.md`; (b) update status tracking: write to `features/NNN/status.md`; (c) update archive: on completion move `features/NNN/` to `archive/NNN/`; (d) update all path references throughout; (e) update AUTO-LOAD to read `features/NNN/plan.md` and `features/NNN/status.md`
- [x] T012 [P] Update `skills/mema.create-skill/SKILL.md` — replace `agent-memory/` → `agent/` and `project-memory/` → `project/` in: AUTO-LOAD section (patterns.md path), AUTO-SAVE section (patterns.md path), and the AUTO-LOAD hints keyword mapping in Step 2

**Checkpoint**: Foundation complete. All path references are consistent. `npx mema-kit` would install all 12 skills. Existing skills work with new `.mema/` structure.

---

## Phase 3: User Story 1 — Build a New Project From Scratch (Priority: P1) 🎯 MVP

**Goal**: A developer with a vague idea can run five skills end-to-end and produce a structured project plan with feature directories — without writing any code.

**Independent Test**: Start from an empty directory; run seed → clarify → research → challenge → roadmap. Verify `.mema/product/` has all 5 files and `.mema/features/` has numbered directories. No code written.

- [x] T013 [US1] Write `skills/mema.seed/SKILL.md` — AUTO-LOAD: read `index.md` (or skip if no `.mema/`, this is the first skill); WORK: capture raw idea from inline arg or prompt, mirror it back to user, save to `.mema/product/seed.md` with metadata; on re-run ask to confirm overwrite; guide user to run `/mema.clarify` next; AUTO-SAVE: seed.md is the record (NOOP for other files); AUTO-INDEX: update
- [x] T014 [US1] Write `skills/mema.clarify/SKILL.md` — AUTO-LOAD: read `index.md` + `product/seed.md`; guard: if seed.md missing, accept inline description or prompt for it; WORK: ask 3–5 targeted questions (problem, audience, motivation, scope, constraints), allow multiple rounds until clarified, save structured summary to `product/clarify.md`; on re-run: show current clarify.md and ask what to refine; AUTO-SAVE: ADD clarify.md; AUTO-INDEX: update
- [x] T015 [P] [US1] Write `skills/mema.research/SKILL.md` — AUTO-LOAD: read `product/seed.md` + `product/clarify.md`; optional focus area arg narrows searches; WORK: use WebSearch tool to find (1) existing solutions/competitors, (2) market context and size, (3) technical options; compile findings with source URLs into `product/research.md`; graceful degradation: if web search unavailable, inform user, proceed with training knowledge, flag limitation clearly in output; AUTO-SAVE: ADD research.md; AUTO-INDEX: update
- [x] T016 [P] [US1] Write `skills/mema.challenge/SKILL.md` — AUTO-LOAD: read all `product/` files that exist; WORK: (a) list key assumptions, mark each as validated or risky; (b) build risk register with severity (high/medium/low), likelihood, and mitigation for each risk; (c) identify blind spots — what hasn't been considered; (d) if critical risks found, suggest alternatives; save all to `product/challenge.md`; AUTO-SAVE: ADD challenge.md; AUTO-INDEX: update
- [x] T017 [US1] Write `skills/mema.roadmap/SKILL.md` — AUTO-LOAD: read all `product/` files + `index.md`; WORK: synthesize discovery outputs into (a) problem statement, (b) value proposition, (c) prioritized feature list with one-line description per feature, (d) MVP scope (smallest deliverable); save to `product/roadmap.md`; for each feature create `features/NNN-kebab-name/` directory (numbered 001, 002... in priority order) with a `status.md` set to `pending`; on re-run: update roadmap.md, do NOT recreate existing feature directories, only add new ones; AUTO-SAVE: ADD roadmap.md; AUTO-INDEX: update

**Checkpoint**: P1 complete. Full discovery workflow is functional and independently testable.

---

## Phase 4: User Story 2 — Add a Feature to an Existing Project (Priority: P2)

**Goal**: A developer can pick any feature (from roadmap or fresh description), generate a spec, plan, and task list, then implement it step by step — with project memory informing every step.

**Independent Test**: On any project with `.mema/` set up (with or without `product/`), run `/mema.specify` → `/mema.plan` → `/mema.tasks` → `/mema.implement`. Verify `features/001-name/` contains spec.md, plan.md, tasks.md, and status.md with progress after implement runs.

- [x] T018 [US2] Write `skills/mema.specify/SKILL.md` — AUTO-LOAD: read `index.md`, `product/roadmap.md` (if exists), `product/research.md` (if exists), `project/architecture.md` (if exists); WORK: if roadmap exists → present numbered feature list and ask which to specify; if no roadmap or inline description given → generate spec from description; scan `features/` for current max number, use N+1 for new feature; create `features/NNN-name/spec.md` with: purpose, user scenarios with acceptance criteria, functional requirements, constraints; if feature directory already exists → show current spec and offer to update specific sections (idempotent); AUTO-SAVE: ADD or UPDATE spec.md; AUTO-INDEX: update
- [x] T019 [US2] Write `skills/mema.tasks/SKILL.md` — AUTO-LOAD: read `features/NNN/spec.md` + `features/NNN/plan.md`; guard: if plan.md missing, prompt to run `/mema.plan` first; WORK: generate ordered implementation task list with exact file paths for each task, grouped into phases (setup → core → polish); write to `features/NNN/tasks.md`; on re-run: warn if tasks are partially checked off, ask before regenerating; AUTO-SAVE: ADD or UPDATE tasks.md; AUTO-INDEX: update

**Checkpoint**: P2 complete. Full feature workflow (specify → plan → tasks → implement) is functional. Both P1 and P2 work independently.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Documentation and project context updates.

- [x] T020 [P] Rewrite `docs/guide.md` — cover full lifecycle: (a) Quick Start for new projects (seed → roadmap → specify → implement); (b) Quick Start for existing projects (onboard → specify → implement); (c) one section per skill with usage example and output; (d) the full workflow diagram showing how all 12 skills connect through `.mema/`; (e) memory structure section describing new 4-section layout; (f) tips section updated for new workflow
- [x] T021 [P] Update `CLAUDE.md` — add to Active Technologies: "Markdown (skills), Node.js ≥ 16.7.0 (cli.js), Claude Code WebSearch (mema.research)"; add to Recent Changes: "002-expand-lifecycle: Added 7 new skills (seed, clarify, research, challenge, roadmap, specify, tasks); restructured .mema/ to product/, features/, project/, agent/; updated 5 existing skills; updated bin/cli.js to install all 12 skills"

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1 (T001)
    └── Phase 2 (T002 first, then T003–T012 in parallel after T002)
              └── Phase 3 (US1: T013 → T014 → {T015, T016} → T017)
              └── Phase 4 (US2: T018 → T019)
                        └── Phase 5 ({T020, T021} in parallel)
```

### Within Phase 2

```
T002 (protocol update — must be first)
  ├── T003 [P] (product templates)
  ├── T004 [P] (features templates)
  ├── T005 [P] (rename project/agent dirs)
  ├── T006 [P] (update index template)
  ├── T007 [P] (update cli.js)
  ├── T009 [P] (update recall)
  ├── T012 [P] (update create-skill paths)
  └── after T003/T004/T005:
      ├── T008   (update onboard — needs template structure)
      ├── T010 [P] (update plan — needs features/ path from T004)
      └── T011 [P] (update implement — needs features/ path from T004)
```

### User Story Dependencies

- **US1 (Phase 3)**: Sequential — seed first, clarify second (reads seed), then research and challenge can run in parallel (both read product/ files), roadmap last (reads all)
- **US2 (Phase 4)**: T018 (specify) → T019 (tasks). `mema.plan` (T010) is already done in Phase 2; T018/T019 are the remaining new skills for US2
- **US3 (recall)**: Done in Phase 2 as T009
- **US4 (onboard)**: Done in Phase 2 as T008

### Parallel Opportunities

```
# Phase 2 — after T002 completes:
Parallel batch 1: T003, T004, T005, T006, T007, T009, T012

# Phase 2 — after batch 1 completes:
Parallel batch 2: T008, T010, T011

# Phase 3 — after T014 completes:
Parallel batch 3: T015, T016

# Phase 5 — after all user story phases complete:
Parallel batch 4: T020, T021
```

---

## Implementation Strategy

### MVP (Phase 1 + 2 + 3 only — US1)

1. T001: Confirm baseline
2. T002: Update protocol (prerequisite)
3. T003–T007, T009, T012 in parallel
4. T008, T010, T011 in parallel
5. T013 → T014 → {T015, T016} → T017
6. **STOP**: Run quickstart.md Test 1 — verify full discovery workflow
7. Ship if validated

### Incremental Delivery

1. Foundation + US1 → discovery workflow works (new project path)
2. + US2 (T018, T019) → feature workflow works (existing project path)
3. + US3/US4 (already in Phase 2) → resume and onboard work
4. + Polish (T020, T021) → docs complete

### Note on Single-File Bottleneck

Phase 2 has multiple single-file updates (T008–T012), but they're all different files, so they run in parallel after T002. The one bottleneck: `_memory-protocol.md` (T002) must be the first thing written because every skill references it.

---

## Notes

- **Path consistency check**: After each skill is written, verify all `.mema/` paths use `product/`, `features/`, `project/`, `agent/` — not the old names. This is the most common mistake.
- **Discovery is optional**: Never make `product/*.md` files a hard guard in US2 skills (`mema.specify`, `mema.plan`, `mema.tasks`, `mema.implement`). They should work on any project that has run `/mema.onboard`.
- **Feature numbering**: T017 (roadmap) and T018 (specify) both create feature directories. Both must scan `features/` for the current max number before creating — never hardcode.
- **`bin/cli.js`**: T007 is easy to forget. After all 12 SKILL.md files exist, verify T007 was done and the list matches exactly.
