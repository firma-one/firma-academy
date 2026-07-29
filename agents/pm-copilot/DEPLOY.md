# Deploy Guide — PM Copilot

How to take this repo from disk into a working agent. Three surfaces are involved: **native Skills** (account-level, reusable, visible in Customize → Skills), a **Claude Project** (the standing role + connectors + Atlas context), and — for Claude Code users — installing this agent's whole skill set in one step as a **plugin** from this repo's marketplace.

## Prerequisites
- Claude desktop or web app, paid plan (Pro/Max/Team/Enterprise) for the Skills feature.
- **Settings → Capabilities → enable Code execution & File creation** — required for skills to run, and specifically for `pmc-outcome-dashboard` to compute/chart. Without it, the dashboard skill falls back to a prose-only view.
- Atlassian connector (Jira + Confluence) connected, with access to project **AT** and space **Atlas**.
- Google Drive + Gmail connectors (write access) for `pmc-drive-report-publisher` and `pmc-gmail-stakeholder-update`; Slack connector (write access) for `pmc-slack-notifier`. All three publishing skills degrade gracefully (report the missing connector) if not connected.

## Step 1 — Package each skill as a ZIP
Each skill folder must zip so that `SKILL.md` sits at the **root** of the archive (not inside an extra directory). From the repo root:

```bash
cd skills
for d in pmc-executive-brief pmc-risk-intelligence pmc-stakeholder-email pmc-decision-register pmc-action-register pmc-outcome-dashboard pmc-drive-report-publisher pmc-slack-notifier pmc-gmail-stakeholder-update; do
  (cd "$d" && zip -r "../../dist/$d.zip" . -x '*.DS_Store')
done
```
This produces nine ZIPs in `dist/`. (The `pmc-outcome-dashboard.zip` includes its `scripts/` folder.)

### Alternative: install as a plugin (Claude Code)
If you're using Claude Code rather than the Claude app, skip Steps 1–2 below and install all nine skills in one step as a plugin, from this repo's own marketplace:

```bash
/plugin marketplace add git@github.com:firma-one/firma-academy.git
/plugin install pm-copilot@firma-academy
```

This reads `agents/pm-copilot/.claude-plugin/plugin.json` and delivers the whole `skills/` folder in one install — equivalent to Steps 1–2, but a single command and always in sync with this repo. You still need to connect the Atlassian connector and supply `instructions.md` to whatever surface hosts the standing role (Step 3 below still applies if you're pairing this with a Claude Project). See the root `README.md`'s "Publish & install as a plugin marketplace" section for the general flow, and its security note: only add marketplaces your organization has reviewed and publishes itself, not untrusted community ones.

## Step 2 — Upload the skills
In the Claude app: **Customize → Skills → Add → upload** each ZIP. Each appears in the list; **toggle it on**. Uploaded skills are private to your account.

Verify: start a chat and ask, e.g., *"Use the pmc-risk-intelligence skill for Project Atlas."* It should announce `▸ Skill: Risk Intelligence` and run.

## Step 3 — Create the Project
1. New Project → name it e.g. *PM Copilot — Atlas*.
2. Connect the **Atlassian** connector, plus **Google Drive**, **Gmail**, and **Slack** for the publishing skills.
3. Paste `instructions.md` into the Project's **custom-instructions** field.
4. (Optional) Add the Atlas Charter/RAID as Project knowledge for extra grounding — though the agent can also read them live from Confluence.

## Step 4 — Dry run
In the Project, prompt: **"Prepare Monday's Steering Committee for Project Atlas."**
Expect: a labelled governance pack (brief, risk radar, outcome view, decisions/actions), each a draft, each announcing its skill. If the dashboard skill is used, it computes metrics and renders a chart (Code execution must be on).

Then try a publishing skill, e.g. **"Save the steering pack to Drive"** — expect a direct write to the Atlas Shared Drive with a `viewUrl`. Try **"post the steering summary to #atlas"** — expect a Slack draft staged for review, not sent, unless you explicitly say "post it now".

## Notes
- **Scope:** native Skills are account-level and work across every chat and Cowork, not just this Project. The Project supplies the standing Atlas role + connectors; the skills supply the repeatable procedures.
- **Sharing:** to share skills with colleagues you need a Team/Enterprise plan and an owner to enable sharing in Organization settings. On personal plans they stay private to you.
- **Updating a skill:** edit the file here, re-zip that one skill, re-upload (replaces the entry). Keep this repo as the source of truth.
- **No code fallback:** if Code execution is off, `pmc-outcome-dashboard` still works as a prose outcome view — it just won't compute/chart.
- **Publishing governance gradient:** `pmc-drive-report-publisher` writes directly (internal artefact, the team's own workspace). `pmc-slack-notifier` and `pmc-gmail-stakeholder-update` reach stakeholders, so they default to a draft for the PM to review — direct send only on explicit instruction (and Gmail can never send autonomously at all, by connector design).
