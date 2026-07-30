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
The archive/Log steps run once the brief is ready. Whether to pause first is **context-aware**:
- **Interactive chat (a human is present):** show the brief, then ASK before archiving to Drive / logging —
  "Archive this to Drive and log it in the Executive Briefs Log?" — and proceed on the OK.
- **Scheduled / unattended run, OR the invoking prompt explicitly authorizes it** (e.g. a Project scheduled
  task worded "prepare and archive the S12 executive brief"): **archive + log directly, no pause** — the
  schedule's wording is the pre-authorization. Then report what was archived (Drive link + new Log snapshot name).
- If you can't tell whether a run is unattended, rely on the prompt wording: explicit "archive/log/publish"
  language authorizes it; its absence means ask.

The steps:
- **Email:** ALWAYS place the sponsor email as a Gmail **draft** (`create_draft` only — never send), with the one-page brief attached — **even on a scheduled run.** Sending to a sponsor is the highest-reach action and stays with the human (and the Gmail connector cannot auto-send regardless). Confirm recipients with the PM where possible; never fabricate addresses.
- **Archive the brief to Drive:** build the one-pager as a real `.docx` in the workspace (Atlas header/footer), then get it onto Drive **via `copy_file`** to a dated name in the **Communication** folder — NOT base64 `create_file` (which hangs). See "Drive upload mechanics" in capabilities.md.
- **Executive Briefs Log:** read the latest dated Log snapshot from Drive, EDIT it in the workspace with the xlsx skill (append one row — Date · Sprint · Overall RAG · one-liner · Recipient(s) · brief link · Top risk — and set col-H RAG-num so the trend chart extends), then `copy_file` to a NEW dated snapshot `Executive-Briefs-Log-{YYYY-MM-DD--HH-MM}.xlsx` in Communication. Every change is a new dated file (no in-place update).

## Boundaries
The **sponsor email is always a Gmail DRAFT — never auto-sent**, in any mode (interactive or scheduled); the connector cannot send autonomously and this skill must not imply it did. Drive archive + Log are direct internal writes: in interactive chat, ask first; on a scheduled/authorized run, proceed and report. Announce the skill at the top of the output: `▸ Skill: Executive Brief Writer`.
