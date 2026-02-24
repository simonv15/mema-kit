---
description: Set up your developer profile so Claude knows your skill level, preferences, and working style. Written to CLAUDE.md for automatic loading every session.
---

# /profile — Developer Profile Setup

You are setting up the developer's profile. This profile will be written to CLAUDE.md so it's automatically loaded in every conversation. The goal is to understand who this developer is and how they prefer to work with AI.

## Step 1: Check Current State

1. Read `CLAUDE.md` (if it exists)
2. Check if it contains a `# About Me` section
3. If it does, read the existing profile and tell the user: "I found your existing profile. Would you like to update it or start fresh?"
4. If it doesn't, proceed to Step 2

## Step 2: Interview the Developer

Have a conversational exchange to learn about the developer. Ask about these four dimensions, but do it naturally — don't present a numbered list. Adapt your questions based on their answers.

**Dimensions to cover:**

1. **Experience level** — How experienced are they overall? Are they expert in some areas and beginner in others? Examples: "senior backend engineer, learning frontend", "junior developer 1 year in", "experienced full-stack, new to AI-assisted coding"

2. **Preferred languages and frameworks** — What do they like to code in? What's their current project stack? Examples: "TypeScript + React + Node.js", "Python with FastAPI", "Rust for systems, TypeScript for web"

3. **Working style** — How do they prefer to approach problems? Examples: "big picture first then details", "incremental small changes", "prototype fast then refine", "test-first TDD strict"

4. **Communication preferences** — How should you communicate with them? Examples: "explain trade-offs for major decisions", "be concise, skip explanations I'd already know", "show code first, explain after", "use lots of comments in code"

**Interview tips:**
- Ask 1-2 questions at a time, not all four at once
- Follow up if an answer is vague ("You mentioned TypeScript — any particular frameworks or patterns you prefer?")
- If the user gives a comprehensive answer unprompted, don't ask redundant follow-up questions
- Keep the interview to 2-3 exchanges maximum — don't over-interview

## Step 3: Compose the Profile

Write a concise profile paragraph (not key-value pairs) that captures all four dimensions. The profile should be:
- **Under 15 lines** (CLAUDE.md is loaded every session — every line costs tokens)
- **Natural language** (readable by both humans and AI)
- **Specific** (not "I like clean code" but "I prefer functions under 20 lines with descriptive names")
- **Action-oriented** (tells future Claude instances what to DO, not just who the person IS)

Example output (for reference — every profile will be different):

```
# About Me

I'm a mid-level backend engineer with 3 years of experience, primarily in TypeScript and Node.js. I'm comfortable with Express/Fastify and PostgreSQL, but still learning React for frontend work.

I prefer a test-first approach (TDD) and clean architecture with clear separation of concerns. I like incremental changes — small PRs over big rewrites.

When making architectural decisions, explain the trade-offs briefly. For implementation, show code first and explain only the non-obvious parts. Keep responses concise — I'll ask if I need more detail.
```

## Step 4: Write to CLAUDE.md

1. Read the current `CLAUDE.md`
2. If `# About Me` already exists:
   - Find the line with `# About Me`
   - Find the next line starting with `#` (any heading level) or end of file
   - Replace everything between those two markers with the new profile
3. If `# About Me` does not exist:
   - If a `## Praxis-kit Workflow` section exists, insert the profile **before** it (with a blank line separator)
   - Otherwise, append the profile at the end of the file
4. If `CLAUDE.md` doesn't exist, create it with just the profile

## Step 5: Confirm to the User

Show the user what was written:

```
Your profile has been saved to CLAUDE.md! Here's what I wrote:

[show the profile]

This will be loaded automatically in every conversation. Run /profile again anytime to update it.
```
