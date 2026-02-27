# Quickstart: Developing the Full Lifecycle Expansion

**Phase**: 1 — Design
**Branch**: `002-expand-lifecycle`
**Date**: 2026-02-27

## What Changes

This is a large feature. Here's a map of every file that changes:

### New files (12 total)
```
skills/mema.seed/SKILL.md
skills/mema.clarify/SKILL.md
skills/mema.research/SKILL.md
skills/mema.challenge/SKILL.md
skills/mema.roadmap/SKILL.md
skills/mema.specify/SKILL.md
skills/mema.tasks/SKILL.md
templates/product/seed.md
templates/product/clarify.md
templates/product/research.md
templates/product/challenge.md
templates/product/roadmap.md
```

### Updated files (13 total)
```
skills/_memory-protocol.md       (directory names + index format)
skills/mema.onboard/SKILL.md     (new .mema/ structure + migration)
skills/mema.recall/SKILL.md      (surface active features)
skills/mema.plan/SKILL.md        (feature-level design: reads features/NNN/spec.md)
skills/mema.implement/SKILL.md   (reads features/NNN/tasks.md)
skills/mema.create-skill/SKILL.md (update path refs)
templates/index.md               (new index format with 4 sections)
templates/project/architecture.md (renamed from project-memory/)
templates/project/requirements.md (renamed)
templates/project/decisions/decision.md (renamed)
templates/agent/lessons.md        (renamed from agent-memory/)
templates/agent/patterns.md       (renamed)
bin/cli.js                        (install 12 skills)
docs/guide.md                     (major rewrite)
```

**Total: ~25 file changes**

---

## Implementation Order

Work in this order — each phase is independently deployable:

### Phase A: Foundation (blocks everything)
1. Update `skills/_memory-protocol.md` — new directory names + index format
2. Update `templates/` — rename directories, add product/ templates
3. Update `bin/cli.js` — install all 12 skills

### Phase B: Updated Existing Skills (P4 onboard + P3 recall)
4. Update `mema.onboard` — create new structure, add migration
5. Update `mema.recall` — surface active features
6. Update `mema.plan` — feature-level design flow
7. Update `mema.implement` — reads from features/
8. Update `mema.create-skill` — path reference fixes

### Phase C: Discovery Skills (P1 — new project from scratch)
9. Write `mema.seed`
10. Write `mema.clarify`
11. Write `mema.research`
12. Write `mema.challenge`
13. Write `mema.roadmap`

**P1 checkpoint**: At this point, the full discovery workflow works. Test manually.

### Phase D: Feature Workflow Skills (P2 — add features)
14. Write `mema.specify`
15. Write `mema.tasks`

**P2 checkpoint**: Full lifecycle works end-to-end. Test manually.

### Phase E: Polish
16. Major rewrite of `docs/guide.md`
17. Update `CLAUDE.md` (repository instructions)

---

## Manual Test Scenarios

### Test 1 — Full new project from scratch (P1)
```
mkdir /tmp/test-project && cd /tmp/test-project
# Install skills (or symlink for dev)
/mema.seed I want to build a tool that helps remote teams do async standups
/mema.clarify
/mema.research
/mema.challenge
/mema.roadmap
```
**Verify**: `.mema/product/` has all 5 files. `.mema/features/` has at least one numbered directory. `.mema/index.md` has all 4 sections.

### Test 2 — Feature implementation on existing project (P2)
```
# On any project with .mema/ set up
/mema.specify
/mema.plan
/mema.tasks
/mema.implement
```
**Verify**: `features/001-[name]/` has spec.md, plan.md, tasks.md, status.md. After implement runs, status.md shows progress.

### Test 3 — Cold start recall (P3)
```
# New session
/mema.recall
```
**Verify**: Output shows active feature name, current status, and what to run next — in under 10 lines at the top.

### Test 4 — Migration from old structure (P4)
```
# Project with old .mema/ (project-memory/, task-memory/, agent-memory/)
/mema.onboard
```
**Verify**: Old directories renamed to new paths. Content preserved. `index.md` updated. User informed of migration.

### Test 5 — Install via CLI
```
npx mema-kit
ls .claude/skills/
```
**Verify**: All 12 skill directories present. `_memory-protocol.md` present.

---

## Common Pitfalls

- **Path drift**: New skills must use `product/`, `features/`, `project/`, `agent/` — not the old names. Check every new SKILL.md before committing.
- **Memory protocol consistency**: `_memory-protocol.md` is the reference for ALL skills. Update it first (Phase A) before writing any skill that reads from it.
- **Discovery is optional**: `mema.specify` must work without any `product/` files existing. Don't make discovery a hard prerequisite in the implementation skills.
- **Feature number conflicts**: `mema.specify` and `mema.roadmap` both create feature directories. The numbering logic must be consistent — always scan `features/` for the current max before assigning a new number.
- **`bin/cli.js` skill list**: Easy to forget to add a new skill here. After adding a skill file, immediately update `bin/cli.js`.

---

## What "Done" Looks Like

- [ ] `npx mema-kit` installs all 12 skills with no errors
- [ ] Full discovery workflow (P1 test) completes in a fresh directory
- [ ] Feature workflow (P2 test) works on an existing project without prior discovery
- [ ] `/mema.recall` surfaces active features prominently (P3 test)
- [ ] `/mema.onboard` migrates old `.mema/` structure (P4 test)
- [ ] `docs/guide.md` describes the full lifecycle with worked examples
