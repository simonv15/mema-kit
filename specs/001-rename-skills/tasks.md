---

description: "Task list for renaming mema-kit skills to mema.* namespace"
---

# Tasks: Rename Skills to mema.* Namespace

**Input**: Design documents from `specs/001-rename-skills/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅

**Tests**: Not requested — validation is manual grep + install check per quickstart.md.

**Organization**: Tasks are grouped by user story. US1 (directory renames) blocks US2
and US3, but US2 and US3 can proceed in parallel once US1 is complete.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no shared state)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Each task includes the exact file path to edit

## Path Conventions

Repository root is `mema-kit/`. All paths below are relative to it.

---

## Phase 1: Setup

**Purpose**: Confirm starting state before making any changes.

- [x] T001 Verify current `skills/` directory contains exactly 5 old-named directories: `onboard/`, `recall/`, `plan/`, `implement/`, `create-skill/` — run `ls skills/` and confirm output

---

## Phase 2: User Story 1 — Namespaced Skill Invocation (Priority: P1) 🎯 MVP

**Goal**: Rename all five skill directories so `npx mema-kit` installs them under
`mema.*` names, making `/mema.onboard` etc. available in Claude Code.

**Independent Test**: After completing this phase, run `node bin/cli.js` in a clean
temp directory. Confirm `.claude/skills/` contains `mema.onboard/`, `mema.recall/`,
`mema.plan/`, `mema.implement/`, `mema.create-skill/` — and no old-named directories.

### Implementation for User Story 1

- [x] T00X [US1] Rename `skills/onboard/` to `skills/mema.onboard/` (move the directory; preserve SKILL.md inside)
- [x] T00X [P] [US1] Rename `skills/recall/` to `skills/mema.recall/` (move the directory; preserve SKILL.md inside)
- [x] T00X [P] [US1] Rename `skills/plan/` to `skills/mema.plan/` (move the directory; preserve SKILL.md inside)
- [x] T00X [P] [US1] Rename `skills/implement/` to `skills/mema.implement/` (move the directory; preserve SKILL.md inside)
- [x] T00X [P] [US1] Rename `skills/create-skill/` to `skills/mema.create-skill/` (move the directory; preserve SKILL.md inside)

**Checkpoint**: Run `ls skills/` — output MUST show only `mema.*` directories and
`_memory-protocol.md`. No old names. US1 is independently testable and complete here.

---

## Phase 3: User Story 2 — Internal Cross-Reference Consistency (Priority: P2)

**Goal**: Update the contents of each SKILL.md file so all skill command references
use the new `mema.*` names. Skills should not instruct users to run `/onboard` etc.

**Independent Test**: Run `grep -r "/onboard\|/recall\|/plan\|/implement\|/create-skill" skills/ --include="*.md"` — expected: zero results.

### Implementation for User Story 2

All T007–T011 tasks edit different files and can run in parallel after US1 is complete.

- [x] T00X [P] [US2] Update `skills/mema.onboard/SKILL.md` — replace all occurrences of `/onboard` → `/mema.onboard`, `/recall` → `/mema.recall`, `/create-skill` → `/mema.create-skill` (also update the `# /onboard` heading on line 5 and the description on line 440–442)
- [x] T00X [P] [US2] Update `skills/mema.recall/SKILL.md` — replace `/recall` → `/mema.recall`, `/onboard` → `/mema.onboard` (update heading, body references on lines 5, 7, 26, 88, 135)
- [x] T00X [P] [US2] Update `skills/mema.plan/SKILL.md` — replace `/plan` → `/mema.plan`, `/onboard` → `/mema.onboard`, `/implement` → `/mema.implement` (update heading, description, usage examples on lines 2, 5, 7, 15, 31, 33–34, 81, 85, 183)
- [x] T0XX [P] [US2] Update `skills/mema.implement/SKILL.md` — replace `/implement` → `/mema.implement`, `/onboard` → `/mema.onboard`, `/plan` → `/mema.plan` (update heading, description, usage examples on lines 2, 5, 7, 9, 15, 31–34, 37, 48, 80, 118)
- [x] T0XX [P] [US2] Update `skills/mema.create-skill/SKILL.md` — replace `/create-skill` → `/mema.create-skill`, `/onboard` → `/mema.onboard` (update heading on line 5 and reference on line 51)

**Checkpoint**: `grep -r "/onboard\|/recall\|" skills/ --include="*.md"` returns zero
results. US1 + US2 are now both complete and independently verified.

---

## Phase 4: User Story 3 — Updated User-Facing Documentation (Priority: P3)

**Goal**: Update all documentation files so every example command uses `mema.*` names.
After this phase, a developer can copy any command from the docs and it will work.

**Independent Test**: `grep -r "/onboard\|/recall\|/plan\|/implement\|/create-skill" docs/ CLAUDE.md README.md bin/cli.js .specify/memory/constitution.md` returns zero results.

### Implementation for User Story 3

All T012–T016 tasks edit different files and can run fully in parallel.

