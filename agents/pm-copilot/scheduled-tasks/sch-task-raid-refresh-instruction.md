# Scheduled Task — RAID Refresh from Minutes (propose-only)

| Field | Value |
|---|---|
| **Skill** | `pmc-raid-maintainer` |
| **Cadence** | Weekly, Thursday 17:00 IST (Asia/Calcutta), after steering |
| **Cron (UTC)** | `30 11 * * 4` |
| **Mode** | Unattended, but PROPOSE-ONLY |
| **Publishes** | RAID diff staged for PM approval + Slack DM to the PM |
| **Edits system-of-record?** | Prepares the edit — does NOT apply it |

> **Why propose-only:** the RAID log is a system-of-record page. Even on a schedule this skill must never auto-edit it. The scheduled run does the heavy extraction ahead of time so the PM only has to approve.

## Prompt sent on each firing
Prepare a RAID refresh for Project Atlas (Digital Lending Platform engagement).

Invoke the `pmc-raid-maintainer` skill. Scan for NEW Confluence meeting minutes / transcripts posted since the last RAID update, extract new or changed Risks, Assumptions, Issues, Dependencies, decisions taken and actions, and build the RAID diff (Add / Update / Close, each traceable to a specific minute).

This is a scheduled run, but do NOT edit the RAID page. Stage the proposed diff and DM the PM on Slack that a RAID diff is ready for review and approval. The RAID Confluence page is only updated after the PM explicitly approves in a follow-up.

If there are no new minutes since the last run, do nothing and note "no new minutes — RAID unchanged".
