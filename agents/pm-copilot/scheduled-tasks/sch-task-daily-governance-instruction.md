# Scheduled Task — Daily Governance Intelligence

| Field | Value |
|---|---|
| **Skill** | `pmc-governance-intelligence` |
| **Cadence** | Every weekday, 08:00 IST (Asia/Calcutta) |
| **Cron (UTC)** | `30 2 * * 1-5` |
| **Mode** | Unattended / scheduled |
| **Publishes** | Confluence dated page (under "9. Sprint Reports") + Slack #atlas |
| **Edits system-of-record?** | No — read/synthesise only |

## Prompt sent on each firing
Run the PM Copilot governance view for Project Atlas (Digital Lending Platform engagement).

Invoke the `pmc-governance-intelligence` skill. Pull the latest from Jira (AT project) and Confluence (RAID log + steering minutes) and build the single causal governance picture: each active risk → the decision it forces → the actions it spawns, with owner and priority gauged together.

This is a scheduled, unattended run — nobody is watching the session, so do not pause for confirmation. Produce the analysis and publish it to the dated Confluence governance page and post the summary to Slack #atlas, per the skill's standard routing. This skill is read/synthesise only — do NOT edit the RAID log.

If Jira or Confluence cannot be reached, skip publishing, note in one line what failed, and stop.
