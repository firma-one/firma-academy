---
name: pmc-executive-brief
description: "Use when the Project Manager asks for a steering brief, executive status, sponsor update, or 'how are we doing'. Produces a one-page executive status brief anchored to the business outcome, not story points. Reads Jira and Confluence; drafts for human review; never sends or publishes."
---

# Executive Brief Writer

Produce a one-page executive status brief a sponsor can read in 90 seconds.

## When to use
"Prepare the steering brief", "how are we doing", "status for the sponsor", "exec summary".

## How to invoke (examples)
**Slash command (power users):**
- `/pmc-executive-brief` — brief for the **current/latest** sprint (infer from Jira / the latest Fortnightly Dashboard).
- `/pmc-executive-brief Sprint 12` — brief for a **specific** sprint (`Sprint {n}`; also accepts `S12`).

**Natural-language prompts (say any of these):**
- *"Draft the sponsor update for S12."*
- *"Prepare the steering brief for the committee."*
- *"How do I tell leadership where we are?"*
- *"Give me an exec summary of this sprint."*

If no sprint is given, default to the latest sprint and state which sprint you used.

## Resolve the sprint first (before any Jira pull)
The user's shorthand (`S12`, `Sprint 12`, `12`) is NOT a Jira sprint name/ID. Before pulling data, resolve
it to the real Jira sprint for project **AT**: map the shorthand to the sprint **number**, look up the
matching Jira sprint (name + numeric ID), and query with `sprint = <resolvedSprintId>` — never
`sprint = "S12"` (that errors). If it's ambiguous or not found, ASK the PM which sprint they mean, and state
the resolved sprint ("Brief for **AT Sprint 12**") before pulling stats.

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
The email body (HTML — see Publish & archive) opens with, as the FIRST line above the greeting:
- **Report date: DD Month YYYY** — the date of the run, in the PM's local timezone (Asia/Calcutta).

Then:
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

## Publish & archive (internal capabilities — see references/capabilities.md)
The archive/Log/notify steps run automatically once the brief is ready — **no confirmation, ever, in any
mode** (interactive or scheduled). This is unconditional: do not pause, do not ask "should I proceed?" or
"archive this?", and do not stop partway to check in — not even if a prior turn in this conversation asked
first, not even if you're unsure. Complete the Gmail draft, Drive archive, Log update, and Slack notification
back-to-back as one uninterrupted run, and only stop once every step is done. Then report what was done
(Drive link, new Log snapshot name, and confirmation the Slack DM was sent).

The steps:
- **Email — HTML draft, brief auto-attached:** place the sponsor email as a Gmail **draft**
  (`create_draft` / `update_draft`, never send — the connector can't auto-send regardless), **even on a
  scheduled run.** Send it as an **executive HTML email** (navy `#1F3864` header band with project name +
  "Sprint X of Y (closed)"; the *Report date: DD Month YYYY* line; a RAG callout coloured by status;
  uppercase section dividers; clean bullet rows; `Restricted — Internal Use Only · © Atlas` footer), and
  ALWAYS set the plain-text `body` as a fallback. **Subject leads with the project name and drops the sprint
  number**, e.g. `Atlas - Executive Brief: Go-live status & steering asks`.
  **The assistant attaches the one-page brief `.docx` itself** via the tool's `attachments` param, so the
  draft is delivered ready-to-send — NEVER write a note telling the PM to attach it before sending. Recipient
  defaults to the PM's own address unless the PM names one; never fabricate addresses. (Attachment bytes go
  via base64 from a `.b64` file on disk, delegated to a subagent + verified — see "Drive upload mechanics" in
  capabilities.md; never hand-transcribe base64.)
- **Archive the brief to Drive:** produce the one-page brief `.docx` in the workspace (start from
  `fortnightly-dashboard-template.docx`, id `1y9hl9AKorePd8JO2MEmbMFxJ_xy0mdwR`, in Templates — it carries the
  `Atlas - [project_name]` header/footer + placeholders — read it, edit the placeholders with the docx skill),
  then upload to the **Communication** folder (`10Ow77XB3SVlHGoGnGqr8QLLzSOMKEUDc`) via `create_file` (base64
  from a `.b64` file on disk, delegated + verified). Dated name (LOCKED — no sprint number; ISO-8601 local
  time, offset in round brackets): `Atlas-Exec-Brief-{YYYY-MM-DDThh-mm-ss(±ZZZZ)}.docx`, e.g.
  `Atlas-Exec-Brief-2026-07-31T13-08-43(+0530).docx`. `copy_file` is the byte-perfect re-date mechanism
  only for an unchanged file. See "Drive upload mechanics" in capabilities.md.
- **Executive Briefs Log:** read the latest dated Log snapshot from Drive, EDIT it in the workspace with the
  xlsx skill (append one row — Date · Sprint · Overall RAG · one-liner · Recipient(s) · brief link · Top risk —
  and set col-H RAG-num so the trend chart extends), then upload a NEW dated snapshot
  `Executive-Briefs-Log-{YYYY-MM-DDThh-mm-ss(±ZZZZ)}.xlsx` (PM's local tz, round-bracket offset) to
  Communication via `create_file` (base64 from disk, delegated + verified). Every change is a new dated file
  (no in-place update).
- **Notify the PM on Slack (1:1 DM):** once the draft is prepared, send a short **direct message to the PM**
  (their own Slack `user_id` as the channel) confirming the brief is drafted **and attached**, with the RAG
  headline and the committee asks. Send it directly with `slack_send_message` — no confirmation, no draft —
  so the PM actually gets notified the moment the brief is ready. The note MUST NOT tell the PM to attach the
  file — it is already attached. E.g. *"📋 Atlas — Sprint 12 Executive Brief drafted in your Gmail (brief
  attached). RAG: AMBER. Asks: confirm gateway date, book security slot."*

## Boundaries
The **sponsor email is always a Gmail DRAFT — never auto-sent**, in any mode (interactive or scheduled); the connector cannot send autonomously and this skill must not imply it did. Drive archive, the Log, and the Slack notification are direct internal writes/actions and run automatically in every mode (interactive or scheduled) — never ask for confirmation before doing them. Announce the skill at the top of the output: `▸ Skill: Executive Brief Writer`.
