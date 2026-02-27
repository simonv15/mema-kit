# Data Model: Rename Skills to mema.* Namespace

This feature has no data entities in the traditional sense (no database schemas,
no runtime objects). The "data model" here is the **skill name mapping** — the
authoritative table of old-to-new names that every file edit must agree with.

## Skill Name Mapping (Canonical)

| Old Command      | New Command           | Old Directory          | New Directory             |
|------------------|-----------------------|------------------------|---------------------------|
| `/onboard`       | `/mema.onboard`       | `skills/onboard/`      | `skills/mema.onboard/`    |
| `/recall`        | `/mema.recall`        | `skills/recall/`       | `skills/mema.recall/`     |
| `/plan`          | `/mema.plan`          | `skills/plan/`         | `skills/mema.plan/`       |
| `/implement`     | `/mema.implement`     | `skills/implement/`    | `skills/mema.implement/`  |
| `/create-skill`  | `/mema.create-skill`  | `skills/create-skill/` | `skills/mema.create-skill/` |

**Rule**: Every place in the codebase that references a skill command by name MUST
use the "New Command" column after this feature is implemented.

## File Impact Map

| File | Old References | Notes |
|------|---------------|-------|
| `skills/onboard/SKILL.md` | `/onboard`, `/recall`, `/create-skill` | 3 internal refs |
| `skills/recall/SKILL.md` | `/recall`, `/onboard` | 4 refs (incl. header) |
| `skills/plan/SKILL.md` | `/plan`, `/onboard`, `/implement` | 6 refs |
| `skills/implement/SKILL.md` | `/implement`, `/onboard`, `/plan` | 6 refs |
| `skills/create-skill/SKILL.md` | `/create-skill`, `/onboard` | 3 refs |
| `bin/cli.js` | `/onboard` | 3 occurrences in output strings |
| `docs/guide.md` | All 5 names | ~25 occurrences across code blocks |
| `CLAUDE.md` | All 5 names | ~6 occurrences in overview + architecture |
| `README.md` | `/onboard`, `/recall`, `/create-skill` | ~7 occurrences |
| `.specify/memory/constitution.md` | `/recall`, `/onboard` | 2 occurrences |

## Scope Boundary

- **In scope**: All files listed above.
- **Out of scope**: `.mema/` memory files (no skill names stored there).
- **Out of scope**: `templates/` directory (memory file templates, no skill names).
- **Out of scope**: `specs/` directory (this feature's spec/plan files — frozen as-is).
- **Out of scope**: Migrating previously installed `.claude/skills/` in user projects.
  Users re-run `npx mema-kit --update` to get the new names.
