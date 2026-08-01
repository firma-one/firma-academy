# Scheduled Task — Fortnightly Sprint Dashboard

| Field | Value |
|---|---|
| **Skill** | `pmc-fortnightly-dashboard` |
| **Cadence** | Sprint-end Mondays, 09:00 IST (Asia/Calcutta) |
| **Cron (UTC)** | `30 3 * * 1` (fires every Monday — see note) |
| **Mode** | Unattended / scheduled |
| **Publishes** | Confluence dated page (under "9. Sprint Reports") + Slack #atlas |
| **Edits system-of-record?** | No |

> **Fortnightly note:** cron has no native "every other week". Options: (a) keep the weekly cron above and let the run resolve the active Jira sprint — on an off-week it reports the in-flight sprint, which is usually fine; or (b) enable/disable the task on sprint-boundary Mondays; or (c) trigger it from the sprint-close event instead of the clock.

## Prompt sent on each firing
Generate the PM Copilot fortnightly dashboard for Project Atlas (Digital Lending Platform engagement).

Invoke the `pmc-fortnightly-dashboard` skill. Resolve the current/just-closed Jira sprint in the AT project, compute sprint metrics from LIVE Jira only (no demo/sample data) via the bundled script, and build the two-layer report: Layer 1 Sprint Review (pp.1-2) and Layer 2 Outcome-Based Summary (p.3) anchored to the +20% conversion outcome.

This is a scheduled, unattended run — do not pause for confirmation. Publish the dashboard to the dated Confluence page under "9. Sprint Reports" and post the summary to Slack #atlas.

If the sprint cannot be resolved or Jira/Confluence is unreachable, skip publishing, note in one line what failed, and stop.
