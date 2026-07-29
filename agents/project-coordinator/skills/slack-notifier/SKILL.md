---
name: slack-notifier
description: "Use when the Project Manager asks to post, notify, or share an update on Slack — e.g. 'post the steering summary to #atlas', 'notify the channel', 'drop a Slack update'. Posts a concise update to a Slack channel. Defaults to drafting for review; sends directly only on explicit instruction. This is a WRITE skill that reaches stakeholders, so human approval is the default."
---

# Slack Notifier

Share a concise project update to a Slack channel — as a reviewable draft by default.

## When to use
"Post the steering summary to #atlas", "notify the channel", "drop a Slack update", "let the team know on Slack".

## Prerequisite
The Slack connector must be connected with write access.

## Default channel
`#atlas` (private channel, ID `C0BLQHPR90U`). If the PM names a different channel, resolve it with `slack_search_channels` and confirm the match before posting.

## Governance — draft first, send on instruction
Slack posts reach stakeholders, so the **default is to create a draft for the PM to review and send**, not to post directly.
- **Default (`slack_send_message_draft`):** stage the message as a Slack draft in the channel; the PM reviews and hits send.
- **Direct (`slack_send_message`):** only when the PM explicitly says "post it", "send it now", or similar. Never post directly on an ambiguous instruction.

If unsure which the PM wants, draft and say so — err toward review.

## Procedure
1. Compose a **concise** update (Slack is not the place for the full pack): RAG status, the 1–2 things that matter this week, and any decision/ask. Link to the full artefact (e.g. the Drive report `viewUrl`) rather than pasting it.
2. Resolve the target channel ID (default `#atlas` / `C0BLQHPR90U`).
3. **Draft by default:** call `slack_send_message_draft` with the channel ID and message. Tell the PM a draft is staged for their review.
4. **Direct only on explicit instruction:** if the PM clearly asked to post now, call `slack_send_message` and return the message link.
5. Use Slack markdown (bold, bullets, links). Keep it scannable.

## Output shape
State whether a draft was staged or a message posted, to which channel, and (if posted) the message link. Announce the skill at the top: `▸ Skill: Slack Notifier`.

## Boundaries
Never post to a channel the PM didn't name or confirm. Never post the full governance pack — post a summary + link. Reaching stakeholders defaults to review.
