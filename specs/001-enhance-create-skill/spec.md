# Feature Specification: Enhanced /mema.create-skill Skill

**Feature Branch**: `001-enhance-create-skill`
**Created**: 2026-02-27
**Status**: Draft
**Input**: User description: "I want to know how speckit work, what is workflow for development? and what I can apply for my mema-kit (at first, I want to enhance the /mema.create-skill skill)"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Generate Meaningful WORK Phase Content (Priority: P1)

A developer runs `/mema.create-skill` and describes their skill's purpose in one or two sentences. Currently the generated SKILL.md WORK phase contains only generic placeholder lines like `[First action]`, `[Second action]`, `[Third action]`. With this enhancement, the generated WORK phase steps are derived from the purpose description — concrete, purposeful actions rather than empty scaffolding that requires manual filling.

**Why this priority**: The most common complaint with the current skill is that users receive a shell with placeholders. The WORK phase is the entire value of a skill — generating it meaningfully is the core enhancement.

**Independent Test**: Can be fully tested by running `/mema.create-skill` with a descriptive purpose and verifying the resulting SKILL.md WORK phase contains zero `[First action]`-style placeholders, with steps that directly relate to the described purpose.

**Acceptance Scenarios**:

1. **Given** a user provides the purpose "review the project's git log and extract architectural lessons", **When** the skill is generated, **Then** the WORK phase contains steps specific to reading git history, identifying patterns, and formatting lessons — not generic placeholders.
2. **Given** a user provides a vague one-word purpose like "audit", **When** the skill is generated, **Then** the skill asks a focused follow-up question to clarify scope before generating WORK phase content.
3. **Given** a user provides a complex multi-concern purpose, **When** the skill is generated, **Then** the WORK phase organizes steps into labeled sub-sections (e.g., "### 2a: Gather", "### 2b: Analyze") matching the described concerns.

---

### User Story 2 - Preview Before Writing (Priority: P2)

A developer is prompted to review the fully rendered SKILL.md content in the conversation before it is written to disk. They can approve it, request targeted changes, or cancel. The file is written only after explicit approval.

**Why this priority**: Writing directly to disk without preview has caused users to end up with skills they immediately delete. A preview step prevents wasted iterations and builds trust in the generated output.

**Independent Test**: Can be fully tested by running `/mema.create-skill` end-to-end and confirming no file is created until the user explicitly approves the previewed content.

**Acceptance Scenarios**:

1. **Given** the skill finishes generating content, **When** the preview is shown, **Then** the user sees the full SKILL.md rendered inline in the conversation before any file is written.
2. **Given** the user says "change the WORK phase to include X", **When** they respond to the preview, **Then** the skill revises only the requested section and re-shows the preview without restarting the interview.
3. **Given** the user approves the preview, **When** the file is written, **Then** the disk contents exactly match what was shown in the preview.
4. **Given** the user says "cancel", **When** they respond to the preview, **Then** no file is created or modified.

---

### User Story 3 - Update Existing Skills (Priority: P3)

A developer re-runs `/mema.create-skill` using the name of an existing skill they previously created. Instead of a blunt "file already exists, overwrite?" warning, the skill detects the existing content, presents what would change, and offers three options: enhance the existing skill, overwrite with a fresh generation, or cancel.

**Why this priority**: Skills evolve. The current binary "overwrite or cancel" forces users to manually edit existing skills or risk losing customizations. Supporting in-place enhancement enables iterative skill improvement.

**Independent Test**: Can be fully tested by running `/mema.create-skill` twice with the same skill name — the second run must detect the existing skill and present the three options without modifying anything until the user chooses.

**Acceptance Scenarios**:

1. **Given** a skill named `debug` already exists at `.claude/skills/debug/SKILL.md`, **When** the user runs `/mema.create-skill` with name `debug`, **Then** the skill shows the existing skill's description and phases, then offers: (A) Enhance existing, (B) Overwrite with new, (C) Cancel.
2. **Given** the user chooses "Enhance existing" and describes what to change, **When** the enhancement is applied, **Then** only the specified sections are modified; all other existing content is preserved.
3. **Given** the user chooses "Overwrite", **When** confirmed, **Then** the existing file is replaced with the newly generated content (goes through the preview step first).

---

### Edge Cases

- What happens when the user provides a skill name that conflicts with a built-in mema.* skill (e.g., `create-skill`, `onboard`)?
- How does the skill handle a purpose description that spans multiple unrelated concerns (should it split into multiple skills or combine)?
- What happens if the user requests changes to the preview more than three times — does the interview restart, or does it continue refining?
- How does the skill behave if the `.claude/skills/` directory does not exist when writing?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The skill MUST generate purposeful, non-placeholder WORK phase steps derived directly from the user's described skill purpose.
- **FR-002**: The skill MUST display the fully generated SKILL.md content inline for the user to review before writing any file to disk.
- **FR-003**: The user MUST be able to request targeted revisions to the previewed content without restarting the interview; the skill revises only the requested section and re-presents the preview.
- **FR-004**: The skill MUST detect when a skill with the given name already exists and present three choices: Enhance, Overwrite (with preview), or Cancel.
- **FR-005**: When enhancing an existing skill, the skill MUST preserve all sections the user did not explicitly request to change.
- **FR-006**: The skill MUST warn the user if the requested skill name matches a built-in mema.* skill name before proceeding.
- **FR-007**: The skill MUST generate relevant memory file hints in the AUTO-LOAD phase that reflect the skill's described purpose, not only the default generic list.
- **FR-008**: The skill MUST validate that the generated SKILL.md includes required elements (description frontmatter, phase structure matching complexity level, reference to `_memory-protocol.md` for standard/advanced) before presenting the preview.

### Key Entities

- **Skill Definition**: A SKILL.md file in `.claude/skills/[name]/` containing frontmatter description, named phases, and purpose-specific instructions. Key attributes: name, complexity level, memory access mode (read/write/both), phase structure.
- **Generated WORK Phase**: The section of SKILL.md describing the skill's core actions. Derived from user's purpose description; must contain zero unresolved placeholder text before writing.
- **Memory Hint List**: The suggested set of `.mema/` file paths listed in AUTO-LOAD, tailored to the skill's domain.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Zero `[placeholder]`-style unresolved tokens remain in any generated SKILL.md WORK phase written to disk — measurable by automated text scan of output files.
- **SC-002**: Users require no more than one revision request after the initial preview before approving the generated skill — measured by average revision rounds before approval dropping below 1.5.
- **SC-003**: When re-running the skill on an existing skill name, 100% of cases present the three-choice prompt rather than immediately overwriting or erroring — measurable by testing with any pre-existing skill file.
- **SC-004**: Generated skills reference purpose-relevant memory file paths in AUTO-LOAD (not solely the default list) — measurable by checking that at least one AUTO-LOAD entry differs from the boilerplate default list when the purpose implies a distinct domain.

## Assumptions

- The three complexity levels (simple, standard, advanced) are preserved as-is; this enhancement improves the *quality* of generated content within each level, not the level structure itself.
- Built-in mema.* skill directories under `skills/` are considered protected; the skill warns before allowing a user to create a `.claude/skills/` entry with the same name.
- The preview is rendered as a markdown code block in the conversation — no new UI components are required.
- "Enhance existing" mode uses the user's natural-language description of changes as the directive; it does not diff or merge files programmatically.
- The skill continues to operate with zero runtime dependencies (reads and writes using Claude Code's native file tools only).
