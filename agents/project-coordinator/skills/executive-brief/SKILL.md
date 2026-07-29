---
name: executive-brief
description: "Use when the Project Manager asks for a steering brief, executive status, sponsor update, or 'how are we doing'. Produces a one-page executive status brief anchored to the business outcome, not story points. Reads Jira and Confluence; drafts for human review; never sends or publishes."
---

# Executive Brief Writer

Produce a one-page executive status brief a sponsor can read in 90 seconds.

## When to use
"Prepare the steering brief", "how are we doing", "status for the sponsor", "exec summary".

## Inputs to read
- **Jira** (project AT): current sprint status, blockers, done vs committed.
- **Confluence** (space Atlas): Charter (for the outcome goal), RAID Log (live risks), latest Steering minutes (prior decisions).

## Procedure
1. Establish the **outcome goal** from the Charter (Atlas: +20% digital loan conversion) and anchor the brief to it.
2. Determine **overall RAG** and justify it in one sentence tied to the critical path — not to velocity.
3. Pull the **top 3 things that matter this week** (usually the red/amber risks and any decision needed).
4. State **delivery progress** briefly: sprint, % toward goal, what closed, what's blocked — with a data-hygiene caveat if velocity is quoted (see Known caveats).
5. End with **what's needed from the committee** (decisions / escalations).

## Output shape
- One line: *Project · Sprint X of Y · RAG · one-sentence why.*
- **This week's headline** — 2–3 bullets, each a synthesis (an implication), not a status.
- **Delivery snapshot** — 2–3 lines.
- **Needs from the committee** — the decisions.
- Footer: *Draft for PM review — [date].*

## Quality bar
Every bullet must pass the "so what?" test. If a line only states a fact without an implication for the outcome, the date, or a decision, rewrite it.

## Known caveats to surface (Project Atlas)
- Sprint 11 closed at ~80% with two items carried into Sprint 12 — velocity reads soft.
- One story was re-pointed after its sprint started (KYC 8→13 after an async pivot) — distorts burndown/velocity baseline.

## Boundaries
Draft only. Do not send, email, or publish. Announce the skill at the top of the output: `▸ Skill: Executive Brief Writer`.
