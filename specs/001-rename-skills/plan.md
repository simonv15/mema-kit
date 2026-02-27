# Implementation Plan: Rename Skills to mema.* Namespace

**Branch**: `001-rename-skills` | **Date**: 2026-02-27 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/001-rename-skills/spec.md`

## Summary

Rename all five built-in mema-kit skill directories from bare names (`onboard`,
`recall`, `plan`, `implement`, `create-skill`) to namespaced names
(`mema.onboard`, `mema.recall`, `mema.plan`, `mema.implement`, `mema.create-skill`).
Update every cross-reference in SKILL.md files, `bin/cli.js`, `docs/guide.md`,
`CLAUDE.md`, `README.md`, and `.specify/memory/constitution.md` to use the new
names. No new code logic is introduced — this is a pure rename + text replacement.

## Technical Context

**Language/Version**: Node.js ≥ 16.7.0 (cli.js), Markdown (all skill files)
**Primary Dependencies**: None — Node.js `fs`/`path` built-ins only
**Storage**: Files (markdown in `skills/`, `docs/`, `bin/`)
**Testing**: Manual verification per `quickstart.md`
**Target Platform**: macOS / Linux / Windows (anywhere Node.js 16+ runs)
**Project Type**: CLI tool + skill library
**Performance Goals**: N/A — no runtime performance impact
**Constraints**: Zero runtime dependencies (existing constraint, unchanged)
**Scale/Scope**: 5 directory renames, ~10 files with text edits, ~50 string replacements

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **I. Memory-First** — N/A: This feature renames directories and edits text.
  It does not add or remove a skill. Existing skills already implement all four
  lifecycle phases; the rename does not change their behavior.
- [x] **II. Zero Runtime Dependencies** — ✅ No new dependencies introduced.
  All changes are directory renames and text edits in existing files.
- [x] **III. Idempotency** — ✅ Directory renames are idempotent if new-name
  directories don't already exist; text replacements are idempotent if already
  applied. No state corruption on re-run.
- [x] **IV. Skills as Single Source of Truth** — ✅ All changes originate in
  `skills/` (directories renamed there) and propagate to docs. No duplication.
- [x] **V. Simplicity** — ✅ Minimum viable change: rename directories +
  replace text. No new abstractions, helpers, or features introduced.

> **Violations**: None. Complexity Tracking table omitted.

## Project Structure

### Documentation (this feature)

```text
specs/001-rename-skills/
├── plan.md          # This file
├── spec.md          # Feature specification
├── research.md      # Phase 0: dot-naming validation, file impact map
├── data-model.md    # Canonical name mapping + file impact table
├── quickstart.md    # Post-implementation validation guide
├── checklists/
│   └── requirements.md
└── tasks.md         # Phase 2 output (/speckit.tasks — not yet created)
```

### Source Code (repository root)

```text
skills/                        # ALL FIVE directories renamed here
├── mema.onboard/
│   └── SKILL.md               # Internal refs updated
├── mema.recall/
│   └── SKILL.md               # Internal refs updated
├── mema.plan/
│   └── SKILL.md               # Internal refs updated
├── mema.implement/
│   └── SKILL.md               # Internal refs updated
├── mema.create-skill/
│   └── SKILL.md               # Internal refs updated
└── _memory-protocol.md        # No changes needed

bin/
└── cli.js                     # 3 output strings updated

docs/
└── guide.md                   # ~25 skill name occurrences updated

CLAUDE.md                      # ~6 skill name occurrences updated
README.md                      # ~7 skill name occurrences updated

.specify/memory/
└── constitution.md            # 2 skill name occurrences updated
```

**Structure Decision**: Single-project layout; no `src/` or `tests/` directories
are involved — this is a pure file rename + text update feature.
