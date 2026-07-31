---
name: pmc-raid-maintainer
description: "Use when the Project Manager asks to update the RAID log, 'process the latest minutes', 'refresh RAID from the meeting', or after new Steering/sprint Minutes are posted to Confluence. Reads new meeting minutes/transcripts, extracts new or changed Risks, Assumptions, Issues, Dependencies, decisions taken, and actions, then PROPOSES a RAID diff for the PM to approve before updating the RAID page in Confluence. Maintains a Version History table (Date / Source minute / Summary) at the top of the RAID page, appending one row per approved update. This is the heaviest governance action in the plugin — it edits a system-of-record page — so it is strictly propose-then-approve. Reads Jira and Confluence; never edits RAID without explicit approval."
version: 1.1.0
---

# RAID Maintainer

Keep the **RAID log current** so that `pmc-governance-intelligence` always reads a living source, not
a page that rotted after the last meeting. This skill turns freshly-posted meeting minutes into
proposed RAID updates — and only writes them to Confluence once the PM approves.

Why this exists: governance intelligence is only as good as its RAID log. A static RAID page is stale
within a sprint. This skill closes that gap by making RAID a maintained artefact, driven by minutes.

## When to use
"Update RAID", "process the latest minutes", "refresh RAID from the meeting", "the steering minutes are up",
or automatically as the first step before governance-intelligence if the RAID page is older than the latest minutes.

## How to invoke (examples)
**Slash command (power users):** `/pmc-raid-maintainer`

**Natural-language prompts (say any of these):**
- *"Process the latest steering minutes into the RAID log."*
- *"Refresh RAID from Tuesday's sprint review."*
- *"Update the RAID log — the minutes are up."*
- *"What's new in RAID since the last meeting?"*

Always PROPOSES a diff for your approval first — nothing is written to the RAID page until you say yes.

## Inputs to read
- **Confluence** (space Atlas): the NEW **Meeting Notes** page(s) under "4. Meeting Notes" (pageId 589826) and
  any embedded **transcript** snippets since RAID was last updated; and the current **RAID Log** page (557057)
  to diff against.
- **Jira** (project AT): to confirm/cross-reference tickets a minute refers to (e.g. a blocker AT-15).

**Meeting Notes convention:** child pages under "4. Meeting Notes" are titled `YYYY-MM-DD · <Meeting Name>`
(date-prefixed, so they sort chronologically — NOT numbered 4.x). Sprint reviews/retrospectives are NOT kept
as meeting-note pages — their substance lives in the Sprint Reports (Fortnightly Dashboard under "9. Sprint
Reports"). So read the dated Meeting Notes (Steering, PO↔Architect, Architect↔Engineers, Governance/Risk Review)
for RAID inputs; don't expect a separate "sprint review" meeting page. If this skill ever creates a meeting-note
page, title it `YYYY-MM-DD · <Meeting Name>` and nest it under 589826.

## Procedure — propose, then (on approval) write
1. **Identify what's new:** compare the latest Minutes page(s) against the RAID Log's last-updated marker.
   Only process minutes newer than the current RAID state; don't re-ingest old ones.
2. **Extract RAID-relevant items** from the minutes/transcript:
   - new or changed **Risks** (with impact/likelihood if stated), **Assumptions**, **Issues**, **Dependencies**;
   - **Decisions taken** (mark the matching pending decision as resolved, with date/owner);
   - **Actions** (new actions with owner + due; existing actions to close or reassign).
3. **Produce a DIFF, not a silent edit** — present it as: *Add · Update · Close/Resolve*, each line citing
   the source minute (page + date) and the affected RAID ID / Jira key. Flag anything ambiguous rather than guessing.
4. **Get explicit approval.** Do NOT modify the RAID page until the PM approves the diff. The PM may edit the diff first.
5. **On approval, update the RAID Log page** in Confluence (`updateConfluencePage`, space Atlas) with the approved
   changes, and append one new row to the **Version History table** (see below).

## Version History table (LOCKED format, top of page)
The RAID Log page carries a **Version History** table as its first section, above the RAID register itself.
Columns: **Date · Source minute · Summary of changes.**
- **Date** — the date of this update (the run date, not the minute's date).
- **Source minute** — the Meeting Notes page this update was derived from (title + link), e.g.
  `2026-07-29 · Steering`.
- **Summary of changes** — one line, plain language: what was added/updated/closed, e.g.
  *"Added R-04 (KMS provisioning dependency); closed A-07 (vendor call, done); updated D-2 to resolved."*
  Summarize the diff, don't paste it verbatim — this is a scannable log, not a duplicate of the diff.
Rows are **appended at the bottom** (oldest first, newest last) — do not reorder or delete prior rows. If the
table doesn't exist yet on the RAID page (first-ever run of this skill against it), create it as the new
first section, with a header row, before making any other edit.

## Output shape
Announce the skill at the top: `▸ Skill: RAID Maintainer (v1.1.0)`. Present the proposed diff grouped
Add / Update / Close, each traceable to a minute and a RAID/Jira ID, then ask for approval. After approval,
confirm the RAID page was updated (with a link) and state the Version History summary line that was added —
do not print internal IDs.

## Boundaries
Editing the RAID system-of-record is a governed write: **propose-then-approve is mandatory** — never
edit RAID autonomously, never invent items not supported by the minutes, never resolve a decision or close
an action the minutes don't actually record. When unsure, leave it in the diff as a flagged question for the PM.
