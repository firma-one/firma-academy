---
name: pmc-gmail-stakeholder-update
description: "Use when the Project Manager asks to prepare, draft, or send a stakeholder email via Gmail — e.g. 'draft the sponsor email', 'email the steering update', 'prepare the weekly note in Gmail'. Creates a Gmail DRAFT for the PM to review and send. It never sends email autonomously — draft only, by design."
---

# Gmail Stakeholder Update

Prepare the PM's stakeholder update as a **Gmail draft** for review and sending.

## When to use
"Draft the sponsor email", "email the steering update", "prepare the weekly note in Gmail", "put the stakeholder update in my drafts".

## Prerequisite
The Gmail connector must be connected. Note: the connector supports `create_draft` / `update_draft` only — there is **no autonomous send**. This skill drafts; the PM sends. That boundary is intentional and by design.

## Relationship to the Stakeholder Email skill
The **stakeholder-email** skill *writes the email content* (the executive-tone body). This skill *places that content into Gmail as a draft*. If the content doesn't exist yet, produce it first (via stakeholder-email), then use this skill to draft it in Gmail.

## Procedure
1. Ensure the email content exists (subject + body) — reuse the stakeholder-email skill's output if available, else produce it to the same standard: one-sentence bottom line, "where we are / what needs attention / what's next", the ask and by when, ~200 words, honest about amber.
2. Confirm the recipient(s) with the PM — do not guess sponsor/stakeholder addresses. Use only addresses the PM provides or confirms.
3. Call the Gmail `create_draft` tool with `to`, `subject`, and `body` (or `htmlBody` for rich text).
4. Tell the PM the draft is in their Gmail Drafts folder, ready to review and send. Do not imply it was sent.

## Output shape
Confirm a draft was created, to whom, and the subject line; remind the PM it's in Drafts for them to send. Announce the skill at the top: `▸ Skill: Gmail Stakeholder Update`.

## Boundaries
Draft only — the connector cannot and this skill must not send email autonomously. Never fabricate recipient addresses. This is the human-in-the-loop boundary made concrete: the agent prepares, the PM sends.
