---
description: Stress-test your idea by challenging assumptions, identifying risks, and surfacing blind spots. Saves a risk register and recommendations to product/challenge.md.
---

# /mm.challenge — Idea Stress-Test

You are executing the /mm.challenge skill. Follow these steps carefully.

This skill plays devil's advocate — it examines the idea critically to find what could go wrong before any code is written. A challenge that kills a weak idea is a success.

## AUTO-LOAD

1. Read `.mema/index.md`
2. Read all available `product/` files:
   - `product/seed.md` — the raw idea
   - `product/clarify.md` — refined intent (if exists)
   - `product/research.md` — competitive and market findings (if exists)
3. Build a full picture of the idea before proceeding

## WORK

### Identify Assumptions

List every assumption the idea depends on. For each:
- **Validated**: supported by research or clear logic
- **Risky**: not yet validated; failure would significantly harm the project

Look for assumptions about: user behavior, market size, technical feasibility, competitive differentiation, and the team's ability to execute.

### Build Risk Register

For each significant risk:
- **What's the risk?** — specific failure mode, not vague concern
- **Severity**: High (project-threatening), Medium (costly), Low (manageable)
- **Likelihood**: High (likely without mitigation), Medium (possible), Low (unlikely)
- **Mitigation**: concrete action that reduces severity or likelihood

### Identify Blind Spots

What hasn't been considered?
- Regulatory, legal, or privacy constraints?
- Distribution and discovery — how will users find this?
- Monetization — if relevant, is there a clear path?
- What does the competition do better than this idea, not worse?
- What's the failure mode if the key assumption is wrong?

### Critical Risks

If any risks are both High severity AND High likelihood:
- Flag them explicitly
- Suggest a pivot or alternative approach if possible
- Do NOT hide critical problems — they're more valuable than false confidence

### Handle Re-run

If `challenge.md` already exists, show the previous summary and ask:

"Previous challenge from [date]. Run fresh challenge, or update specific sections?"

### Save

Write `.mema/product/challenge.md`:

```
# [Project Name] — Challenge

**Status:** active | **Updated:** [today's date]

## Assumptions

| Assumption | Status | Risk if Wrong |
|------------|--------|---------------|
| [Assumption] | ✓ Validated / ⚠ Risky | [Impact] |

## Risk Register

| Risk | Severity | Likelihood | Mitigation |
|------|----------|------------|------------|
| [Risk] | High/Med/Low | High/Med/Low | [Action] |

## Blind Spots

- [What hasn't been considered]

## Critical Concerns

[If any High/High risks: flag them clearly with recommended action]
[If no critical risks: "No critical risks identified. Proceed with caution on the risky assumptions above."]

## Recommended Actions Before Building

- [Validate assumption X by doing Y]
- [Resolve risk Z before committing to approach]
```

### Guide Next Step

```
Next: Run /mm.roadmap to synthesize everything into a project plan and feature list.
```

Or, if critical concerns were found:

```
⚠ Critical concerns found. Consider addressing them before building:
[List critical risks]

You can re-run /mm.clarify or /mm.research to address these, then re-run /mm.challenge.
Or proceed to /mm.roadmap if you've decided to accept these risks.
```

## AUTO-SAVE & CURATE

- ADD or UPDATE `product/challenge.md`
- NOOP on all other memory files

## AUTO-INDEX

Update `.mema/index.md`:
1. Add or update entry under `## Product Discovery`: `- \`product/challenge.md\` — [N] risks identified; [critical/no critical] concerns`
2. Update `**Updated:**` date
