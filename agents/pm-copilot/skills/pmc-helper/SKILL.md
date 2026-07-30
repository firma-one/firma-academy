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
1. Print the menu below (verbatim shape; keep the one-line "pulls / publishes" note on each — it
   doubles as a preview so the user sees what a skill will touch before it runs).
2. If the user replies with a number or a skill name, invoke that skill.
3. Do NOT run any analysis or publish anything from this skill — it only shows options and routes.

## The menu
```
PM Copilot — here's what I can prepare for Project Atlas (reply with a number or name):

  1. Fortnightly Dashboard
     The full sprint-review + outcome report (2 layers, one doc).
     Pulls: Jira (project AT) + Confluence (Charter/notes) → computes velocity/chart.
     Publishes: a dated Confluence page for the team + a heads-up in #atlas (Slack).

  2. Executive Brief
     The sponsor-facing update: an email + a one-page supporting brief.
     Pulls: page 3 (Outcome Summary) of the current Fortnightly Dashboard.
     Publishes: archives the brief to the Atlas Shared Drive, logs it in the Executive
     Briefs Log, and places the email in Gmail as a DRAFT for you to review & send.

  3. Governance Intelligence
     Risk + decisions + actions as ONE causal picture (risk → decision it forces → actions).
     Pulls: Jira (AT) + Confluence RAID log + steering minutes.
     Publishes: a dated Confluence page for the team + a heads-up in #atlas (Slack).

Or say "prepare the Steering Committee" and I'll assemble the full pack (1 + 3, then 2).
```

## Boundaries
Announce at the top: `▸ Skill: PM Helper`. This skill never reads systems of record, never drafts,
never publishes. Governance still applies to whatever skill it routes to: Confluence/Drive are
direct internal writes; Gmail/Slack default to drafts (human sends).
