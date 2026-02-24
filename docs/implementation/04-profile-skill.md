# 04 — Profile Skill

**Produces:** `skills/profile/SKILL.md`
**Milestone:** 1
**Dependencies:** 03-kickoff-skill (CLAUDE.md must exist, though `/profile` should work even without `/kickoff`)

---

## What This Skill Does

`/profile` creates a `# About Me` section in CLAUDE.md that tells Claude who the developer is. Because Claude Code reads CLAUDE.md at the start of every conversation, this profile is always loaded — the agent always knows your skill level, preferences, and communication style.

This is a simple but high-impact skill. The profile affects every future interaction:
- A beginner profile gets more explanations and simpler code
- An expert profile gets concise responses and advanced patterns
- A "prefer TypeScript" profile ensures the agent defaults to TypeScript, not JavaScript
- A "explain trade-offs" preference means the agent discusses alternatives instead of just picking one

---

## Key Design Decisions

### 1. Where the profile lives: CLAUDE.md, not `.praxis/`

**Decision: Write the profile to CLAUDE.md as an `# About Me` section.**

Reasoning:
- CLAUDE.md is loaded by Claude Code **automatically at the start of every conversation**. This is exactly the behavior we want for a profile — always present, zero manual loading.
- `.praxis/` files need to be explicitly loaded by skills. If the profile were in `.praxis/`, the agent would need to load it at the start of every session — an extra step that could be forgotten.
- The profile is small (~10-15 lines). It fits easily in CLAUDE.md without bloating it.
- The profile is also useful for **non-Praxis skills**. If the user asks Claude a general question (not via a Praxis skill), the profile in CLAUDE.md still applies. If it were in `.praxis/`, only Praxis skills would see it.

Alternative considered: Store in `.praxis/agent-memory/profile.md` and have each skill load it. Rejected because it adds a loading step to every skill and doesn't benefit from CLAUDE.md's automatic loading.

### 2. What to ask the developer

**Decision: Ask about four dimensions that meaningfully change agent behavior.**

The four dimensions and why each matters:

| Dimension | Why it matters | How it changes behavior |
|-----------|---------------|------------------------|
| **Experience level** | Determines explanation depth and code complexity | Beginner: more comments, simpler patterns, step-by-step explanations. Expert: concise code, advanced patterns, skip obvious explanations. |
| **Preferred languages/frameworks** | Eliminates "which language should I use?" ambiguity | Agent defaults to stated preferences instead of guessing or asking. |
| **Working style** | Aligns with how the developer thinks | "I like to see the big picture first" → agent starts with architecture. "I prefer incremental changes" → agent makes small commits. |
| **Communication preferences** | Sets the tone and verbosity | "Explain trade-offs" → agent discusses alternatives. "Be concise" → agent gives direct answers. "Show code first, explain after" → agent leads with implementation. |

Why NOT more dimensions:
- "Favorite editor" — irrelevant to agent behavior
- "Years of experience" — too vague; experience level covers this
- "Team size" — affects project decisions, not personal interaction style
- "Time zone" — irrelevant to agent behavior

We want the minimum set of dimensions that produces the maximum change in agent behavior. Four is the sweet spot — enough to meaningfully personalize, few enough to keep the profile under 15 lines.

### 3. Conversational approach, not a form

**Decision: Ask questions conversationally rather than presenting a rigid form.**

Reasoning:
- A form ("1. Experience level: [  ]  2. Languages: [  ]") feels mechanical and often produces terse, unhelpful answers.
- A conversational approach ("Tell me about yourself — what's your experience level? What languages do you prefer?") produces richer, more natural responses.
- The agent can follow up if an answer is vague ("You mentioned TypeScript — any particular frameworks you prefer?").
- The conversational format also lets the user volunteer information the questions don't cover ("I have ADHD so I prefer short responses").

The SKILL.md provides question prompts but instructs the agent to ask conversationally, not as a numbered list.

### 4. Profile format: narrative paragraph, not structured data

**Decision: Write the profile as a short narrative paragraph, not key-value pairs.**

Reasoning:
- A narrative profile ("I'm a senior backend engineer who prefers TypeScript and clean architecture. I like explanations of trade-offs and concise responses.") reads naturally and is easy for the LLM to interpret.
- Key-value format ("Experience: Senior\nLanguages: TypeScript, Python\nStyle: Concise") is parseable but feels robotic and loses nuance.
- The narrative can capture subtleties that structured data can't: "I'm experienced with React but new to backend" or "I prefer verbose error messages in code but concise chat responses."
- Since only an LLM reads this (not a parser), natural language is the optimal format.

### 5. Idempotency: update existing profile, don't duplicate

**Decision: If `# About Me` already exists in CLAUDE.md, replace it rather than appending a second one.**

Reasoning:
- Users will re-run `/profile` when their preferences change or when they want to update their profile.
- Appending a second `# About Me` section would confuse the agent — which profile is current?
- The replacement strategy: find the `# About Me` heading, find the next `#` heading (or end of file), replace everything between them.
- If no `# About Me` exists, append it at the end of CLAUDE.md (but before the `## Praxis-kit Workflow` section if it exists, so the profile appears in a logical position).

---

## Implementation Guide

### Step 1: Create the SKILL.md file structure

```
skills/
└── profile/
    └── SKILL.md
```

### Step 2: Write the SKILL.md

The skill has three phases:
1. **Assess current state** — check if CLAUDE.md exists, check for existing profile
2. **Ask questions** — conversational interview about the four dimensions
3. **Write profile** — compose and write the `# About Me` section

### Step 3: Test the conversation flow

Run `/profile` and verify:
- The agent asks about all four dimensions naturally
- It follows up on vague answers
- The generated profile captures all the information
- The profile is ~10-15 lines, not 30+ lines
- Re-running `/profile` updates (not duplicates) the section

---

## Full SKILL.md Content

```markdown
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
```

---

## Design Notes

### Why placement matters in CLAUDE.md

The `# About Me` section should appear **before** the `## Praxis-kit Workflow` section (if it exists). This is because:
1. CLAUDE.md is read top-to-bottom. Profile information (who the developer is) should come before workflow instructions (how to use the tools).
2. If CLAUDE.md gets truncated (unlikely but possible with very long files), the profile is more important to preserve than the workflow reference.

### Why not store the profile in `.praxis/`?

This question comes up because `.praxis/` is the memory system. But the profile is fundamentally different from project memory:
- **Project memory** is about the project (architecture, decisions, tasks). It's project-specific.
- **Profile** is about the developer. It applies to ALL projects, not just this one.
- CLAUDE.md is the native mechanism for "always-loaded" information. Using it for the profile is idiomatic.

In the future, if Praxis-kit supports global installation (`~/.claude/skills/`), the profile could live in a global CLAUDE.md. For now, project-local is the only option.

### Why the profile is capped at ~15 lines

CLAUDE.md is loaded into every conversation. With the Praxis-kit workflow section (~10 lines) and the profile (~15 lines), that's ~25 lines. This leaves plenty of room for user-added content while keeping the automatic token cost low.

A 50-line profile might feel thorough, but most of that information would rarely be relevant. The 15-line constraint forces the profile to focus on the highest-impact preferences — the ones that actually change agent behavior in most interactions.