- [x] T0XX [P] [US3] Update `docs/guide.md` — replace all ~25 occurrences of skill command names: `/onboard` → `/mema.onboard`, `/recall` → `/mema.recall`, `/plan` → `/mema.plan`, `/implement` → `/mema.implement`, `/create-skill` → `/mema.create-skill` (includes Quick Start block, section headings "## Recalling Memory: /recall" etc., code examples, workflow diagrams, and Tips section)
- [x] T0XX [P] [US3] Update `CLAUDE.md` — replace ~6 occurrences in Project Overview list and Architecture section: `/onboard` → `/mema.onboard`, `/recall` → `/mema.recall`, `/plan` → `/mema.plan`, `/implement` → `/mema.implement`, `/create-skill` → `/mema.create-skill`
- [x] T0XX [P] [US3] Update `README.md` — replace ~7 occurrences in Quick Start block (lines 17, 20), prose on line 23, and Built-in Skills table (lines 29–31, 67, 70): `/onboard` → `/mema.onboard`, `/recall` → `/mema.recall`, `/create-skill` → `/mema.create-skill`
- [x] T0XX [P] [US3] Update `bin/cli.js` — replace 3 output strings (lines 50, 53, 126): change all occurrences of `/onboard` → `/mema.onboard` in `console.log` and template literal strings
- [x] T0XX [P] [US3] Update `.specify/memory/constitution.md` — replace 2 occurrences: `/recall` → `/mema.recall` (line 40), `/onboard` → `/mema.onboard` (lines 69 and 121)

**Checkpoint**: All user stories are complete. Zero old skill names remain in any source
file. Docs accurately reflect what users will see after `npx mema-kit`.

---

## Phase 5: Polish & Validation

**Purpose**: Final verification sweep across all modified files.

- [x] T0XX Run full repository grep validation: `grep -r "/onboard\|/recall\|/plan\|/implement\|/create-skill" skills/ docs/ CLAUDE.md README.md bin/cli.js .specify/memory/ --include="*.md" --include="*.js"` — confirm zero results (excludes specs/ and .mema/)
- [x] T0XX [P] Verify installed skill names by running `node bin/cli.js` in a temporary empty directory and confirming `.claude/skills/` contains exactly: `mema.onboard/`, `mema.recall/`, `mema.plan/`, `mema.implement/`, `mema.create-skill/`, `_memory-protocol.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — run immediately.
- **US1 (Phase 2)**: Depends on Setup. Blocks US2 and US3.
  After US1, the `skills/` directories have new names — US2 edits files inside them.
- **US2 (Phase 3)**: Depends on US1 completion. T007–T011 are fully parallel.
- **US3 (Phase 4)**: Can start as soon as US1 is done (does not depend on US2).
  T012–T016 are fully parallel with each other and with US2 tasks.
- **Polish (Phase 5)**: Depends on US1 + US2 + US3 all being complete.

### User Story Dependencies

- **US1 (P1)**: No upstream dependencies. Immediately executable after setup.
- **US2 (P2)**: Depends on US1 (needs renamed directories to exist before editing content inside them).
- **US3 (P3)**: Depends on US1 conceptually (needs final names confirmed). Can run in parallel with US2.

### Within Each User Story

- T002 can start before T003–T006 but all 5 renames are independent of each other.
- T007–T011 have no ordering constraint among themselves.
- T012–T016 have no ordering constraint among themselves.

### Parallel Opportunities

- US1: T003, T004, T005, T006 can all run in parallel with T002 (different directories).
- US2: T007, T008, T009, T010, T011 can all run in parallel (different files).
- US3: T012, T013, T014, T015, T016 can all run in parallel (different files).
- US2 and US3 can run in parallel with each other (completely different file sets).

---

## Parallel Example: US1 Directory Renames

```bash
# All five renames are independent — run simultaneously:
Task: "Rename skills/onboard/ to skills/mema.onboard/"
Task: "Rename skills/recall/ to skills/mema.recall/"
Task: "Rename skills/plan/ to skills/mema.plan/"
Task: "Rename skills/implement/ to skills/mema.implement/"
Task: "Rename skills/create-skill/ to skills/mema.create-skill/"
```

## Parallel Example: US2 + US3 Text Updates

```bash
# After US1 completes, all of these can run simultaneously:
Task: "Update skills/mema.onboard/SKILL.md"      # US2
Task: "Update skills/mema.recall/SKILL.md"       # US2
Task: "Update skills/mema.plan/SKILL.md"         # US2
Task: "Update skills/mema.implement/SKILL.md"    # US2
Task: "Update skills/mema.create-skill/SKILL.md" # US2
Task: "Update docs/guide.md"                     # US3
Task: "Update CLAUDE.md"                         # US3
Task: "Update README.md"                         # US3
Task: "Update bin/cli.js"                        # US3
Task: "Update .specify/memory/constitution.md"   # US3
```

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1: Setup (T001)
2. Complete Phase 2: US1 — rename all 5 directories (T002–T006)
3. **STOP and VALIDATE**: Run `node bin/cli.js` in temp dir, confirm `mema.*` dirs installed
4. Skills are now invocable as `/mema.onboard` etc. — core feature delivered.

### Incremental Delivery

1. US1 complete → skills invocable with new names (MVP)
2. US2 complete → SKILL.md internal cross-refs consistent (polish for skill content)
3. US3 complete → docs fully consistent, installer message updated (polish for users)
4. Polish phase → validation sweep confirms zero old names anywhere

### Parallel Team Strategy

With multiple agents or developers:

1. Complete T001 (setup) + T002–T006 (US1 renames) together — takes minutes
2. Once US1 done, split:
   - Agent A: T007–T011 (all 5 SKILL.md updates)
   - Agent B: T012–T016 (all 5 doc/code updates)
3. Polish phase (T017–T018) after both agents complete

---

## Notes

- [P] tasks = different files, no shared state — safe to run in parallel
- [US*] label maps each task to the user story it fulfills
- T002–T006 are directory renames (git mv or OS rename), not text edits
- T007–T016 are text replacements inside files — use Edit tool, not shell sed
- The old `CLAUDE.md` skill names are also in the CLAUDE.md that `/mema.onboard` will GENERATE for user projects — those are inside `skills/mema.onboard/SKILL.md` and are covered by T007
- Avoid editing `specs/` — those files are the source of truth for this feature, not a target
