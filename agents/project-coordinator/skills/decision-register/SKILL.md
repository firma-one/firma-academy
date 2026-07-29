---
name: decision-register
description: "Use when the Project Manager asks to log decisions, 'what did we decide', or for the decision register. Captures decisions made and decisions pending, each pending item with options, a recommendation, and the cost of not deciding. Reads Confluence and Jira; drafts for human review."
---

# Decision Register

Capture and maintain the log of decisions the governance forum has made or must make.

## When to use
"Log the decisions", "what did we decide", "decision register", "decisions for steering".

## Inputs to read
- **Confluence** (space Atlas): latest Steering minutes (Meeting Notes) for decisions already taken.
- **Jira** (project AT) + RAID: decisions implied by current live risks.

## Procedure
1. List **decisions made**: ID, decision, date, owner, rationale, and the Jira/RAID item it affects.
2. List **decisions pending** — the calls the committee must make now — each with the options and a **recommended option**.
3. For each pending decision, make the **cost of not deciding** explicit (this is what drives executives to decide).

## Output shape
Two short tables — *Decisions made* and *Decisions needed* — with a recommended option on each pending item.

## Atlas anchors
- D-1 — sandbox stub for the payment gateway (unblock dependent work).
- D-2 — escalate the security-sign-off booking to the sponsor.
- D-3 — accept disbursement reconciliation (AT-16) as a Sprint 14 carry-over candidate.

## Boundaries
Draft only. Announce the skill at the top: `▸ Skill: Decision Register`.
