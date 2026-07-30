---
name: pmc-governance-intelligence
description: "Use when the Project Manager asks for the governance view, risk radar, decisions, actions, 'what are the risks', 'what did we decide', 'who owns what', or 'what's threatening go-live'. Produces ONE holistic governance picture that connects risks -> the decisions they force -> the actions they spawn, so priority and ownership are gauged together, not as three separate lists. Reads Jira and Confluence; shows the analysis in chat first, then asks before publishing to Confluence / notifying Slack."
version: 1.0.0
---

# Governance Intelligence

Turn the RAID log, Jira blockers, and steering minutes into ONE causal governance picture —
not three disconnected registers. The value is holistic: a risk forces a decision, a decision
spawns actions with owners and dates. Seeing them together is how a Delivery Director gauges
priority and drives the committee.

## When to use
"Governance view", "risk radar / what are the risks", "what's threatening go-live",
"decisions / what did we decide", "actions / who owns what", "steering prep".

## How to invoke (examples)
**Slash command (power users):** `/pmc-governance-intelligence`

**Natural-language prompts (say any of these):**
- *"What's threatening go-live?"*
- *"What are the risks and what do we need to decide?"*
- *"Who owns what — any overdue or unowned actions?"*
- *"Give me the governance picture for steering prep."*

Renders the analysis in chat first, then asks before publishing (see below).

## Inputs to read
- **Confluence** (space Atlas): RAID Log (risks/issues/dependencies), latest Steering minutes (decisions taken).
- **Jira** (project AT): live blocker tickets behind the risks; comment threads for status.

## Procedure — build the causal chain, don't list
1. **Rank risks** by impact on the outcome / date (not register order). For each top risk:
   *what it is · why it matters now · Jira evidence · the decision it forces · recommended response.*
2. **Decisions** — link each to the risk that forces it. Split **made** (ID, decision, date, owner,
   rationale, affected Jira/RAID) vs **pending** (options, recommended option, and the **cost of not deciding**).
3. **Actions** — link each to the risk/decision/ticket it serves: *action · owner · due · status · source.*
   Flag **overdue** and **unowned** (an unowned action is itself a risk).
4. **Holistic priority view:** present the chains top-reds-first, e.g.
   *R-01 (AT-15 gateway delay) → forces D-1 (approve sandbox stub) → actions: book vendor call (owner, date).*
   Separate live reds (decision needed now) from amber watch items.
5. Note any item with stale data or unconfirmed owner/mitigation.

## Output shape
A ranked set of **risk → decision → action chains** (reds first), then a short amber "watching" list,
then an unowned/overdue callout. Cross-reference Jira keys, RAID IDs, decision IDs (R-/D-/A-).

## Show first, then ask to publish (chat-first — do NOT auto-publish)
Render the full governance picture **in the chat first**. Do NOT write to Confluence or post to Slack
as part of producing the analysis. After presenting it, ASK the PM whether to publish, e.g.
*"Publish this as a dated Confluence page (Governance Intelligence — S<n>) and drop a heads-up in #atlas?"*
Only on an explicit yes:
- **Confluence** (space Atlas, new dated page "Governance Intelligence — S<n>") — direct internal write on approval.
- **#atlas** Slack heads-up (title + one-line message + link) — draft-first (see references/capabilities.md).
The analysis is always chat-first and conversational; the PM can drill in, refine, or act on it before anything is published.

## Atlas anchors
- R-01 / AT-15 — payment-gateway API delay (~3 wks to 8-Aug) → D-1 sandbox stub.
- R-02 / AT-22 — security sign-off unscheduled (go-live gate) → D-2 escalate to sponsor.
- R-03 / AT-18 — returning-customer OTP defect (~8% of logins).
- D-3 — accept AT-16 reconciliation as a Sprint 14 carry-over candidate.

## Boundaries
**Chat-first:** always render the analysis in chat and ASK before publishing — never write to Confluence
or post to Slack as an automatic part of running the skill. On approval, Confluence is a direct internal
write and Slack defaults to a draft. Announce the skill at the top: `▸ Skill: Governance Intelligence (v1.0.0)`.
