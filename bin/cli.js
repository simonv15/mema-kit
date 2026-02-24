#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const VERSION = require('../package.json').version;
const VERSION_COMMENT = `<!-- mema-kit v${VERSION} -->`;

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
      console.log('⚠  mema-kit skills already exist in .claude/skills/');
      console.log('   Use --update to replace with the latest version.');
      console.log('   Or delete .claude/skills/ and run again for a fresh install.');
      process.exit(1);
    }
  }

  // Create target directory
  fs.mkdirSync(targetDir, { recursive: true });

  // Copy all skills
  copySkills();

  console.log('✓ mema-kit skills installed to .claude/skills/');
  console.log('');
  console.log('Next step: Open your project in Claude Code and run /onboard');
  console.log('');
  console.log('  claude');
  console.log('  > /onboard');
  console.log('');
}

function runUpdate() {
  if (!fs.existsSync(targetDir)) {
    console.log('⚠  No .claude/skills/ directory found.');
    console.log('   Run npx mema-kit (without --update) for a fresh install.');
    process.exit(1);
  }

  // Check current version
  const protocolPath = path.join(targetDir, '_memory-protocol.md');
  if (fs.existsSync(protocolPath)) {
    const content = fs.readFileSync(protocolPath, 'utf8');
    const versionMatch = content.match(/<!-- mema-kit v([\d.]+) -->/);
    if (versionMatch && versionMatch[1] === VERSION) {
      console.log(`✓ mema-kit skills are already at v${VERSION}. No update needed.`);
      process.exit(0);
    }
    if (versionMatch) {
      console.log(`Updating mema-kit skills from v${versionMatch[1]} to v${VERSION}...`);
    }
  }

  // Copy (overwrite) all skills
  copySkills();

  console.log(`✓ mema-kit skills updated to v${VERSION}`);
  console.log('');
  console.log('  .mema/ and CLAUDE.md were not modified.');
  console.log('');
}

function copySkills() {
  const entries = fs.readdirSync(skillsSource, { withFileTypes: true });

  for (const entry of entries) {
    const sourcePath = path.join(skillsSource, entry.name);
    const targetPath = path.join(targetDir, entry.name);

    if (entry.isDirectory()) {
      // Skill directory (e.g., onboard/)
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
  const cleaned = content.replace(/<!-- mema-kit v[\d.]+ -->\n?/, '');
  // Add current version at the end
  return cleaned.trimEnd() + '\n\n' + VERSION_COMMENT + '\n';
}

function printHelp() {
  console.log(`
mema-kit v${VERSION} — Memory protocol kit for Claude Code skills

Usage:
  npx mema-kit            Install skills to .claude/skills/
  npx mema-kit --update   Update skills to the latest version
  npx mema-kit --help     Show this help message

After installing, open your project in Claude Code and run /onboard.

Learn more: https://github.com/simonv15/mema-kit
  `.trim());
}
