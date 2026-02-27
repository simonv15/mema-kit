# Implementation Plan: Enhanced /mema.create-skill

**Branch**: `001-enhance-create-skill` | **Date**: 2026-02-27 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-enhance-create-skill/spec.md`

## Summary

Enhance `skills/mema.create-skill/SKILL.md` to (1) generate purposeful, non-placeholder WORK phase steps derived from the user's skill purpose, (2) add a preview-before-write gate so no file is written without explicit user approval, (3) detect existing skills and offer Enhance/Overwrite/Cancel instead of a blunt warning, and (4) add the mandatory AUTO-LOAD / AUTO-SAVE / AUTO-INDEX memory lifecycle to the skill itself (Constitution Principle I compliance).

All changes are confined to one file: `skills/mema.create-skill/SKILL.md`.

## Technical Context

**Language/Version**: Markdown (skill files) — no executable code in this feature
**Primary Dependencies**: None — Claude Code native Read/Write tools only
**Storage**: File system — `.claude/skills/[name]/SKILL.md` output; `.mema/agent-memory/patterns.md` + `.mema/index.md` for memory
**Testing**: Manual — invoke skill in Claude Code and verify behavior against acceptance scenarios
**Target Platform**: Claude Code (any OS, any project)
**Project Type**: Skill template / markdown instruction file
**Performance Goals**: SKILL.md output must be under ~250 lines to avoid context bloat
**Constraints**: Zero runtime dependencies; no external APIs; pure markdown; no build step
**Scale/Scope**: Single file modification

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] **I. Memory-First** — The enhanced skill will add AUTO-LOAD, AUTO-SAVE & CURATE, and AUTO-INDEX phases to the skill itself. Research Decision 1 resolves this. *(Current skill has no memory phases — this enhancement fixes the violation.)*
- [x] **II. Zero Runtime Dependencies** — Only a markdown file is modified. No packages, no external APIs.
- [x] **III. Idempotency** — FR-004 (three-choice prompt on existing skill) satisfies re-run safety. Research Decision 5 defines the Enhance/Overwrite/Cancel flow which preserves existing state by default.
- [x] **IV. Skills as Single Source of Truth** — All changes originate in `skills/mema.create-skill/SKILL.md`.
- [x] **V. Simplicity** — Three focused enhancements (WORK generation, preview, existence check). No speculative features. Memory lifecycle addition is required by Principle I, not elective.

> **Post-design re-check**: All five principles pass. No violations requiring Complexity Tracking.

## Project Structure

### Documentation (this feature)

```text
specs/001-enhance-create-skill/
├── plan.md              # This file
├── research.md          # Phase 0 — design decisions
├── data-model.md        # Phase 1 — conceptual entities
├── quickstart.md        # Phase 1 — development & testing guide
├── contracts/
│   └── skill-interface.md  # Phase 1 — invocation contract
├── checklists/
│   └── requirements.md  # Spec validation checklist
└── tasks.md             # Phase 2 output (/speckit.tasks — NOT created here)
```

### Source Code (repository root)

```text
skills/
└── mema.create-skill/
    └── SKILL.md          # THE only file that changes
```

**Structure Decision**: Single-file modification. No new directories or files in the source tree. The enhancement lives entirely in the instruction content of `SKILL.md`.

## Complexity Tracking

> No violations — all principles pass. Table not needed.

## Phase 0: Research

**Status**: Complete — see [research.md](research.md)

All five design decisions resolved without external research:

| Decision | Resolution |
|----------|------------|
| Memory lifecycle for skill itself | Add AUTO-LOAD (read index.md + patterns.md) + AUTO-SAVE (append patterns.md) + AUTO-INDEX |
| Preview mechanism | Explicit "Step 2.5: Draft Review" with APPROVE/CANCEL/revise loop |
| WORK step generation | Purpose decomposition prompt + scan-before-continue validation |
| Context-relevant AUTO-LOAD hints | Keyword-to-file mapping from purpose description |
| Existing skill detection | Read headers only, three-choice prompt (Enhance/Overwrite/Cancel) |

## Phase 1: Design & Contracts

**Status**: Complete

### Artifacts

| Artifact | File | Purpose |
|----------|------|---------|
| Data model | [data-model.md](data-model.md) | Conceptual entities managed by the skill |
| Skill interface contract | [contracts/skill-interface.md](contracts/skill-interface.md) | Invocation, interaction flow, output contract, error conditions |
| Development guide | [quickstart.md](quickstart.md) | How to implement and manually test |

### Key Design Choices

1. **Memory lifecycle placement**: AUTO-LOAD added before Step 1 (Interview). AUTO-SAVE & CURATE + AUTO-INDEX added after Step 5 (Confirm). This keeps the "Steps 1–5 generation workflow" intact and wraps it with the memory lifecycle.

2. **Preview gate numbering**: Inserted as "Step 2.5" (not renumbering existing steps) to minimize diff and clearly signal it's between generation and write.

3. **Existence check placement**: Moved into Step 3 (Write) as a conditional branch. Step 3 already handles file writing — adding the existence check here keeps write logic co-located.

4. **Reserved name list**: `onboard`, `recall`, `plan`, `implement`, `create-skill` — the five mema.* built-ins. A user creating `.claude/skills/onboard/SKILL.md` would shadow the installed version.

5. **Memory record granularity**: Only `agent-memory/patterns.md` is written (lightweight record). No `decisions/` file per skill creation — that would produce excessive file churn for a routine operation (Principle V: Simplicity).

### SKILL.md Structural Layout (Post-Enhancement)

```markdown
---
description: ...
---

# /mema.create-skill — Generate Memory-Aware Skills

## AUTO-LOAD              ← NEW

## Step 1: Interview       (existing — minor refinements)

## Step 2: Generate SKILL.md  (existing — enhanced with WORK generation + hints)

## Step 2.5: Draft Review  ← NEW

## Step 3: Write the File  (existing — enhanced with existence check)

## Step 4: Verify          (existing — unchanged)

## Step 5: Confirm         (existing — unchanged)

## AUTO-SAVE & CURATE      ← NEW

## AUTO-INDEX              ← NEW
```
