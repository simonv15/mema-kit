# 09 — CLI & Packaging

**Produces:** `bin/cli.js`, `package.json`, repo structure ready for npm publish and Vercel Skills
**Milestone:** 5
**Dependencies:** All skills (01-08) must be complete and tested before packaging

---

## What This Component Does

The CLI is the primary distribution channel for Praxis-kit. Running `npx praxis-kit` copies skill files from the npm package into the user's project at `.claude/skills/`. It's a simple file-copying script — no build step, no compilation, no runtime dependencies.

The CLI does NOT:
- Create `.praxis/` (that's `/kickoff`'s job)
- Modify CLAUDE.md (that's `/kickoff`'s job)
- Touch `.gitignore` (that's `/kickoff`'s job)

This separation ("install the tool" vs. "set up the project") means every distribution channel (npm, Vercel Skills, manual copy) converges on the same `/kickoff` experience.

---

## Key Design Decisions

### 1. Zero runtime dependencies

**Decision: The CLI uses only Node.js built-in modules (`fs`, `path`, `process`).**

Reasoning:
- Every dependency is a potential point of failure: version conflicts, supply chain risk, increased package size.
- The CLI's job is trivially simple: copy files from A to B. Node.js built-ins handle this perfectly.
- Zero dependencies means the package installs instantly (no dependency tree to resolve) and works on any Node.js version that supports ES modules or CommonJS.
- This also makes the package tiny (<50KB), which is ideal for `npx` usage where the package is downloaded on every run.

Alternative considered: Use `fs-extra` for recursive directory copying. Rejected because `fs.cpSync` (Node.js 16.7+) handles recursive copy natively. For older Node versions, a simple recursive copy function is ~10 lines.

### 2. File structure in the npm package

**Decision: Include only `bin/`, `skills/`, and `templates/` in the published package.**

```
praxis-kit (npm package)
├── bin/
│   └── cli.js          # Entry point for npx praxis-kit
├── skills/
│   ├── _memory-protocol.md
│   ├── kickoff/SKILL.md
│   ├── profile/SKILL.md
│   ├── explore/SKILL.md
│   ├── plan-docs/SKILL.md
│   ├── gen-test/SKILL.md
│   └── implement/SKILL.md
└── templates/           # Memory file templates (used by /kickoff's inline content)
    ├── decision.md
    ├── context.md
    ├── plan.md
    ├── lessons.md
    ├── patterns.md
    └── status.md
```

Reasoning:
- `bin/cli.js` is the entry point. npm runs it when the user executes `npx praxis-kit`.
- `skills/` contains all SKILL.md files — the core product.
- `templates/` is included for reference and for the Vercel Skills channel. Note: `/kickoff` has templates inline in its SKILL.md, so it doesn't read from `templates/` at runtime. But including them in the package allows manual-copy users to find them.
- `docs/`, `tests/`, `.github/`, `README.md`, `CLAUDE.md` are excluded from the published package via the `files` field in package.json. They're useful for development but not for users.

### 3. What the CLI copies

**Decision: Copy the entire `skills/` directory to `.claude/skills/` in the user's project.**

The CLI copies:
- `_memory-protocol.md` → `.claude/skills/_memory-protocol.md`
- `kickoff/SKILL.md` → `.claude/skills/kickoff/SKILL.md`
- `profile/SKILL.md` → `.claude/skills/profile/SKILL.md`
- `explore/SKILL.md` → `.claude/skills/explore/SKILL.md`
- `plan-docs/SKILL.md` → `.claude/skills/plan-docs/SKILL.md`
- `gen-test/SKILL.md` → `.claude/skills/gen-test/SKILL.md`
- `implement/SKILL.md` → `.claude/skills/implement/SKILL.md`

Reasoning:
- Simple 1:1 mapping. The structure in the npm package mirrors the structure in the user's project.
- No transformation, compilation, or merging needed.
- The `.claude/skills/` directory is the standard Claude Code location for skills. Any other location would require custom configuration.

### 4. Version tracking in installed files

**Decision: Add a version comment to each installed file for upgrade detection.**

Each file gets a comment appended (or prepended): `<!-- praxis-kit v1.0.0 -->`

Reasoning:
- When a user runs `npx praxis-kit --update`, the CLI needs to know if files are outdated.
- Comparing the installed version comment with the current package version is simple and reliable.
- The version comment is an HTML comment — invisible in rendered markdown, non-disruptive to the SKILL.md content.
- Without version tracking, the `--update` flag would have to do content comparison (slow, complex, fragile) or always overwrite (might overwrite user customizations).

### 5. The `--update` flag

**Decision: `--update` replaces skill files and protocol only. It never touches `.praxis/`, CLAUDE.md, or `.gitignore`.**

