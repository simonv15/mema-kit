# Feature Specification: Rename Skills to mema.* Namespace

**Feature Branch**: `001-rename-skills`
**Created**: 2026-02-27
**Status**: Draft
**Input**: User description: "I want to change name of skills, e.g, /onboard -> /mema.onboard and update related docs too"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Namespaced Skill Invocation (Priority: P1)

A developer who has installed mema-kit wants to invoke the built-in skills using the
new namespaced command names (e.g., `/mema.onboard` instead of `/onboard`). All five
skills are renamed so that the `mema.` prefix is prepended to each name, avoiding
conflicts with other Claude Code skills the developer may have installed.

**Why this priority**: This is the core deliverable. Until the skill directories are
renamed, no other change (docs, guide) is meaningful. Namespacing prevents name
collisions with other skill collections.

**Independent Test**: Run `npx mema-kit` on a clean project, then open Claude Code
and type `/mema.onboard` — the skill runs. Type `/onboard` — no such skill is found.
This delivers the full value of the rename with no other changes needed.

**Acceptance Scenarios**:

1. **Given** a project with a fresh mema-kit install, **When** the developer types
   `/mema.onboard` in Claude Code, **Then** the onboarding skill executes correctly.
2. **Given** a project with a fresh mema-kit install, **When** the developer types
   the old command `/onboard`, **Then** Claude Code does not find a matching skill.
3. **Given** all five skills are renamed, **When** the developer lists available
   skills in Claude Code, **Then** all five appear as `mema.onboard`, `mema.recall`,
   `mema.plan`, `mema.implement`, and `mema.create-skill`.

---

### User Story 2 - Internal Cross-Reference Consistency (Priority: P2)

A developer reading a SKILL.md file (e.g., inside `/mema.plan`) sees references to
other skills using their new namespaced names. When `/mema.plan` instructs the user
to run `/mema.implement`, that name matches exactly what Claude Code exposes.

**Why this priority**: Broken cross-references inside SKILL.md files are immediately
confusing and reduce trust in the tool. This must be fixed alongside the rename.

**Independent Test**: Open any SKILL.md file and search for references to skill
commands — every reference uses the `mema.` prefix. No old names (`/onboard`,
`/recall`, etc.) appear.

**Acceptance Scenarios**:

1. **Given** the skill files are updated, **When** a developer reads
   `skills/mema.plan/SKILL.md`, **Then** any reference to running another skill
   uses the new name (e.g., "run `/mema.implement`").
2. **Given** the `_memory-protocol.md` shared file is updated, **When** it
   references any built-in skill by name, **Then** it uses the new namespaced name.

---

### User Story 3 - Updated User-Facing Documentation (Priority: P3)

A developer reads `docs/guide.md` to learn how to use mema-kit. Every command
example in the guide uses the new `mema.*` names, so copy-pasting from the guide
works without modification.

**Why this priority**: Documentation is the primary onboarding path for new users.
Stale command names in the guide cause immediate confusion and failed first attempts.

**Independent Test**: Read `docs/guide.md` from top to bottom. Every skill invocation
example uses a `mema.*` name. Search for old names (`/onboard`, `/recall`, `/plan`,
`/implement`, `/create-skill`) — none are found.

**Acceptance Scenarios**:

1. **Given** the guide is updated, **When** a developer copies any command example
   from `docs/guide.md` into Claude Code, **Then** the command executes correctly.
2. **Given** the README or CLAUDE.md contains skill usage examples, **When** a
   developer reads them, **Then** all examples use `mema.*` names.
3. **Given** the `bin/cli.js` installer is updated, **When** a developer runs
   `npx mema-kit`, **Then** skills are installed under `mema.*` directory names.

---

### Edge Cases

- A developer who previously installed mema-kit has old skill directories
  (`.claude/skills/onboard/`, etc.) alongside the new namespaced ones. Both may
  coexist until the developer removes the old directories manually or re-runs
  `npx mema-kit` with a clean install. No automatic migration is provided.
- A SKILL.md file that references another skill by name (e.g., `/plan`) inside a
  quoted user example — the rename MUST update these references to preserve
  correctness.
- The skill `create-skill` becomes `mema.create-skill`. The dot in the name is
  valid in Claude Code skill directories; this MUST be verified before finalizing.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: All five built-in skill directories MUST be renamed from their current
  names (`onboard`, `recall`, `plan`, `implement`, `create-skill`) to their
  namespaced equivalents (`mema.onboard`, `mema.recall`, `mema.plan`,
  `mema.implement`, `mema.create-skill`) within the `skills/` source directory.
- **FR-002**: All references to skill invocation commands inside `skills/*/SKILL.md`
  files MUST be updated to use the new `mema.*` names.
- **FR-003**: The shared file `skills/_memory-protocol.md` MUST be updated to
  reference any built-in skill by its new namespaced name.
- **FR-004**: `docs/guide.md` MUST be updated so every command example uses the
  new `mema.*` names — no old names MUST remain.
- **FR-005**: `CLAUDE.md` at the repository root MUST reflect the new skill names
  in its Project Overview and any usage examples.
- **FR-006**: `bin/cli.js` MUST install skill directories under the new `mema.*`
  names when users run `npx mema-kit`.
- **FR-007**: Old skill directory names MUST NOT be present in the `skills/`
  source directory after the rename is complete.
- **FR-008**: All speckit skill files in `.specify/` that reference mema-kit skill
  names MUST be updated to use the new names.

### Assumptions

- Dots (`.`) are valid characters in Claude Code skill directory names, meaning
  a directory named `mema.onboard` will be invoked as `/mema.onboard`.
- No backward-compatible aliases for old names are required; this is a clean rename.
- No database migration or runtime state migration is needed — `.mema/` memory files
  are not affected by this rename.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All five `mema.*` skill commands are invocable in Claude Code after
  running `npx mema-kit` on a clean project — zero failures on first attempt.
- **SC-002**: Zero occurrences of old skill names (`/onboard`, `/recall`, `/plan`,
  `/implement`, `/create-skill`) remain in any file within `skills/`, `docs/`,
  `CLAUDE.md`, or `bin/cli.js`.
- **SC-003**: Every command example a developer copies from `docs/guide.md` works
  without modification after a fresh mema-kit install.
- **SC-004**: A full text search for the old command names across the repository
  returns zero results in source files (excluding git history and this spec).
