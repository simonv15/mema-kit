# Research: Full AI-Assisted Development Lifecycle

**Phase**: 0 — Outline & Research
**Branch**: `002-expand-lifecycle`
**Date**: 2026-02-27

## Decision 1: Memory Directory Restructure — Migration Strategy

**Question**: The current `.mema/` uses `project-memory/`, `task-memory/`, `agent-memory/`. The new structure uses `project/`, `features/`, `agent/`, `product/`. How should existing users migrate?

**Decision**: `/mema.onboard` detects the old structure and migrates automatically on re-run.

**Migration logic**:
- If `project-memory/` exists and `project/` does not → move contents, inform user
- If `task-memory/` exists and `features/` does not → move contents, inform user; existing task directories become `features/NNN-name/` (assign numbers starting from 001)
- If `agent-memory/` exists and `agent/` does not → move contents, inform user
- If new structure already exists → NOOP on that directory

**Rationale**: Automatic migration on re-run is the lowest-friction path. Users who re-run `/mema.onboard` (the expected upgrade path) get migrated automatically. No manual steps needed.

**Alternatives considered**:
- Separate `/mema.migrate` skill — rejected (adds a skill for a one-time operation; violates Principle V)
- Support both old and new paths in all skills — rejected (doubles the complexity of every skill's AUTO-LOAD section indefinitely)

---

## Decision 2: `/mema.research` Web Search Mechanism

**Question**: How does `/mema.research` use web search without adding a runtime dependency?

**Decision**: The skill instructs Claude to use its native WebSearch capability directly in the SKILL.md instructions.

**Pattern**:
```
Use the WebSearch tool to search for:
1. "[product name] competitors" or "[problem domain] existing solutions"
2. "[product name] market size" or "[domain] market trends [current year]"
3. "[key technology option 1] vs [key technology option 2]"
Save all findings with source URLs to .mema/product/research.md
```

**Rationale**: Claude Code skills are instructions to Claude, not executable code. Claude has a built-in WebSearch tool. Instructing it to use that tool requires zero npm packages — it's the same pattern as instructing it to use Read/Write tools. This is consistent with how the whole system works.

**Graceful degradation**: If WebSearch is unavailable (no internet, tool not permitted), the skill informs the user and offers to proceed using Claude's training knowledge, noting the limitation clearly in `research.md`.

**Alternatives considered**:
- External Node.js web scraping script — rejected (adds runtime dependency, violates Principle II)
- Prompt user to paste research manually — rejected (defeats the automation value)

---

## Decision 3: Feature Directory Numbering

**Question**: How are features numbered in `.mema/features/`? Who assigns numbers and how?

**Decision**: 3-digit sequential padding (001, 002, ...). Two sources of numbers:
- `/mema.roadmap` — creates directories for all features in the roadmap simultaneously, numbering them in priority order
- `/mema.specify` — when creating a feature without a roadmap, scans `.mema/features/` for the highest existing number N and uses N+1; starts at 001 if directory is empty

**Format**: `NNN-kebab-case-name/` (e.g., `001-user-auth/`, `002-search/`)

**Rationale**: Sequential numbering makes ordering visible at a glance in the file system. 3-digit padding keeps alphabetical and numeric sort aligned up to 999 features (sufficient for any real project). Consistent assignment logic between roadmap and standalone paths prevents numbering conflicts.

**Alternatives considered**:
- Name-only directories (no number prefix) — rejected; no natural ordering, hard to see priority
- Timestamp-based directories — rejected; harder to read and no inherent priority signal

---

## Decision 4: `mema.plan` Role in the New Model

**Question**: The current `mema.plan` "breaks goals into implementation specs." In the new model, `mema.specify` handles specification. What does `mema.plan` become?

**Decision**: `mema.plan` becomes the **technical implementation design** skill for a single feature. It reads `features/NNN/spec.md` and writes `features/NNN/plan.md`. This is the same job as speckit's `plan` phase — architecture decisions, data model, implementation approach — but without the speckit quality gates (no contracts/ directory, no spec quality checklist).

**Inputs**: `features/NNN/spec.md` + `project/architecture.md` + `project/decisions/` + `agent/lessons.md`
**Output**: `features/NNN/plan.md`

**Rationale**: `mema.plan` retains a planning function; it just plans at the feature level rather than the goal level. This is a natural fit and avoids naming confusion. The old "break goal into specs" behavior is now split between `mema.specify` (what) and `mema.plan` (how).

**Alternatives considered**:
- Rename to `mema.design` — rejected; `mema.plan` is already established and the function is still planning
- Merge `mema.specify` + `mema.plan` into one skill — rejected; the what/how separation is the core value of spec-driven development; keeping them separate maintains the review gate

---

## Decision 5: `_memory-protocol.md` Update Scope

**Question**: How extensively does `_memory-protocol.md` need to change?

**Decision**: Two targeted updates only:
1. **Directory references**: Replace `project-memory/` → `project/`, `task-memory/` → `features/`, `agent-memory/` → `agent/` throughout
2. **Index format**: Update the four sections to reflect new structure: `Active Features`, `Product Discovery`, `Project Knowledge`, `Agent Knowledge`

All curation rules (ADD/UPDATE/DELETE/NOOP), curation styles per file type, and the Rebuild Procedure logic remain unchanged — they are structure-agnostic.

**Rationale**: The protocol's value is its curation rules, not its directory names. Minimal surgical changes reduce the risk of accidentally changing behavior.

---

## Decision 6: `mema.recall` Updates

**Question**: What does `/mema.recall` need to change to surface active features?

**Decision**: Add a new section to the recall output: **Active Features** — lists all `features/NNN-name/` directories where `status.md` is NOT `complete`, showing: feature name, current status, and last task completed (from `status.md`). This section appears at the top of the output.

The existing minimal/full mode distinction from the current implementation is preserved. Full mode additionally loads `product/roadmap.md` if it exists.

**Rationale**: The single most important thing a returning developer needs is "what was I working on?" Surfacing active features prominently directly addresses SC-002 (under 60 seconds to next action).

---

## Decision 7: Skill Count — What Gets Removed vs. Added

**Final 12-skill inventory:**

| Skill | Status | Change |
|-------|--------|--------|
| `mema.onboard` | Updated | Creates new `.mema/` structure; migrates old |
| `mema.recall` | Updated | Surfaces active features prominently |
| `mema.plan` | Updated | Now: feature-level technical design → `features/NNN/plan.md` |
| `mema.implement` | Updated | Reads from `features/NNN/tasks.md`; updates `features/NNN/status.md` |
| `mema.create-skill` | Updated | Minor path reference fixes only |
| `mema.seed` | New | Captures raw idea → `product/seed.md` |
| `mema.clarify` | New | Q&A refinement → `product/clarify.md` |
| `mema.research` | New | Web search → `product/research.md` |
| `mema.challenge` | New | Stress-test → `product/challenge.md` |
| `mema.roadmap` | New | Project plan + feature directories → `product/roadmap.md` |
| `mema.specify` | New | Feature spec → `features/NNN/spec.md` |
| `mema.tasks` | New | Task breakdown → `features/NNN/tasks.md` |

**Removed** (merged/superseded):
- Old `mema.plan` behavior ("break goal into specs") → replaced by `mema.specify` + updated `mema.plan`
- brainstormer `/review` → idempotency covers it
- `speckit.*` skills → absorbed into `mema.*` namespace (speckit remains a separate dev tool for mema-kit's own development; it is not distributed to users)

---

## Summary

All design decisions are resolvable from first principles. No external research required — the architecture is entirely internal (markdown skills, file system, Claude Code native tools). The web search capability in `/mema.research` is Claude Code's own tool, consistent with the zero-runtime-dependency principle.
