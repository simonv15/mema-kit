# Data Model: Enhanced /mema.create-skill

**Phase**: 1 — Design
**Branch**: `001-enhance-create-skill`
**Date**: 2026-02-27

## Overview

This feature has no persistent database or structured data files. The "data model" describes the conceptual state that the enhanced skill manages during a single execution session — purely in-memory (Claude's context window) and in the file that gets written at the end.

---

## Entity 1: SkillDraft

The working representation of the skill being created, built up during the interview and generation steps.

| Attribute | Type | Source |
|-----------|------|--------|
| `name` | string (kebab-case) | User interview — Step 1 |
| `purpose` | string | User interview — Step 1 |
| `complexity` | `simple` \| `standard` \| `advanced` | User interview — Step 1 (default: standard) |
| `memoryMode` | `read` \| `write` \| `both` | User interview — Step 1 (default: both) |
| `workPhaseSteps` | string[] | Generated from purpose — Step 2 |
| `autoLoadHints` | `{ path: string, reason: string }[]` | Derived from purpose keywords — Step 2 |
| `descriptionFrontmatter` | string | Generated from purpose — Step 2 |
| `existingContent` | string \| null | Read from disk if file exists — Step 3 check |
| `approvalStatus` | `pending` \| `approved` \| `cancelled` | Set in Draft Review step |

**State transitions**: `initial → interviewed → generated → previewed → approved/cancelled`

---

## Entity 2: InterviewSession

Tracks what the skill has gathered from the user to avoid re-asking answered questions.

| Attribute | Type | Notes |
|-----------|------|-------|
| `nameProvided` | boolean | Can be pre-filled if user passes name as arg |
| `purposeProvided` | boolean | One sentence minimum |
| `complexityDecided` | boolean | Defaults to `standard` if not specified |
| `memoryModeDecided` | boolean | Defaults to `both` if not specified |
| `revisionCount` | integer | How many preview revision loops occurred |
| `maxRevisions` | integer | 3 — if exceeded, warn user and continue |

---

## Entity 3: ExistingSkillCheck

Captured when an existing SKILL.md is detected at the target path.

| Attribute | Type | Notes |
|-----------|------|-------|
| `path` | string | `.claude/skills/[name]/SKILL.md` |
| `descriptionFrontmatter` | string | Extracted from `---` block |
| `phaseHeaders` | string[] | All `## Phase` or `## Step` headings (not body content) |
| `userChoice` | `enhance` \| `overwrite` \| `cancel` | User's selection from the three-option prompt |
| `enhanceDirective` | string \| null | User's description of what to change (if choice is `enhance`) |

---

## Entity 4: MemoryRecord

The lightweight lesson recorded in `agent-memory/patterns.md` after a skill is written.

| Attribute | Type | Notes |
|-----------|------|-------|
| `skillName` | string | The created/updated skill's kebab-case name |
| `complexity` | string | The template type used |
| `purpose` | string | One-sentence summary |
| `action` | `created` \| `enhanced` \| `overwritten` | Which branch was taken |
| `date` | string | `YYYY-MM-DD` |

This record is appended to `agent-memory/patterns.md` using the standard curation rules (ADD if new skill, UPDATE if same skill name seen again).

---

## File System Outputs

| File | Created when | Format |
|------|-------------|--------|
| `.claude/skills/[name]/SKILL.md` | User approves preview | Markdown with YAML frontmatter (description only) + phase sections |
| `.mema/agent-memory/patterns.md` | After file write (AUTO-SAVE) | Existing file updated with new entry |
| `.mema/index.md` | After AUTO-SAVE | Updated `**Updated:**` date + entry for patterns.md if changed |

---

## Constraints

- `SKILL.md` must begin with `---\ndescription: ...\n---` (YAML frontmatter, description key only)
- `name` must be kebab-case; no uppercase letters, no spaces
- `name` must not match reserved names: `onboard`, `recall`, `plan`, `implement`, `create-skill` (these are protected mema.* built-ins)
- Total SKILL.md line count should stay under ~250 lines to avoid context bloat in Claude's window when the skill is loaded
- `workPhaseSteps` must contain zero `[placeholder]`-style text before write
