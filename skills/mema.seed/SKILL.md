---
description: Capture a raw idea and save it as the starting point for the mema-kit discovery workflow. Run this first when starting a new project from scratch.
---

# /mema.seed — Idea Capture

You are executing the /mema.seed skill. Follow these steps carefully.

This is the first step of the discovery workflow. It captures a raw idea — exactly as described, no editing — and saves it as the foundation for everything that follows.

## AUTO-LOAD

1. Check if `.mema/` exists
2. If it does, read `index.md` to check for an existing seed
3. If `.mema/` doesn't exist, create it with the `product/` subdirectory — this is a new project

## WORK

### Capture the Idea

Get the idea from one of these sources (in priority order):
1. **Inline argument** — everything after `/mema.seed` in the user's message
2. **Prompt** — if no argument, ask: "What's your idea? Don't worry about structure — just describe it."

Accept anything: one sentence, bullet points, stream of consciousness, half-formed thoughts. Do not edit, filter, or structure the input.

### Mirror Back

Repeat the idea back to the user exactly as captured:

```
Got it. Here's what I captured:

---
[Exact text of the idea]
---

Saved to .mema/product/seed.md
```

### Handle Re-run

If `product/seed.md` already exists, show the current content and ask:

"A seed already exists. Replace it with the new idea, or keep the existing one?"

- **Replace**: overwrite `seed.md` with new content
- **Keep**: exit without changes

### Save

Write `.mema/product/seed.md`:

```
# [Project Name or Working Title] — Seed

**Status:** active | **Updated:** [today's date]

## Raw Idea

[The idea exactly as described by the user — no editing]

## Initial Thoughts

[If the user included any meta-commentary ("I'm not sure about X", "maybe also Y"), capture it here. Otherwise omit this section.]
```

For the project name: use any name mentioned by the user, or derive a 2-3 word working title from the idea if no name was given.

### Guide Next Step

Tell the user:

```
Next: Run /mema.clarify to turn this into a crisp problem statement.
```

## AUTO-SAVE & CURATE

- ADD `product/seed.md` (or UPDATE on re-run)
- NOOP on all other memory files

## AUTO-INDEX

Update `.mema/index.md`:
1. Re-read the current index
2. Add or update entry under `## Product Discovery`: `- \`product/seed.md\` — [working title]: [one-line idea summary]`
3. Update `**Updated:**` date
