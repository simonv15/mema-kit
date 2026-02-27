# Contract: /mema.create-skill Skill Interface

**Phase**: 1 — Design
**Branch**: `001-enhance-create-skill`
**Date**: 2026-02-27

## Overview

This document defines the observable interface of the `/mema.create-skill` skill — how a user invokes it, what inputs it accepts, and what outputs/behaviors it guarantees. This is the contract that the enhanced skill must uphold.

---

## Invocation

```
/mema.create-skill [optional: skill-name] [optional: brief purpose]
```

### Arguments (all optional)

| Argument | Type | Behavior when provided |
|----------|------|------------------------|
| `skill-name` | kebab-case string | Pre-fills the name field; skill skips asking for it |
| `brief purpose` | free text | Pre-fills the purpose field; skill may ask to confirm or expand |

If no arguments are provided, the skill starts with the interview from scratch.

---

## Interaction Flow (Enhanced)

```
User invokes /mema.create-skill
         │
         ▼
[AUTO-LOAD] Read .mema/index.md + patterns.md
         │
         ▼
[Step 1] Interview (name, purpose, complexity, memory mode)
  ← max 2–3 exchanges; stop when all fields collected →
         │
         ▼
[Step 2] Generate SKILL.md content
  ← derive WORK steps from purpose
  ← derive AUTO-LOAD hints from purpose keywords
  ← validate: zero [placeholder] text, correct structure →
         │
         ▼
[Step 2.5] Draft Review
  ← show full SKILL.md in fenced code block
  ← ask: APPROVE / describe change / CANCEL
  ← on change request: revise named section only, re-show full draft
  ← on APPROVE: proceed to Step 3 →
         │
         ▼
[Step 3] Existence Check
  ├── File does NOT exist → write to .claude/skills/[name]/SKILL.md
  └── File EXISTS → show description + phase headers
                    offer: (1) Enhance  (2) Overwrite  (3) Cancel
                    ├── Enhance → apply user directive to named sections only
                    ├── Overwrite → go through Draft Review again
                    └── Cancel → exit, no file changes
         │
         ▼
[Step 4] Verify
  ← read back the written file
  ← confirm: frontmatter present, name correct, no [placeholder] text →
         │
         ▼
[Step 5] Confirm (output to user)
         │
         ▼
[AUTO-SAVE] Update agent-memory/patterns.md with skill record
         │
         ▼
[AUTO-INDEX] Update .mema/index.md
```

---

## Output Contract (Step 5 — Confirm Message)

The confirmation message MUST include:

```
Skill created: /[name]

Location: .claude/skills/[name]/SKILL.md
Type:     [simple|standard|advanced]
Memory:   [read-only|write-only|read+write]

To use it:
  /[name] [your request]

The skill follows the mema-kit memory protocol and will
[read from / write to / read from and write to] .mema/ automatically.
```

No additional formatting, no markdown headers. Plain text block.

---

## Error Conditions

| Condition | Behavior |
|-----------|----------|
| Name matches a reserved built-in (`mema.onboard`, `mema.recall`, `mema.plan`, `mema.implement`, `mema.create-skill`) | Warn before proceeding: "This name matches a built-in mema-kit skill. Using it in `.claude/skills/` will shadow the built-in. Continue? (yes/no)" |
| Name is not kebab-case | Convert automatically, inform user: "Name converted to kebab-case: [converted-name]" |
| Purpose is too vague (single word or <5 characters) | Ask one follow-up question to expand before generating |
| Draft review revision count exceeds 3 | Warn: "Multiple revisions requested. Consider re-running /mema.create-skill with a more detailed purpose." — continue with current draft |
| `.claude/skills/` directory does not exist | Create it automatically without prompting |
| `.mema/index.md` missing during AUTO-LOAD | Follow Rebuild Procedure from `_memory-protocol.md` |

---

## What This Skill Does NOT Do

- Does not run or test the generated skill (out of scope; skills are markdown instructions, not executable code)
- Does not publish or install the skill to the mema-kit npm package (that's `bin/cli.js` territory)
- Does not generate multi-file skill bundles (each skill is one SKILL.md)
- Does not generate skills for other AI agents or platforms — only Claude Code skills
