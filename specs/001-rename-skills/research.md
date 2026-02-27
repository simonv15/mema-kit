# Research: Rename Skills to mema.* Namespace

## Question 1: Do dots work in Claude Code skill directory names?

**Decision**: Yes — dots are valid in Claude Code skill directory names.

**Rationale**: The `speckit.*` family of skills (`speckit.plan`, `speckit.specify`,
`speckit.constitution`, etc.) are actively installed and running in this project's
session. These skills use dots in their directory names and resolve to `/speckit.*`
slash commands without issue. This is direct empirical evidence that the planned
`mema.*` naming scheme will work.

**Alternatives considered**:
- `mema-onboard` (hyphen separator) — rejected; less clearly namespaced,
  harder to distinguish as a "mema-kit skill" vs. any random kebab-case skill.
- `mema/onboard` (subdirectory) — rejected; Claude Code does not resolve nested
  directories as `/parent/child` commands; only flat directories inside
  `.claude/skills/` are treated as skills.
- Keep existing names — rejected; the user explicitly requested namespacing.

---

## Question 2: What files need to change?

**Decision**: 8 locations require edits. No database changes, no new dependencies.

| File/Location | Change Type | Old Text → New Text |
|---------------|-------------|---------------------|
| `skills/onboard/` (dir) | Rename directory | `onboard/` → `mema.onboard/` |
| `skills/recall/` (dir) | Rename directory | `recall/` → `mema.recall/` |
| `skills/plan/` (dir) | Rename directory | `plan/` → `mema.plan/` |
| `skills/implement/` (dir) | Rename directory | `implement/` → `mema.implement/` |
| `skills/create-skill/` (dir) | Rename directory | `create-skill/` → `mema.create-skill/` |
| `skills/*/SKILL.md` (5 files) | Text replacement | All `/onboard`, `/recall`, etc. refs |
| `bin/cli.js` | Text replacement | 3 occurrences of `/onboard` |
| `docs/guide.md` | Text replacement | All skill command examples |
| `CLAUDE.md` | Text replacement | Skill names in Overview + Architecture |
| `README.md` | Text replacement | Table + Quick Start examples |
| `.specify/memory/constitution.md` | Text replacement | 2 occurrences |

**Rationale**: The CLI (`bin/cli.js`) does not reference skill directory names
directly in the copy logic — it copies whatever directories exist in `skills/`.
So renaming the directories is sufficient to fix the installed behavior; the
only text changes in `cli.js` are in printed help/output strings.

**Alternatives considered**:
- Alias approach (keep old dirs, add new ones) — rejected per spec; the user
  requested a clean rename with no backward-compat aliases.
- Automated regex script — noted as an option for implementation, but not
  required; targeted edits per file are clearer and safer.

---

## Question 3: Are there any references inside generated CLAUDE.md content?

**Decision**: Yes — the `/onboard` SKILL.md generates a CLAUDE.md for user projects
that references skill names. This content lives inside `skills/onboard/SKILL.md`
and will be updated as part of the SKILL.md content edits.

**Rationale**: The onboard skill writes a CLAUDE.md to the user's project that
describes the five skills. Once `onboard/SKILL.md` (renamed to `mema.onboard/SKILL.md`)
is updated to reference `mema.*` names, future `/mema.onboard` runs will produce
correct CLAUDE.md content in user projects.

---

## Question 4: Does `_memory-protocol.md` reference skill names?

**Decision**: No changes needed to `_memory-protocol.md`.

**Rationale**: A grep confirms `_memory-protocol.md` contains no references to
specific skill invocation names (`/onboard`, `/recall`, etc.). It describes the
4-phase protocol abstractly. No edits required.
