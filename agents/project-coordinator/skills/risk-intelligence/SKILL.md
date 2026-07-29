---
name: risk-intelligence
description: "Use when the Project Manager asks for the risk radar, 'what are the risks', or 'what's threatening go-live'. Turns the RAID log and Jira blockers into a ranked, causal, decision-oriented risk picture — not a list. Reads Jira and Confluence; drafts for human review."
---

# Risk Intelligence (Risk Radar)

Turn the RAID log and Jira blockers into a prioritised, decision-oriented risk picture.

## When to use
"What are the risks", "risk radar", "what's threatening go-live", "risk review".

## Inputs to read
- **Confluence** (space Atlas): RAID Log — risks, issues, dependencies.
- **Jira** (project AT): the live blocker tickets behind the risks; comment threads for current status.

## Procedure
1. Rank risks by **impact on the outcome / date**, not by register order.
2. For each top risk give: *what it is · why it matters now · the Jira evidence · the decision it forces · recommended response.*
3. Connect **related risks** into a causal chain — e.g. vendor delay → disbursement slips → reconciliation moves to S14 → finance-ops readiness at risk.
4. Separate **live red risks** (need a decision now) from **watch items** (amber, being managed).
5. Note any risk whose data is stale or whose owner/mitigation is unconfirmed.

## Output shape
A short ranked list (top reds first), each with the five elements above, then a one-line "watching" list. Cross-reference Jira keys and RAID IDs.

## Atlas anchors
- R-01 / AT-15 — payment-gateway API delay (~3 wks to 8-Aug).
- R-02 / AT-22 — external security sign-off unscheduled (hard go-live gate).
- R-03 / AT-18 — returning-customer OTP defect (~8% of logins).

## Boundaries
Draft only. Announce the skill at the top: `▸ Skill: Risk Intelligence`.
