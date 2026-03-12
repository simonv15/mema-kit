---
description: Research competitors, market context, and technical options for your idea using web search. Saves findings to product/research.md.
---

# /mm.research — Discovery Research

You are executing the /mm.research skill. Follow these steps carefully.

This skill uses web search to investigate what already exists, validate market opportunity, and explore technical options. It informs the challenge and roadmap phases.

## AUTO-LOAD

1. Read `.mema/index.md`
2. Read `.mema/product/seed.md` (for the idea)
3. Read `.mema/product/clarify.md` (for audience and scope — skip if missing)
4. If `product/research.md` exists, read it to understand prior research

## WORK

### Parse Focus Area

If the user provided an optional focus area (e.g., `/mm.research competitors` or `/mm.research tech stack`), narrow the research to that area. Otherwise, run a full research sweep.

### Graceful Degradation

If web search is unavailable:
- Inform the user: "Web search is unavailable. I'll research from training knowledge and flag where real-time data would be needed."
- Proceed using training knowledge
- Clearly mark each finding with `[Training data — verify with current sources]`

### Research Areas

For each area, use the WebSearch tool with targeted queries:

**1. Existing Solutions**

Search for: `"[problem domain] tools"`, `"[problem] software"`, `"alternatives to [category]"`

For each solution found, capture: name, what it does, key strengths, key weaknesses, pricing model (if relevant), and how it relates to this idea.

**2. Market Context**

Search for: `"[domain] market size [current year]"`, `"[domain] trends"`, `"[audience] pain points"`

Capture: market size or growth signals, key trends, validated pain points, and any data that confirms or challenges the idea's assumptions.

**3. Technical Options**

Based on the clarified scope, search for: `"[technical capability] libraries [language]"`, `"how to build [core feature]"`, `"[technology choice 1] vs [technology choice 2]"`

Capture: viable technical approaches, key trade-offs, and any significant constraints or gotchas.

### Save

Write `.mema/product/research.md`:

```
# [Project Name] — Research

**Status:** active | **Updated:** [today's date]

## Existing Solutions

| Solution | What it does | Strengths | Weaknesses |
|----------|-------------|-----------|------------|
| [Name] | [One line] | [+] | [-] |

## Key Insight
[Most important thing the research revealed about the competitive landscape]

## Market Context

[Market size, trends, validated pain points — with source links]

## Technical Options

### [Option/Approach 1]
- What it is: [description]
- Best for: [when to use]
- Trade-offs: [pros/cons]

### [Option/Approach 2]
[same format]

## Recommended Approach
[Based on research findings, what approach fits best for this idea]

## Sources

- [Title](URL)
- [Title](URL)
```

### Guide Next Step

```
Next: Run /mm.challenge to stress-test the idea against these findings.
```

## AUTO-SAVE & CURATE

- ADD or UPDATE `product/research.md`
- NOOP on all other memory files

## AUTO-INDEX

Update `.mema/index.md`:
1. Add or update entry under `## Product Discovery`: `- \`product/research.md\` — [N] competitors found; recommended approach: [one-line]`
2. Update `**Updated:**` date
