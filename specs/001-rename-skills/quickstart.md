# Quickstart: Validate the Skill Rename

This guide walks through verifying the rename was successful after implementation.

## Step 1: Check source directories exist with new names

```bash
ls skills/
# Expected output includes:
#   mema.onboard/
#   mema.recall/
#   mema.plan/
#   mema.implement/
#   mema.create-skill/
#   _memory-protocol.md
#
# Old names (onboard/, recall/, etc.) MUST NOT appear.
```

## Step 2: Verify no old skill names remain in source files

```bash
grep -r "/onboard\|/recall\|/plan\|/implement\|/create-skill" \
  skills/ docs/ CLAUDE.md README.md bin/cli.js \
  --include="*.md" --include="*.js" -l
# Expected: no output (zero matches across all files)
```

## Step 3: Install to a test project

```bash
mkdir /tmp/test-mema-rename && cd /tmp/test-mema-rename
node /path/to/mema-kit/bin/cli.js
# Expected output: "✓ mema-kit skills installed to .claude/skills/"
# Expected next step message: "run /mema.onboard"

ls .claude/skills/
# Expected: mema.onboard/ mema.recall/ mema.plan/ mema.implement/ mema.create-skill/
# Old names MUST NOT appear.
```

## Step 4: Verify SKILL.md internal references

```bash
grep -r "/onboard\|/recall\|/plan\|/implement\|/create-skill" \
  .claude/skills/ --include="*.md"
# Expected: no output
```

## Step 5: Spot-check docs/guide.md

Open `docs/guide.md` and confirm:

- The Quick Start section shows `> /mema.onboard` and `> /mema.recall`
- The guide's section headers reference `mema.recall`, `mema.plan`, `mema.implement`
- The Custom Skills section shows `> /mema.create-skill`
- No old names (`/onboard`, `/recall`, etc.) appear anywhere

## What success looks like

All five checks pass:
1. `ls skills/` shows `mema.*` directories only
2. `grep` for old names returns zero results across all source files
3. Installed test project contains `mema.*` directories only
4. `grep` inside installed test project returns zero results
5. `docs/guide.md` examples all use `mema.*` names
