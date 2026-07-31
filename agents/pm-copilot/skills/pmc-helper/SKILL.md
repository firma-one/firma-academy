---
name: pmc-helper
description: "Use when the Project Manager asks what you can do, types 'help', 'menu', 'options', 'what can you do', 'get started', or invokes /pmc-helper. The front door to PM Copilot: renders the capability menu for Project Atlas, explains what each skill pulls and where it publishes, and routes the user to the skill they pick (by name or number). Takes no arguments."
version: 1.0.0
---

# PM Helper (front door)

Render PM Copilot's capabilities as a menu and route the user to the right skill. Invoked by
`/pmc-helper`, or by "what can you do / help / menu / options / get started". Takes NO arguments —
if the user typed something after the command, treat it as a normal request, not a flag.

## What to do
1. Render the menu below EXACTLY as structured: each of the four skills in its OWN blockquote (`>` on every line)
   so it shows as a boxed card, with the **Sources / Output / You control** preview lines and the **▶ How to run**
   block inside each card. In "▶ How to run", style BOTH the slash command AND each sample natural-language
   prompt as inline `code` (pills) so they look consistent and copyable. Keep the intro and footer lines OUTSIDE
   the blockquotes. Do NOT merge skills into one blockquote and do NOT use a single code block.
2. If the user replies with a number, a skill name, a `/command`, or one of the sample prompts, invoke that skill.
3. Do NOT run any analysis or publish anything from this skill — it only shows options and routes.

## The menu (render EXACTLY with this structure — each skill in its OWN blockquote so it renders as a boxed card)
Render each of the four skills as a **separate blockquote** (every line prefixed with `>`), so the chat draws a
bordered/shaded panel around each one — a card per skill. Keep an intro line and a footer line OUTSIDE the
blockquotes. Do NOT merge skills into one blockquote and do NOT use a single code block.

**PM Copilot — what I can prepare for Project Atlas.** Pick a number or name, type a `/command`, or just say what you need in your own words.

> ### 1 · Fortnightly Dashboard
> The full sprint-review + outcome report — two layers, one doc.
>
> **Sources:** Jira (project AT) + Confluence (Charter/notes); computes velocity + chart from live Jira.
> **Output:** the report in chat.  **You control:** publishing to a dated Confluence page + a #atlas heads-up.
>
> **▶ How to run**
> `/pmc-fortnightly-dashboard` (latest sprint) · `/pmc-fortnightly-dashboard Sprint 12` (specific sprint; `S12` works too)
> *Or say:* `Prepare the fortnightly dashboard for S12` · `Are we on track for the goal?` · `Show me velocity and the outcome view`

> ### 2 · Executive Brief
> The sponsor-facing update — a short email + a one-page supporting brief.
>
> **Sources:** page 3 (Outcome Summary) of the current Fortnightly Dashboard.
> **Output:** the brief in chat.  **You control:** archiving to Drive + the Executive Briefs Log; the Gmail email is a **DRAFT** for you to review & send (never sent for you).
>
> **▶ How to run**
> `/pmc-executive-brief` (latest sprint) · `/pmc-executive-brief Sprint 12` (specific sprint; `S12` works too)
> *Or say:* `Draft the sponsor update for S12` · `Prepare the steering brief for the committee` · `How do I tell leadership where we are?`

> ### 3 · Governance Intelligence
> Risk + decisions + actions as ONE causal picture: risk → the decision it forces → the actions it spawns.
>
> **Sources:** Jira (AT) + Confluence RAID log + steering minutes.
> **Output:** the full governance picture **in chat first** — reds-first, with overdue/unowned flags.  **You control:** I ask before publishing — only on your OK does it go to a dated Confluence page + a Slack DM to you with the link (no channel post).
>
> **▶ How to run**
> `/pmc-governance-intelligence`
> *Or say:* `What's threatening go-live?` · `What are the risks and what do we need to decide?` · `Who owns what — anything overdue or unowned?`

> ### 4 · RAID Maintainer
> Keeps the RAID log current from the latest meeting minutes, so Governance Intelligence reads a living source.
>
> **Sources:** new Confluence Minutes/transcripts + the current RAID log + Jira (AT) cross-refs.
> **Output:** a proposed RAID diff (Add / Update / Close) in chat, each line traceable to a minute.  **You control:** nothing changes on the RAID page until you approve the diff — on approval, a Version History row (Date / Source minute / Summary) is logged at the top of the page.
>
> **▶ How to run**
> `/pmc-raid-maintainer`
> *Or say:* `Process the latest steering minutes into the RAID log` · `Refresh RAID from Tuesday's sprint review` · `Update the RAID log`

---

*Reply with a number, a name, a `/command`, or one of the sample prompts above.*

## Boundaries
Announce at the top: `▸ Skill: PM Helper`. This skill never reads systems of record, never drafts,
never publishes. Governance still applies to whatever skill it routes to: Confluence/Drive are
direct internal writes; Gmail/Slack default to drafts (human sends).
