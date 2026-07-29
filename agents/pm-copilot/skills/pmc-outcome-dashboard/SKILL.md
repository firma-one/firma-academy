---
name: pmc-outcome-dashboard
description: "Use when the Project Manager asks for the outcome view, dashboard, 'are we on track for the goal', or a velocity/burn projection. Shows progress against the business outcome (not just throughput) and can COMPUTE and CHART sprint metrics via the bundled script. Requires Code execution & File creation enabled. Reads Jira and Confluence; drafts for human review."
---

# Outcome Dashboard

Show progress against the **business outcome**, not just delivery throughput — the heart of the "delivery → outcome" message. This skill can run code to compute metrics and render a chart, so the numbers are calculated, not estimated.

## When to use
"Outcome view", "dashboard", "are we on track for the goal", "velocity", "burn projection".

## Prerequisite
**Code execution & File creation** must be enabled (Settings → Capabilities). Without it, fall back to a prose outcome view using the procedure below without the chart.

## Inputs to read
- **Confluence** (space Atlas): Charter (the +20% goal and success criteria).
- **Jira** (project AT): sprint membership, story points, status per issue — the data the script consumes.

## Procedure
1. Restate the **outcome metric** and target: +20% digital loan conversion within two quarters of go-live.
2. Map **delivery workstreams to the outcome**: which in-flight work actually moves the metric vs. which is enabling/hygiene.
3. Run `scripts/compute_metrics.py` (see below) to calculate per-sprint committed vs. completed points, velocity, spillover, and a simple completion projection, and to render `outcome_dashboard.png`.
4. Give an honest **confidence read** on hitting the outcome, citing the top 2–3 things that would raise or lower it.
5. Distinguish **"delivered" from "delivering value"** — a feature can be shipped yet not yet moving conversion.
6. Present the **critical path to the outcome**, not a burndown.

## Using the script
The script accepts sprint data as JSON (extract it from Jira first) and writes a chart plus a metrics summary:

```bash
python scripts/compute_metrics.py --input sprints.json --out outcome_dashboard.png
```

`sprints.json` shape (one object per sprint):
```json
[
  {"sprint": "S11", "committed": 25, "completed": 20, "goal_points": 18},
  {"sprint": "S12", "committed": 21, "completed": 21, "goal_points": 15}
]
```
The script prints a JSON summary (velocity, avg velocity, spillover %, projected sprints to burn the remaining outcome-linked scope) and saves the chart. Quote its numbers; do not invent them.

## Output shape
Outcome metric + target at top; a compact "workstream → outcome contribution → confidence" view; the computed metrics + chart; a short "what would change the confidence" note.

## Known caveats to surface
- Sprint 11 spillover (~80% completion) and the mid-sprint re-pointing both affect velocity reliability — state this when quoting the computed velocity.

## Boundaries
Draft only. The chart is an artefact for the PM, not something to publish. Announce the skill at the top: `▸ Skill: Outcome Dashboard`.
