---
name: pmc-fortnightly-dashboard
description: "Use when the Project Manager asks for the fortnightly dashboard, the sprint review + outcome report, 'are we on track for the goal', velocity/burn, or the comprehensive fortnightly report. Produces the two-layer Fortnightly Dashboard: a traditional Sprint Review (pages 1-2) plus an Outcome-Based Summary (page 3) anchored to the business outcome, not story points. Can COMPUTE and CHART sprint metrics via the bundled script. Reads Jira and Confluence; drafts for human review."
version: 2.0.0
---

# Fortnightly Dashboard

The comprehensive fortnightly report for Project Atlas (Digital Lending Platform). ONE document, two layers, two audiences:
- **Pages 1-2 — Sprint Review** (the delivery team's working view): sprint goal, sprint-at-a-glance metrics, completed & demonstrated, carryover, stakeholder feedback, blockers, actions.
- **Page 3 — Outcome-Based Summary** (the leadership view, on its own page): outcome statement, KPI movement (baseline/now/target), value delivered in outcome terms, what we learned, trajectory & forecast, executive one-liner.

**Audience model (Option B):** the FULL dashboard goes to the whole project team — keeping everyone on the big picture is the point. Executives receive only page 3, lifted into a standalone one-pager by `pmc-executive-brief`. Same data, two views, no divergence.

## Content structure (from the Sprint Review template — cover every section)
Follow this exact coverage; it is the approved reporting structure. Fill every section from LIVE
Jira/Confluence data — no placeholders left in the output.

**Layer 1 — Sprint Review (pages 1-2, the team's working view):**
- **Header:** Team/squad · Sprint # · Dates · Facilitator · Product Owner · Attendees.
- **1. Sprint Goal:** the ONE outcome this sprint was meant to move (not a ticket list) + Goal met? (Fully / Partially / Not met).
- **2. Sprint at a Glance** (numbers table, this-sprint vs last-sprint + trend ▲/▼/→): Committed, Completed, Completion rate, Carried over, Added mid-sprint (scope change), Velocity, Defects found/resolved. Embed the computed chart here.
- **3. Completed & Demonstrated:** table of Item/Story · Value delivered (user or business) · Owner. Only items meeting DoD; frame each by USER VALUE, not the ticket.
- **4. Not Completed — Carryover:** Item · Status · Reason not done (blocker/underestimate/scope) · Plan (carry/drop/split). Be honest about what didn't land and why.
- **5. Stakeholder Feedback:** each reaction → a backlog DECISION (add / clarify / decline), never a vague promise.
- **6. Blockers, Risks & Dependencies:** Issue · Impact (what it threatens) · Owner · Due.
- **7. Action Items:** # · Action · Owner · Due.

**Layer 2 — Outcome-Based Summary (page 3, its own page, the leadership view):**
- **Outcome we are driving toward:** the measurable business/user outcome this work exists to achieve (+20% digital loan conversion).
- **Metric movement:** KPI table — KPI · Baseline · Now · Target · On track? (● on / ◐ at-risk / ○ off). Track outcome KPIs, NOT story points.
- **Value delivered this sprint:** each shipped item → how it moves the outcome. If a completed item moved nothing, SAY SO — that is a signal.
- **What we learned:** Validated / Invalidated-or-surprised / Decision (what we'll do differently).
- **Trajectory & forecast:** Confidence in hitting the outcome (High/Med/Low + why) · Projected completion (on/ahead/behind, by how much) · Biggest lever next sprint.
- **Executive one-liner:** one sentence = progress + outcome + confidence, in plain language. (This is exactly what `pmc-executive-brief` lifts.)

## When to use
"Fortnightly dashboard", "sprint review", "outcome view", "are we on track for the goal", "velocity", "burn projection", "the fortnightly report".

## How to invoke (examples)
**Slash command (power users):**
- `/pmc-fortnightly-dashboard` — build for the **current/latest** sprint (infer the active sprint from Jira).
- `/pmc-fortnightly-dashboard Sprint 12` — build for a **specific** sprint (`Sprint {n}`; also accepts `S12`).

**Natural-language prompts (say any of these):**
- *"Prepare the fortnightly dashboard for S12."*
- *"Are we on track for the goal?"*
- *"Show me velocity and the outcome view for sprint 12."*
- *"How did this sprint go against the +20% conversion target?"*

If no sprint is given, default to the latest sprint and state which sprint you used.

## Prerequisite
**Code execution & File creation** must be enabled (Settings -> Capabilities) for the metrics chart. Without it, fall back to a prose outcome view (no chart).

## Inputs to read
- **Confluence** (space Atlas): Charter (the +20% digital-loan-conversion goal + success criteria), latest sprint-review/retro notes.
- **Jira** (project AT): sprint membership, story points, status per issue, blockers, defects — the data the script consumes and the sprint-review tables need.

## Step 0 — RESOLVE THE SPRINT FIRST (before any data pull)
The user's shorthand (`S11`, `Sprint 11`, `sprint 11`, `11`) is NOT a Jira sprint name or ID. Jira sprints
have their own names (e.g. "AT Sprint 11", "Atlas Sprint 11") and numeric sprint IDs. **Never put the
shorthand straight into a JQL `sprint = "S11"` filter — it will error** (this is the failure to avoid).

Resolve it first:
1. Interpret the shorthand → the sprint **number** (S11 / Sprint 11 / 11 → 11). If none was given, use the latest/active sprint.
2. Look up the real Jira sprint for project **AT** with that number — e.g. board sprints via the Atlassian
   connector, or JQL `project = AT AND sprint = <sprintId>` once you have the ID. Match the number to the
   actual sprint **name** and **numeric ID**.
3. If more than one sprint matches (e.g. a renamed/duplicated sprint) or none does, ASK the PM which sprint
   they mean rather than guessing. State the resolved sprint ("Building the dashboard for **AT Sprint 11**
   (id 42)") so the PM can confirm before you pull stats.

Only after the sprint is resolved to a real Jira sprint (name + ID) do you pull any data or run metrics.

## Procedure
1. Restate the **outcome metric** and target: +20% digital loan conversion within two quarters of go-live.
2. Assemble the **Sprint Review** layer from Jira: goal, committed/completed/velocity/carryover/defects, the done-and-demoed stories (framed by user value), carryover with reasons, blockers, actions.
3. Run `scripts/compute_metrics.py` to calculate per-sprint committed vs completed, velocity, spillover, and a completion projection, and to render `outcome_dashboard.png` (embed it in "Sprint at a Glance").
4. Assemble the **Outcome-Based Summary** layer: KPI movement (baseline/now/target), value-delivered-in-outcome-terms (call out anything shipped that moved nothing — that is a signal), what we learned, trajectory/confidence, and the executive one-liner.
5. **Produce the artefact from the template**, not from scratch. The structural source is `fortnightly-dashboard.template.docx` in the Atlas Shared Drive **Templates** folder (`1VAXBdsZKsHynwWkXFJcnNDRH09TM0XT9`) — the two-layer Sprint Review + Outcome Summary blank form (its sections/tables are enumerated in 'Content structure' above). Fill it with the live data, then render the result as the team's **Confluence** page (primary system of record). An optional archived copy may be placed on Drive per `references/capabilities.md` — edit the template copy in the workspace, then `copy_file` to a dated file (never base64 `create_file`).

## Metrics — LIVE Jira only (no sample data)
`scripts/compute_metrics.py` is a PURE CALCULATOR — it does NOT connect to Jira and
has NO built-in sample data (a no-argument run errors on purpose). YOU pull the live
data and feed it in. Do this as three ordered, non-skippable steps:

1. **Query Jira live** via the Atlassian connector for the sprint(s) in scope — using the **resolved sprint
   ID from Step 0**, not the user's shorthand. E.g. `searchJiraIssuesUsingJql` on
   `project = AT AND sprint = <resolvedSprintId>` (and `getJiraIssue` for detail). Take real committed /
   completed story points and the outcome-linked subset per sprint. Never invent, estimate, or reuse numbers
   from a previous run.
2. **Write** the returned points to `sprints.json`:
   ```json
   [{"sprint":"S11","committed":25,"completed":20,"goal_points":18}, ...]
   ```
   (`goal_points` = the subset of completed points that move the +20% outcome.)
3. **Run** the calculator on that file:
   ```bash
   python scripts/compute_metrics.py --input sprints.json --out outcome_dashboard.png \
       --remaining-goal-scope <points still to deliver to go-live>
   ```

If the Jira connector is unavailable, say so and STOP — do not fabricate a dashboard
from placeholder numbers. Quote the script's computed values verbatim; do not invent them.

## Known caveats to surface
- Sprint 11 spillover (~80% completion) and the mid-sprint KYC re-pointing (8->13) both distort velocity — state this when quoting velocity.

## Publish (internal capabilities — see references/capabilities.md)
Publish the Fortnightly Dashboard to **Confluence** (space Atlas, new dated page
"Fortnightly Dashboard — S<n>") for the whole team, and **notify #atlas** on Slack with a
one-line message + the page link. The team gets the FULL dashboard (Option B — big-picture
for everyone); the executive view is produced separately by `pmc-executive-brief`, which lifts
page 3.

### Where it goes in Confluence (NEVER the space root)
Publish under **Project Atlas › 9. Reports › "Sprint Reports"** (pageId **1802252**) —
`createConfluencePage(..., parentId: "1802252")`. ALWAYS set the parentId; a page created without one lands
orphaned at the space root. Title: "Fortnightly Dashboard — S<n>". If a page for the same sprint already
exists, update it instead of creating a duplicate. See `references/capabilities.md` (publish-to-Confluence)
for the full page-tree map and IDs.

### When to publish — context-aware (interactive = ask; scheduled = auto)
- **Interactive chat (a human is present):** render the dashboard, then ASK before publishing —
  "Publish to Confluence under 9. Reports › Sprint Reports (Fortnightly Dashboard — S<n>) and drop a #atlas heads-up?" — publish only on the OK.
- **Scheduled / unattended run, OR the invoking prompt explicitly authorizes it** (e.g. a Project scheduled
  task worded "post the fortnightly dashboard to Confluence" / "publish without waiting for confirmation"):
  **publish directly, no pause** — the schedule's wording is the pre-authorization. Then report exactly what
  was published (page link + whether the #atlas heads-up was posted).
- Confluence is a direct internal write. Slack still defaults to a **draft** unless the prompt says to post it;
  a scheduled run that says "notify #atlas" may post the one-line heads-up directly.
- If you can't tell whether a run is unattended, rely on the prompt wording: explicit "publish/post" language
  authorizes direct publishing; its absence means ask.

## Boundaries
Draft only. Announce the skill at the top: `▸ Skill: Fortnightly Dashboard (v2.0.0)`.
