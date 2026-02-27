# Research: Enhanced /mema.create-skill

**Phase**: 0 — Outline & Research
**Branch**: `001-enhance-create-skill`
**Date**: 2026-02-27

## Decision 1: Memory-First Compliance for mema.create-skill Itself

**Question**: The current `mema.create-skill` skill has no AUTO-LOAD or AUTO-SAVE phases. Constitution Principle I (Memory-First) requires every skill to implement the 4-phase lifecycle. Should the enhancement add memory phases to the skill itself?

**Decision**: Yes — add minimal memory lifecycle.

**Rationale**: Principle I is non-negotiable. The skill should:
- AUTO-LOAD: Read `index.md` and `agent-memory/patterns.md` to inform what skill patterns already exist. This prevents generating skills that duplicate existing ones.
- AUTO-SAVE: When a new skill is created or updated, record a lightweight lesson in `agent-memory/patterns.md` (e.g., "Created skill X of type advanced for purpose Y"). This builds a corpus of skill authorship over time.
- AUTO-INDEX: Update `index.md` entry for `agent-memory/patterns.md` if modified.

**Alternatives considered**:
- Keep skill memory-free (rejected — violates Constitution Principle I)
- Full 4-phase with decisions/ file per skill created (rejected — too heavy; most skill creations don't warrant a standalone decision file)

---

## Decision 2: Preview-Before-Write Mechanism

**Question**: How should the preview step be expressed in SKILL.md so Claude reliably displays the full generated content and waits for approval before writing any file?

**Decision**: Add an explicit "Step 2.5: Draft Review" between content generation and file write. The step instructs Claude to:
1. Render the complete SKILL.md content inside a fenced markdown code block
2. Ask the explicit question: "Does this look correct? Reply **APPROVE** to write the file, describe a change to revise, or **CANCEL** to exit."
3. Loop: if the user requests a change, apply only the named section and re-show the full draft without restarting the interview
4. Write only after receiving APPROVE

**Rationale**: Explicit "APPROVE/CANCEL" protocol with a named step creates a clear, testable gate. The loop instruction prevents users from needing to restart the entire skill on minor revision requests.

**Alternatives considered**:
- Implicit approval (write file, then ask if satisfied) — rejected; file is already written at that point, defeating the purpose
- Separate `/mema.preview-skill` skill — rejected; violates Principle V (Simplicity), adds unnecessary command surface area

---

## Decision 3: Generating Meaningful WORK Phase Steps

**Question**: How should the skill instruct Claude to produce purposeful, non-placeholder WORK phase content from a one-sentence purpose description?

**Decision**: Add a structured generation prompt within Step 2 that instructs Claude to:
1. Decompose the purpose into 2–5 concrete actions ("what would a skilled developer do, step by step, to accomplish [purpose]?")
2. Translate each action into an imperative instruction sentence in the WORK phase
3. If the purpose has distinct sub-concerns (indicated by "and", multiple verbs, or conditional logic), organize WORK into sub-sections (2a, 2b, 2c)
4. Verification rule: before proceeding, scan the generated WORK phase — if any `[placeholder]`-style text remains, replace it before continuing

**Rationale**: Decomposing purpose into discrete developer actions is the most transferable general strategy. The scan-before-continue verification closes the loop without requiring external tooling.

**Alternatives considered**:
- Provide purpose-category lookup table (e.g., "if purpose mentions 'review' → use these steps") — rejected; too brittle and not exhaustive
- Ask user to enumerate WORK steps explicitly — rejected; defeats the skill's automation value

---

## Decision 4: Context-Relevant AUTO-LOAD Hints

**Question**: How should the enhanced skill generate memory-file hints in AUTO-LOAD that reflect the skill's domain, rather than a one-size-fits-all generic list?

**Decision**: In Step 2, after establishing the purpose and complexity level, instruct Claude to derive relevant memory file paths from the purpose description. Specifically:
- Always include: `project-memory/architecture.md` (nearly always relevant), `agent-memory/lessons.md`
- Conditionally include based on purpose keywords:
  - "decision", "choose", "compare" → `project-memory/decisions/` directory
  - "pattern", "reuse", "template" → `agent-memory/patterns.md`
  - "test", "validate", "check" → `agent-memory/lessons.md` (testing lessons)
  - "implement", "build", "create" → current task-memory if any active task exists
- Instruct Claude to generate the list and annotate each entry with why it's relevant

**Rationale**: Keyword-to-file mapping is lightweight and zero-dependency. It produces more targeted AUTO-LOAD sections without requiring the user to manually enumerate files.

**Alternatives considered**:
- Static generic list only (status quo) — rejected; this is what we're replacing
- Ask user to list relevant memory files — rejected; users don't know what's in memory when creating a skill

---

## Decision 5: Enhance vs. Overwrite for Existing Skills

**Question**: When re-running `mema.create-skill` on an existing skill name, what information should be shown and what actions offered?

**Decision**: Add an existence check at the start of Step 3 (Write). If the file exists:
1. Read and display the existing skill's `description` frontmatter and phase headers (not full content)
2. Offer three numbered options: (1) Enhance existing (keep structure, apply user-described changes), (2) Overwrite with new (go through preview step), (3) Cancel
3. For option 1 (Enhance): ask "What specifically should I change?" then apply only named sections, preserving everything else

**Rationale**: Showing headers + description (not full content) gives enough context without flooding the conversation. The three-option prompt is unambiguous and maps directly to the acceptance scenarios in the spec.

**Alternatives considered**:
- Show full existing content — rejected; too verbose for large skills
- Skip the choice and always go to enhance — rejected; user may want a clean start, so both paths must be available

---

## Summary: No External Research Needed

All five decisions above are resolvable from first principles using the project's own constitution, conventions, and the existing SKILL.md structure. No external API patterns, library docs, or external research required. This is consistent with Principle II (Zero Runtime Dependencies) — the skill is pure markdown.
