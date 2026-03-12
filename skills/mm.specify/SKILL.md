---
description: Create a feature specification. Picks a feature from the roadmap or takes a fresh description, and saves a non-technical spec to features/NNN-name/spec.md.
---

# /mema.specify — Feature Specification

You are executing the /mema.specify skill. Follow these steps carefully.

This skill creates a feature spec — the "what and why" before any technical planning. It works with or without a prior discovery phase.

## AUTO-LOAD

1. Read `.mema/index.md`
2. If `.mema/` doesn't exist:
   - Tell the user: "No memory found. Run `/mema.onboard` first to set up mema-kit."
   - **Stop here.**
3. Read if they exist:
   - `product/roadmap.md` — to present the feature list
   - `product/research.md` — to inform the spec with competitive context
   - `product/challenge.md` — to include known constraints
   - `project/architecture.md` — to note technical constraints in the spec

## WORK

### Select Feature

**If a roadmap exists** and no argument was given:
- List features from `product/roadmap.md` that don't yet have a `spec.md`
- Ask: "Which feature would you like to specify? (Enter number or name)"

**If an argument was given** (e.g., `/mema.specify 001` or `/mema.specify "add search"`):
- If it's a number: find `features/NNN-*/` matching that number
- If it's a name: find the closest matching feature directory, or create a new one
- If it's a fresh description (no matching directory): create a new feature directory

**If no roadmap and no argument**:
- Ask: "Describe the feature you want to specify."

### Create Feature Directory (if needed)

If no directory exists for this feature:
1. Scan `features/` for the highest existing number N
2. Create `features/N+1-kebab-name/` (start at 001 if no features exist)
3. Create a starter `status.md` with `**Status:** pending`

### If spec.md Already Exists

Read the existing spec and ask:
"A spec already exists for [feature name]. Update specific sections, or rewrite from scratch?"
- **Update**: modify named sections, preserve rest
- **Rewrite**: replace entirely (after confirming)

### Write the Spec

Gather the following (from roadmap, user input, or inference):
- **Purpose**: What does this feature do and why does it exist?
- **User scenarios**: Who does what, and what happens?
- **Acceptance criteria**: How do we know it's working?
- **Constraints**: What must this not break? What must it support?
- **Out of scope**: What does this feature NOT do?

Reference `product/research.md` and `product/challenge.md` if they exist — constraints and risks belong in the spec.

Write `.mema/features/NNN-name/spec.md`:

```
# [Feature Name] — Spec

**Status:** active | **Updated:** [today's date]

## Purpose

[What this feature does and why it exists — one paragraph, non-technical]

## User Scenarios

### Scenario 1 — [Title]

**Given** [initial state], **When** [user action], **Then** [expected outcome]

### Scenario 2 — [Title]

**Given** [initial state], **When** [user action], **Then** [expected outcome]

## Acceptance Criteria

- [ ] [Specific, testable criterion]
- [ ] [Specific, testable criterion]

## Constraints

[Non-negotiables, compatibility requirements, performance needs]

## Out of Scope

[What this feature deliberately does NOT include]
```

### Create Feature Branch (if scripts available)

After saving `spec.md`, create (or check out) the feature branch:

1. Parse the feature number and name from the feature directory path:
   - Example: `features/005-skill-integration/` → NNN = `005`, name = `skill-integration`
2. Check if `scripts/bash/create-feature-branch.sh` exists (use Glob: `scripts/bash/create-feature-branch.sh`)
3. **If found:** run: `bash scripts/bash/create-feature-branch.sh <NNN> <name> --json`
   - `status: "created"` → include in confirmation: "Branch created: feat-NNN-name"
   - `status: "exists"` → include: "Branch already exists: feat-NNN-name (checked out)"
   - `status: "error"` → surface the error message; note that spec.md was saved successfully; tell user to resolve the issue (e.g. commit or stash dirty files) and re-run `/mema.specify`
4. **If not found:** note: "Git scripts not installed — run `npx mema-kit` to enable automatic branch creation."

### Confirm to User

```
Spec saved: features/[NNN-name]/spec.md
Branch:     [feat-NNN-name (created) | feat-NNN-name (exists) | error — see above | scripts not installed]

[Feature name]: [one-line purpose summary]
[N] acceptance criteria defined

Next: /mema.plan [NNN-name]
```

## AUTO-SAVE & CURATE

- ADD or UPDATE `features/NNN-name/spec.md`
- UPDATE `features/NNN-name/status.md` to note spec is ready
- NOOP on all other files

## AUTO-INDEX

Update `.mema/index.md`:
1. Add or update entry in `## Active Features`: `- \`features/NNN-name/\` — [one-line description] (spec ready)`
2. Update `**Updated:**` date