Reasoning:
- Users customize `.praxis/` files (memory data), CLAUDE.md (profile + custom content), and `.gitignore`. An update should NEVER touch these.
- Skill files and the protocol are authored by Praxis-kit, not the user. Replacing them with newer versions is safe.
- Edge case: a user who customized a SKILL.md (rare but possible) would lose their changes. The CLI should warn: "This will replace all skill files with the latest version. Any customizations will be lost. Continue? (y/N)"
- The update checks version comments to avoid unnecessary writes if files are already current.

### 6. Exit messaging

**Decision: After installation, print a clear getting-started message.**

```
✓ Praxis-kit skills installed to .claude/skills/

Next step: Open your project in Claude Code and run /kickoff

  cd your-project
  claude
  > /kickoff
```

Reasoning:
- The user needs to know what to do next. Without this message, they might think installation is complete (it's half-done — `/kickoff` still needs to run).
- The message is brief and actionable. No lengthy documentation in the terminal.
- The `cd your-project` line adapts to the actual directory name.

---

## Implementation Guide

### Step 1: Create package.json

```json
{
  "name": "praxis-kit",
  "version": "1.0.0",
  "description": "Spec-driven development kit for Claude Code with intelligent memory management",
  "bin": {
    "praxis-kit": "./bin/cli.js"
  },
  "files": [
    "bin/",
    "skills/",
    "templates/"
  ],
  "keywords": [
    "claude-code",
    "ai-coding",
    "development-workflow",
    "tdd",
    "claude-skills"
  ],
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/simonv15/praxis-kit.git"
  },
  "engines": {
    "node": ">=16.7.0"
  }
}
```

Key fields explained:
- `bin` — maps the `praxis-kit` command to `bin/cli.js`. This is what `npx` invokes.
- `files` — controls what's included in the published package. Only these directories are packaged.
- `engines` — Node 16.7+ is required for `fs.cpSync`. If supporting older versions, implement a recursive copy helper.
- No `dependencies` — zero external packages.
- `license` — MIT is recommended for maximum adoption. The plan's open question about MIT vs. Apache 2.0 is resolved here: MIT is simpler and more permissive, which matters for a developer tool.

### Step 2: Create bin/cli.js

The CLI script handles three modes:
1. `npx praxis-kit` — fresh install
2. `npx praxis-kit --update` — update existing installation
3. `npx praxis-kit --help` — show usage

### Step 3: Write the CLI script

Below is the full implementation:

```javascript
#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const VERSION = require('../package.json').version;
const VERSION_COMMENT = `<!-- praxis-kit v${VERSION} -->`;

// Paths
const packageRoot = path.resolve(__dirname, '..');
const skillsSource = path.join(packageRoot, 'skills');
const targetDir = path.join(process.cwd(), '.claude', 'skills');

// Parse arguments
const args = process.argv.slice(2);
const isUpdate = args.includes('--update');
const isHelp = args.includes('--help') || args.includes('-h');

if (isHelp) {
  printHelp();
  process.exit(0);
}

if (isUpdate) {
  runUpdate();
} else {
  runInstall();
}

function runInstall() {
  // Check if skills already exist
  if (fs.existsSync(targetDir)) {
    const hasSkills = fs.readdirSync(targetDir).some(f => f.endsWith('.md') || fs.statSync(path.join(targetDir, f)).isDirectory());
    if (hasSkills) {
      console.log('⚠  Praxis-kit skills already exist in .claude/skills/');
      console.log('   Use --update to replace with the latest version.');
      console.log('   Or delete .claude/skills/ and run again for a fresh install.');
      process.exit(1);
    }
  }

  // Create target directory
  fs.mkdirSync(targetDir, { recursive: true });

  // Copy all skills
  copySkills();

  console.log('✓ Praxis-kit skills installed to .claude/skills/');
  console.log('');
  console.log('Next step: Open your project in Claude Code and run /kickoff');
  console.log('');
  console.log('  claude');
  console.log('  > /kickoff');
  console.log('');
}

function runUpdate() {
  if (!fs.existsSync(targetDir)) {
    console.log('⚠  No .claude/skills/ directory found.');
    console.log('   Run npx praxis-kit (without --update) for a fresh install.');
    process.exit(1);
  }

  // Check current version
  const protocolPath = path.join(targetDir, '_memory-protocol.md');
  if (fs.existsSync(protocolPath)) {
    const content = fs.readFileSync(protocolPath, 'utf8');
    const versionMatch = content.match(/<!-- praxis-kit v([\d.]+) -->/);
    if (versionMatch && versionMatch[1] === VERSION) {
      console.log(`✓ Praxis-kit skills are already at v${VERSION}. No update needed.`);
      process.exit(0);
    }
    if (versionMatch) {
      console.log(`Updating Praxis-kit skills from v${versionMatch[1]} to v${VERSION}...`);
    }
  }

  // Copy (overwrite) all skills
  copySkills();

  console.log(`✓ Praxis-kit skills updated to v${VERSION}`);
  console.log('');
  console.log('  .praxis/ and CLAUDE.md were not modified.');
  console.log('');
}

function copySkills() {
  const entries = fs.readdirSync(skillsSource, { withFileTypes: true });

  for (const entry of entries) {
    const sourcePath = path.join(skillsSource, entry.name);
    const targetPath = path.join(targetDir, entry.name);

    if (entry.isDirectory()) {
      // Skill directory (e.g., kickoff/)
      fs.mkdirSync(targetPath, { recursive: true });
      const files = fs.readdirSync(sourcePath);
      for (const file of files) {
        const content = fs.readFileSync(path.join(sourcePath, file), 'utf8');
        fs.writeFileSync(path.join(targetPath, file), addVersionComment(content));
      }
    } else if (entry.isFile() && entry.name.endsWith('.md')) {
      // Standalone file (e.g., _memory-protocol.md)
      const content = fs.readFileSync(sourcePath, 'utf8');
      fs.writeFileSync(targetPath, addVersionComment(content));
    }
  }
}

function addVersionComment(content) {
  // Remove any existing version comment
  const cleaned = content.replace(/<!-- praxis-kit v[\d.]+ -->\n?/, '');
  // Add current version at the end
  return cleaned.trimEnd() + '\n\n' + VERSION_COMMENT + '\n';
}

function printHelp() {
  console.log(`
praxis-kit v${VERSION} — Spec-driven development kit for Claude Code

Usage:
  npx praxis-kit            Install skills to .claude/skills/
  npx praxis-kit --update   Update skills to the latest version
  npx praxis-kit --help     Show this help message

After installing, open your project in Claude Code and run /kickoff.

Learn more: https://github.com/simonv15/praxis-kit
  `.trim());
}
```

### Step 4: Make the CLI executable

```bash
chmod +x bin/cli.js
```

The `#!/usr/bin/env node` shebang at the top ensures it runs with Node.js.

### Step 5: Test all distribution paths

1. **Fresh install:**
   ```bash
   cd /tmp/test-project
   npx praxis-kit
   # Verify: .claude/skills/ contains all files with version comments
   ```

2. **Update:**
   ```bash
   # Change a SKILL.md in the package source
   npx praxis-kit --update
   # Verify: files are replaced, .praxis/ is untouched
   ```

3. **Already installed:**
   ```bash
   npx praxis-kit  # Should warn and exit
   ```

4. **Help:**
   ```bash
   npx praxis-kit --help
   ```

5. **Vercel Skills compatibility:**
   ```bash
   # The skills/ directory should follow Vercel's expected format
   # Each skill has a SKILL.md with YAML frontmatter
   ```

### Step 6: Prepare for npm publish

```bash
# Verify package contents
npm pack --dry-run
# Should list only: bin/cli.js, skills/**, templates/**

# Publish
npm publish
```

---

## Vercel Skills Compatibility

The `skills/` directory is structured to work with Vercel Skills out of the box:

```
skills/
├── _memory-protocol.md       # Shared file (not a skill)
├── kickoff/SKILL.md           # /kickoff command
├── profile/SKILL.md           # /profile command
├── explore/SKILL.md           # /explore command
├── plan-docs/SKILL.md         # /plan-docs command
├── gen-test/SKILL.md          # /gen-test command
└── implement/SKILL.md         # /implement command
```

Vercel Skills expects:
- Each skill in its own directory
- A `SKILL.md` file with YAML frontmatter containing at least a `description` field
- The directory name becomes the command name

Our structure matches this exactly. `npx skills add github/praxis-kit` should work without any additional configuration.

The `_memory-protocol.md` file (underscore prefix, no directory wrapper, no frontmatter) is not picked up as a skill by Vercel Skills. It's correctly treated as a supporting file that skills reference.

---

## Design Notes

### Why the CLI checks for existing skills before installing

A user might run `npx praxis-kit` twice by mistake. Without the check, the second run would silently overwrite all skill files. With the check, it warns the user and suggests `--update` for intentional upgrades.

This is a safety measure, not a restriction. The user can always delete `.claude/skills/` and reinstall from scratch.

### Why version comments go at the END of files, not the start

Placing the version comment at the start of a SKILL.md could potentially interfere with YAML frontmatter parsing. Some parsers expect `---` as the very first line. Placing it at the end is safe — nothing reads the end of a markdown file for structural purposes.

### Why the templates/ directory is included in the package

Even though `/kickoff` has templates inline in its SKILL.md, the `templates/` directory is useful for:
1. **Manual copy users** who want to see the templates separately
2. **Vercel Skills** which may expose the templates directory
3. **Developers contributing to Praxis-kit** who want to edit templates and see them reflected in the SKILL.md

It's a small cost (~5KB) for significant convenience.

### Future: plugin distribution

The plan mentions a future "Claude Code Plugin" distribution channel with auto-updates. This would require:
- A plugin manifest file
- Hook integration for auto-memory-saves
- A marketplace listing

This is explicitly deferred to post-v1.0. The npm CLI + Vercel Skills channels cover the MVP needs.
