---
description: Refine a raw idea through targeted Q&A and save a structured summary of the clarified intent, audience, and scope.
---

# /mema.clarify — Idea Clarification

You are executing the /mema.clarify skill. Follow these steps carefully.

This skill turns a raw seed into a clear, structured problem statement through 2-3 rounds of targeted questions.

## AUTO-LOAD

1. Read `.mema/index.md`
2. Read `.mema/product/seed.md`
3. If `seed.md` is missing:
   - Tell the user: "No seed found. Run `/mema.seed` first, or describe your idea now and I'll treat it as the seed."
   - If the user provides an inline description, use it as the seed (save it to `product/seed.md` first)
4. If `product/clarify.md` exists, read it to understand what was already clarified

## WORK

### Mirror Understanding

Before asking questions, confirm your understanding of the idea:

```
Here's what I understand from your seed:

[2-3 sentence summary of the idea]

Is this roughly right? (Say yes to proceed, or correct anything)
```

If the user corrects something significant, update your understanding before continuing.

### Ask Clarifying Questions

Ask **3-5 targeted questions** covering:

1. **Problem**: What specific pain point does this solve? Who experiences it right now?
2. **Audience**: Who is the primary user? Be specific — not "developers" but "solo developers who use Claude Code daily."
3. **Motivation**: Why does this need to exist? What's wrong with existing solutions?
4. **Scope**: What's the smallest version that delivers real value? What's explicitly out of scope?
5. **Constraints**: Any technical, budget, time, or team constraints to know about?

Do not ask all 5 at once if the seed already answers some. Skip questions that are already clear from context.

Allow follow-up rounds if answers raise new questions. Stop when the idea feels crisp — usually 2-3 exchanges.

### Handle Re-run

If `clarify.md` already exists, show the current summary and ask:

"Clarification exists from [date]. Would you like to refine specific sections or start fresh?"

- **Refine**: update named sections
- **Fresh**: overwrite `clarify.md`

### Save

Write `.mema/product/clarify.md`:

```
# [Project Name] — Clarified Intent

**Status:** active | **Updated:** [today's date]

## Problem Being Solved

[Specific problem — not "people need X" but "when Y happens, users can't Z because..."]

## Target Audience

[Specific description — role, context, pain point they experience]

## Motivation

[Why this needs to exist; what's wrong with current alternatives]

## Scope

**In scope:**
- [Core capability 1]
- [Core capability 2]

**Out of scope:**
- [Explicitly deferred item]

## Constraints

[Any technical, time, budget, or team constraints]
```

### Guide Next Step

```
Next: Run /mema.research to find what already exists and validate your approach.
```

## AUTO-SAVE & CURATE

- ADD or UPDATE `product/clarify.md`
- NOOP on all other memory files

## AUTO-INDEX

Update `.mema/index.md`:
1. Add or update entry under `## Product Discovery`: `- \`product/clarify.md\` — Clarified intent: [audience] + [core problem in 5 words]`
2. Update `**Updated:**` date
