# Tasks: Enhanced /mema.create-skill

**Input**: Design documents from `/specs/001-enhance-create-skill/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅, quickstart.md ✅

**Tests**: Not explicitly requested — no test tasks included (Constitution Principle V: Simplicity; skills are markdown instructions, not executable code).

**Organization**: Tasks are grouped by user story. All changes target a single file: `skills/mema.create-skill/SKILL.md`. Because edits are sequential on one file, parallelization applies only to read-only prep tasks and separate-file documentation tasks.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files or read-only — no write conflict)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)

---

## Phase 1: Setup

**Purpose**: Establish a clear baseline before any edits begin.

- [x] T001 Read `skills/mema.create-skill/SKILL.md` end-to-end and annotate each section heading with what it currently does — confirm it matches the plan's baseline structure (Steps 1–5, no memory lifecycle sections)

---

## Phase 2: Foundational — Memory Lifecycle (Constitution Principle I)

**Purpose**: Wrap the existing Steps 1–5 with the mandatory mema-kit AUTO-LOAD / AUTO-SAVE / AUTO-INDEX lifecycle. This is required by Constitution Principle I and must be in place before any user story work begins.

**⚠️ CRITICAL**: These sections establish the skeleton that later tasks insert content into. Complete before Phase 3.

- [x] T002 Add `## AUTO-LOAD` section before Step 1 in `skills/mema.create-skill/SKILL.md` — instruct Claude to read `.mema/index.md`, handle missing index via Rebuild Procedure from `_memory-protocol.md`, then load `agent-memory/patterns.md` to check what skills already exist
- [x] T003 Add `## AUTO-SAVE & CURATE` section after Step 5 in `skills/mema.create-skill/SKILL.md` — instruct Claude to ADD a lightweight record to `agent-memory/patterns.md` containing skill name, complexity, purpose, action (created/enhanced/overwritten), and date; NOOP if no file was written (user cancelled)
- [x] T004 Add `## AUTO-INDEX` section after AUTO-SAVE in `skills/mema.create-skill/SKILL.md` — instruct Claude to re-read `.mema/index.md`, update the summary for `agent-memory/patterns.md` if it was modified, and update the `**Updated:**` date

**Checkpoint**: SKILL.md now has 8 top-level sections (AUTO-LOAD + Steps 1–5 + AUTO-SAVE + AUTO-INDEX). Memory lifecycle is compliant with Constitution Principle I.

---

## Phase 3: User Story 1 — Meaningful WORK Phase Generation (Priority: P1) 🎯 MVP

**Goal**: The WORK phase of every generated skill contains purposeful, actionable steps derived from the described purpose — zero `[placeholder]`-style text.

**Independent Test**: Run `/mema.create-skill`, provide a descriptive purpose (e.g., "scan the git log and extract architectural lessons"), approve the preview, then read the output `.claude/skills/[name]/SKILL.md` — the WORK phase must contain zero `[First action]`-style brackets.

- [x] T005 [US1] Enhance Step 2 in `skills/mema.create-skill/SKILL.md` with a WORK-generation directive: instruct Claude to (a) decompose the purpose into 2–5 concrete developer actions, (b) write each as an imperative instruction sentence, (c) if the purpose contains multiple distinct concerns (multiple verbs, "and", conditional logic) organize into `### 2a:`, `### 2b:` sub-sections
- [x] T006 [US1] Add AUTO-LOAD hint derivation instructions to Step 2 in `skills/mema.create-skill/SKILL.md` — instruct Claude to scan the purpose description for domain keywords and map them to relevant `.mema/` file paths (e.g., "decision/compare/choose" → `project-memory/decisions/`; "pattern/reuse/template" → `agent-memory/patterns.md`; "implement/build/create" → active task-memory if present), annotating each hint with a brief reason
- [x] T007 [US1] Add a pre-proceed validation rule at the end of Step 2 in `skills/mema.create-skill/SKILL.md` — instruct Claude to scan the generated WORK phase for any remaining `[...]`-style placeholder text and replace it before moving on; only proceed to Step 2.5 when zero placeholders remain

**Checkpoint**: User Story 1 complete — generated skills have purposeful WORK phases. Can be validated independently by invoking the enhanced skill in Claude Code.

---

## Phase 4: User Story 2 — Preview Before Writing (Priority: P2)

**Goal**: No SKILL.md file is written to disk until the user explicitly approves the generated content.

**Independent Test**: Run `/mema.create-skill`, complete the interview, reach the preview step — confirm no file exists at `.claude/skills/[name]/SKILL.md` yet. Reply CANCEL. Confirm the file still does not exist. Reply APPROVE on a second run. Confirm the file now exists and matches what was previewed.

- [x] T008 [US2] Insert `## Step 2.5: Draft Review` section between Step 2 and Step 3 in `skills/mema.create-skill/SKILL.md` with these instructions: (a) render the complete generated SKILL.md inside a fenced markdown code block, (b) ask "Does this look correct? Reply **APPROVE** to write the file, describe a specific change to revise, or **CANCEL** to exit without writing", (c) on a change request — apply the change to the named section only, re-render the full draft, and repeat the APPROVE/CANCEL/revise prompt; limit revision loops to 3 before warning the user, (d) on CANCEL — exit cleanly with no file operations, (e) on APPROVE — proceed to Step 3

**Checkpoint**: User Story 2 complete — file write is gated behind explicit user approval. Can be validated independently.

---

## Phase 5: User Story 3 — Update Existing Skills (Priority: P3)

**Goal**: Re-running `/mema.create-skill` on an existing skill name presents an Enhance/Overwrite/Cancel choice rather than a blunt overwrite warning.

