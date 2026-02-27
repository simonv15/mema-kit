# Quickstart: Developing & Testing the Enhanced /mema.create-skill

**Phase**: 1 — Design
**Branch**: `001-enhance-create-skill`
**Date**: 2026-02-27

## What You're Changing

One file: `skills/mema.create-skill/SKILL.md`

That file is the single source of truth (Constitution Principle IV). Once edited, users get the enhancement the next time `npx mema-kit` installs skills to their project.

---

## Development Workflow

### 1. Open the skill file

```
skills/mema.create-skill/SKILL.md
```

### 2. Make changes per the implementation tasks in tasks.md

Each task will tell you which section to modify. The structure of the enhanced SKILL.md will look like:

```
Step 1: Interview          (keep, minor tweaks)
Step 2: Generate SKILL.md  (enhance — add WORK generation logic + AUTO-LOAD hints)
Step 2.5: Draft Review     (NEW — preview gate)
Step 3: Write the File     (enhance — add existence check + three-choice prompt)
Step 4: Verify             (keep, minor tweaks)
Step 5: Confirm            (keep)
[AUTO-LOAD section]        (NEW — add before Step 1)
[AUTO-SAVE section]        (NEW — add after Step 5)
[AUTO-INDEX section]       (NEW — add after AUTO-SAVE)
```

### 3. Test manually in a scratch project

Since skills are markdown instructions, testing means invoking the skill in Claude Code and verifying behavior:

**Test A — New skill, full flow:**
```
/mema.create-skill
```
Follow prompts. Verify:
- WORK phase has no `[placeholder]` text
- Preview is shown before write
- File at `.claude/skills/[name]/SKILL.md` is created only after APPROVE

**Test B — Existing skill:**
```
/mema.create-skill [name of skill you just created]
```
Verify the three-choice prompt appears (not an immediate overwrite warning).

**Test C — Reserved name:**
```
/mema.create-skill onboard
```
Verify a warning about shadowing the built-in is shown before proceeding.

**Test D — Memory lifecycle:**
Check that `.mema/agent-memory/patterns.md` gains a new entry after skill creation.
Check that `.mema/index.md` is updated.

---

## What "Done" Looks Like

- [ ] `skills/mema.create-skill/SKILL.md` updated with all enhancements
- [ ] Manual Test A passes: no placeholders in generated WORK phase
- [ ] Manual Test B passes: three-choice prompt on existing skill
- [ ] Manual Test C passes: reserved name warning shown
- [ ] Manual Test D passes: memory written and index updated
- [ ] `docs/guide.md` updated to describe the new preview step and enhance mode (if relevant section exists)

---

## No Build Step Needed

Skills are plain markdown. There is no compile, lint, or test command to run. Verification is done by reading the SKILL.md and manually exercising it in Claude Code.

---

## Common Pitfalls

- **Accidental `[placeholder]` text left in templates inside SKILL.md**: The skill's Step 2 instructs Claude to generate content, but if the template within SKILL.md still has `[First action]`-style brackets in a code block example, Claude might copy them verbatim. Make sure any template examples inside SKILL.md use clearly-labeled example content, not bracket placeholders.

- **Memory path drift**: Always use `.mema/` as the prefix. Never `.praxis/`, `.memory/`, or any other prefix. The Verify step (Step 4) checks this, but confirm during authoring too.

- **Phase headers vs Step headers**: Built-in mema-kit skills use `## Phase N:` for the lifecycle phases (AUTO-LOAD etc.) and `## Step N:` for the generation steps. The enhanced skill adds `## AUTO-LOAD`, `## AUTO-SAVE & CURATE`, `## AUTO-INDEX` sections around the `## Step` sections to satisfy Constitution Principle I.
