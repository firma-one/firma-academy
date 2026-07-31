---
name: pmc-governance-intelligence
description: "Use when the Project Manager asks for the governance view, risk radar, decisions, actions, 'what are the risks', 'what did we decide', 'who owns what', or 'what's threatening go-live'. Produces ONE holistic governance picture that connects risks -> the decisions they force -> the actions they spawn, so priority and ownership are gauged together, not as three separate lists. Reads Jira, Confluence (Charter, meeting notes, sprint reports, RAID Log), Gmail, and Slack, and cites the source behind every claim; shows the analysis in chat first, then asks before publishing to Confluence and sending the PM a direct Slack DM with the page link — the published Confluence page link is shared in chat too, no separate file is produced."
version: 1.1.0
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
- **Confluence** (space Atlas): Charter (outcome goal, scope), RAID Log (risks/issues/dependencies), Meeting
  Notes (sprint/steering minutes — decisions taken), Sprint Reports (Fortnightly Dashboard / prior Governance
  Intelligence pages), Architecture Decision Records.
- **Jira** (project AT): live blocker tickets behind the risks; comment threads for status.
- **Gmail**: threads that surface a decision, risk, or commitment not yet in Confluence/Jira (e.g. a vendor's
  written confirmation, a sponsor's reply setting a date).
- **Slack** (`#atlas` and relevant DMs/threads): messages that record an agreement, escalation, or status not
  yet captured in the system of record.
Email and Slack are **corroborating/lead-hygiene sources** — they surface what hasn't made it into Confluence
or Jira yet (see step 5, "system-of-record gaps"). They do not replace Confluence/Jira as the source of truth
once a decision is formally logged there.

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
5. **System-of-record gaps:** cross-check Email/Slack against Confluence/Jira. If something was agreed or
   escalated in a thread/DM but never logged in the RAID Log, a decision record, or a Jira ticket, surface it
   explicitly as a hygiene finding (e.g. "agreed in Slack on 28-Jul, not yet on the RAID Log or in Jira") —
   don't silently fold it into the analysis as if it were already tracked.
6. Note any item with stale data or an unconfirmed owner/mitigation.

## Cite every claim (LOCKED — no unsourced assertions)
Every factual claim — a risk's status, a decision's date/owner, an action's due date, "X agreed on Y" — MUST
trace to a source. State the source inline, right after the claim, using:
- **Jira:** the ticket key, e.g. `(AT-15)`.
- **Confluence:** the page name + section, e.g. `(RAID Log, R-01)` or `(Steering Minutes, 29-Jul)`.
- **Gmail:** sender + date, e.g. `(email, vendor, 30-Jul)`.
- **Slack:** channel/DM + date, e.g. `(#atlas, 28-Jul)` or `(Slack DM, PM↔Security Lead, 29-Jul)`.
If a claim is the assistant's own inference rather than something a source states outright (e.g. "this is
soft because it's verbal-only"), label it as inference and say what it's inferred from — never present an
inference as if it were a quoted fact. If a claim can't be traced to any source, don't state it as fact —
flag it as unconfirmed instead.

## Output shape
A ranked set of **risk → decision → action chains** (reds first), then a short amber "watching" list,
then an unowned/overdue callout. Cross-reference Jira keys, RAID IDs, decision IDs (R-/D-/A-), and — per
"Cite every claim" above — the Confluence page/Gmail/Slack source behind every date, decision, or status
that didn't come from a Jira key already cited.

## Show first, then ask to publish (chat-first — do NOT auto-publish)
Render the full governance picture **in the chat first**. Do NOT write to Confluence or send any Slack
message as part of producing the analysis. After presenting it, ASK the PM whether to publish, e.g.
*"Publish this as a dated Confluence page (Governance Intelligence — S<n>) and send you a Slack DM with the
link?"* — a "yes" authorizes both steps below. Only on an explicit yes:
- **Confluence** — new dated page "Governance Intelligence — S<n>" nested under **"9. Sprint Reports"**
  (pageId **1802252**) in the Project Atlas — Governance tree: `createConfluencePage(..., parentId: "1802252")`.
  ALWAYS set the parentId (never publish to the space root). If a same-sprint page exists, update it instead
  of duplicating. Page-tree map + IDs: `references/capabilities.md` (publish-to-Confluence). Direct internal write on approval.
  **After publishing, share the page's URL directly in chat** so the PM can open it — no downloadable file
  is produced; the Confluence page IS the shareable artefact.
- **Slack DM to the PM (no channel post):** send the PM a **direct message** — their own Slack `user_id` as
  the channel — with `slack_send_message` (sent immediately, not `slack_send_message_draft`; this is a
  self-notification to the PM, so it goes direct, not draft-first). The DM must include: the skill name,
  the sprint number, a one-line RAG headline, and the published Confluence page URL as a clickable link.
  E.g. *"📋 Governance Intelligence — Sprint 12. RAG: AMBER. <link|View the published page>."* **Never post to
  `#atlas` or any other channel** — the only Slack action this skill takes is this DM.
The analysis is always chat-first and conversational; the PM can drill in, refine, or act on it before anything is published. Both the Confluence write and the Slack DM fire only on the PM's explicit approval — never on run.

## Atlas anchors
- R-01 / AT-15 — payment-gateway API delay (~3 wks to 8-Aug) → D-1 sandbox stub.
- R-02 / AT-22 — security sign-off unscheduled (go-live gate) → D-2 escalate to sponsor.
- R-03 / AT-18 — returning-customer OTP defect (~8% of logins).
- D-3 — accept AT-16 reconciliation as a Sprint 14 carry-over candidate.

## Boundaries
**Chat-first:** always render the analysis in chat and ASK before publishing — never write to Confluence
or send a Slack message as an automatic part of running the skill. On approval, Confluence is a direct
internal write (share the resulting page link in chat) and the Slack step is a **direct DM to the PM only**
— never a post to `#atlas` or any other channel. Announce the skill at the top:
`▸ Skill: Governance Intelligence (v1.1.0)`.