**Independent Test**: (a) Create any skill (completes P2 dependency). (b) Re-run `/mema.create-skill` with the same name — confirm the three-choice prompt appears and no file is modified until a choice is made. (c) Choose Cancel — confirm file is unchanged. (d) Choose Enhance with a directive — confirm only the named section differs in the output file.

- [x] T009 [US3] Add reserved-name protection check to Step 1 in `skills/mema.create-skill/SKILL.md` — instruct Claude to compare the provided name against the protected list (`onboard`, `recall`, `plan`, `implement`, `create-skill`) and, if it matches, warn the user: "This name matches a built-in mema-kit skill. Using it in `.claude/skills/` will shadow the built-in. Continue? (yes/no)" before proceeding; if name is not kebab-case, convert it automatically and inform the user
- [x] T010 [US3] Enhance Step 3 in `skills/mema.create-skill/SKILL.md` with an existence check: before writing, check if `.claude/skills/[name]/SKILL.md` already exists; if it does — read and display the `description` frontmatter value and all `## Phase` / `## Step` / `## AUTO-*` headings (not body content), then present: "(1) Enhance existing — apply a described change (2) Overwrite — start fresh with preview (3) Cancel — exit without changes"
- [x] T011 [US3] Add Enhance mode instructions to Step 3 in `skills/mema.create-skill/SKILL.md` — when the user selects option 1 (Enhance): ask "What specifically should I change?", apply the described change to the named section only, preview the modified file (reuse Step 2.5 Draft Review flow), write only after APPROVE; when the user selects option 2 (Overwrite): discard the existing content and run the full Steps 1–2.5 flow from scratch; when the user selects option 3 (Cancel): exit with no file changes

**Checkpoint**: User Story 3 complete — all three stories are independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final verification and documentation.

- [x] T012 Read the complete `skills/mema.create-skill/SKILL.md` end-to-end after all edits — verify: (a) description frontmatter present and accurate, (b) AUTO-LOAD / Steps 1–5 (with 2.5) / AUTO-SAVE / AUTO-INDEX sections all present in correct order, (c) no `[placeholder]`-style text, (d) all memory paths use `.mema/` prefix, (e) references `_memory-protocol.md` for curation rules, (f) does not duplicate memory protocol content, (g) total line count under ~250
- [x] T013 [P] Update `docs/guide.md` to document the preview step (Step 2.5) and the update-existing-skill flow (three-choice prompt) — find the existing section that describes `/mema.create-skill` and add a brief explanation of both new behaviors
- [x] T014 Run the manual test scenarios from `specs/001-enhance-create-skill/quickstart.md` (Tests A, B, C, D) against the enhanced skill and confirm all pass

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 baseline read — BLOCKS all user stories
- **User Stories (Phase 3, 4, 5)**: All depend on Phase 2 completion
  - US1 (Phase 3), US2 (Phase 4), US3 (Phase 5) must be done sequentially (same file, sequential edits)
- **Polish (Phase 6)**: Depends on all three user stories complete

### User Story Dependencies

Since all changes target the same file, user stories are implemented sequentially:

```
Phase 1 → Phase 2 → Phase 3 (US1) → Phase 4 (US2) → Phase 5 (US3) → Phase 6
```

US1 must precede US2 because Step 2.5 (Draft Review) references the WORK phase generated in the enhanced Step 2. US2 must precede US3 because the Overwrite branch in Step 3 reuses the Step 2.5 Draft Review flow.

### Within Each Phase

- T005 → T006 → T007 (sequential — all modify Step 2 of the same file)
- T009 → T010 → T011 (sequential — T010/T011 both modify Step 3; T009 modifies Step 1 but must be done before T010 to establish name validation context)
- T012 and T013 are independent (T012: same file as implementation; T013: different file — docs/guide.md) so they can run in parallel
- T014 must come after T012 and T013

### Parallel Opportunities

```
# Phase 6 — two tasks can run in parallel:
Task T012: Verify skills/mema.create-skill/SKILL.md
Task T013: Update docs/guide.md
```

All other tasks are sequential (single-file modifications).

---

## Parallel Example: Phase 6

```
# Launch both together (different files, no dependencies):
Task T012: "Read complete skills/mema.create-skill/SKILL.md and verify all checklist items"
Task T013: "Update docs/guide.md to document preview and enhance-existing behavior"

# Wait for both, then run:
Task T014: "Run manual tests from quickstart.md"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001)
2. Complete Phase 2: Foundational — Memory Lifecycle (T002–T004)
3. Complete Phase 3: User Story 1 — WORK generation (T005–T007)
4. **STOP and VALIDATE**: Run Test A from quickstart.md (new skill, full flow) — verify WORK phase has no placeholders
5. Ship P1 if validated

### Incremental Delivery

1. MVP: US1 → generated skills have purposeful WORK phases
2. +US2 → preview gate before any file write
3. +US3 → update-existing-skill capability
4. +Polish → verified and documented

### Note on Single-File Constraint

This project modifies exactly one source file. There is no "parallel team" strategy — all phases must be executed sequentially by one agent to avoid file conflicts.

---

## Notes

- All edits are to `skills/mema.create-skill/SKILL.md` — commit after each phase checkpoint to keep changes reviewable
- [P] tasks only appear in Phase 6 (T012/T013) where files differ
- Each user story checkpoint is independently testable per quickstart.md scenarios
- Avoid adding speculative features (Principle V) — every added instruction must map to a spec requirement
- The ~250 line budget for SKILL.md: current file is ~243 lines; the enhancements will add content, so be concise in instruction wording
