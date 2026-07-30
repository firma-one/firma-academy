# Deploy Guide — PM Copilot

How to take this repo from disk into a working agent. Three surfaces are involved: **native Skills** (account-level, reusable, visible in Customize → Skills), a **Claude Project** (the standing role + connectors + Atlas context), and — for Claude Code users — installing this agent's whole skill set in one step as a **plugin** from this repo's marketplace.

PM Copilot exposes **five role-shaped skills**: `pmc-helper` (menu/routing), `pmc-fortnightly-dashboard`, `pmc-executive-brief`, `pmc-governance-intelligence`, and `pmc-raid-maintainer`. Publishing mechanics (Confluence write, Drive archive, Gmail draft, Slack notify) are NOT separate skills — they are internal capabilities documented in `references/capabilities.md` and used *inside* the skills.

## Prerequisites
- Claude desktop or web app, paid plan (Pro/Max/Team/Enterprise) for the Skills feature.
- **Settings → Capabilities → enable Code execution & File creation** — required for skills to run, and specifically for `pmc-fortnightly-dashboard` to compute/chart metrics. Without it, the dashboard falls back to a prose-only outcome view.
- Atlassian connector (Jira + Confluence) connected, with access to project **AT** and space **Atlas**.
- Google Drive + Gmail + Slack connectors (write access) for the publishing capabilities used inside `pmc-fortnightly-dashboard`, `pmc-executive-brief`, and `pmc-governance-intelligence`. Each degrades gracefully (reports the missing connector) if not connected.

## Step 1 — Package each skill as a ZIP
Each skill folder must zip so that `SKILL.md` sits at the **root** of the archive (not inside an extra directory). From the plugin folder:

```bash
cd agents/pm-copilot/skills
for d in pmc-helper pmc-fortnightly-dashboard pmc-executive-brief pmc-governance-intelligence pmc-raid-maintainer; do
  (cd "$d" && zip -r "../../../dist/pm-copilot/$d.zip" . -x '*.DS_Store')
done
```
This produces five ZIPs in `dist/pm-copilot/`. (`pmc-fortnightly-dashboard.zip` includes its `scripts/` folder.) The skills reference `references/capabilities.md` for the shared publishing mechanics — when installing as a plugin (below), that file ships automatically; when uploading skills individually, the mechanics are still described inline in each skill's Publish section.

### Alternative: install as a plugin (Claude Code)
If you're using Claude Code rather than the Claude app, skip Steps 1–2 below and install all five skills in one step as a plugin, from this repo's own marketplace:

```bash
/plugin marketplace add git@github.com:firma-one/firma-academy.git
/plugin install pm-copilot@firma-academy
```

This reads `agents/pm-copilot/.claude-plugin/plugin.json` and delivers the whole `agents/pm-copilot/` tree — the five skills **and** `references/capabilities.md` and `instructions.md` — in one install, always in sync with this repo. You still need to connect the Atlassian (and Drive/Gmail/Slack) connectors and supply `instructions.md` to whatever surface hosts the standing role (Step 3 below if you're pairing this with a Claude Project). See the root `README.md`'s "Publish & install as a plugin marketplace" section for the general flow, and its security note: only add marketplaces your organization has reviewed and publishes itself, not untrusted community ones.

## Step 2 — Upload the skills
In the Claude app: **Customize → Skills → Add → upload** each ZIP. Each appears in the list; **toggle it on**. Uploaded skills are private to your account.

Verify: start a chat and ask, e.g., *"Use the pmc-governance-intelligence skill for Project Atlas."* It should announce `▸ Skill: Governance Intelligence` and run.

## Step 3 — Create the Project
1. New Project → name it e.g. *PM Copilot — Atlas*.
2. Connect the **Atlassian** connector, plus **Google Drive**, **Gmail**, and **Slack** for the publishing capabilities.
3. Paste `instructions.md` into the Project's **custom-instructions** field.
4. (Optional) Add the Atlas Charter/RAID as Project knowledge for extra grounding — though the agent can also read them live from Confluence.

## Step 4 — Dry run
In the Project, prompt: **"Prepare Monday's Steering Committee for Project Atlas."**
Expect: a labelled governance pack — the Fortnightly Dashboard and Governance Intelligence to Confluence, then the Executive Brief (Gmail draft + Drive archive) — each a draft, each announcing its skill. If the dashboard is used, it computes metrics from LIVE Jira and renders a chart (Code execution must be on).

Then exercise a publishing capability, e.g. **"Archive the exec brief to Drive"** — expect the brief built as a real `.docx`, placed on the Atlas Shared Drive via `copy_file` to a dated file (see below). Try **"post the steering summary to #atlas"** — expect a Slack **draft** staged for review, not sent, unless you explicitly say "post it now".

## Notes
- **Scope:** native Skills are account-level and work across every chat and Cowork, not just this Project. The Project supplies the standing Atlas role + connectors; the skills supply the repeatable procedures.
- **Sharing:** to share skills with colleagues you need a Team/Enterprise plan and an owner to enable sharing in Organization settings. On personal plans they stay private to you.
- **Updating a skill:** edit the file here, re-zip that one skill, re-upload (replaces the entry). Keep this repo as the source of truth.
- **No code fallback:** if Code execution is off, `pmc-fortnightly-dashboard` still works as a prose outcome view — it just won't compute/chart.
- **Drive write model (`copy_file`, not base64):** every Drive artefact is a **new dated file** (the connector cannot update in place). The base file lives on Drive; each run reads it, edits it in the workspace with the xlsx/docx skill, then uses **`copy_file`** to place the new dated file — instant, server-side, no base64. base64 `create_file` hangs on non-trivial files and is avoided. Full mechanics: `references/capabilities.md` (Drive upload mechanics).
- **Publishing governance gradient:** Confluence and Drive are internal writes (direct on request — the team's own workspace). Gmail and Slack reach stakeholders, so they default to a **draft** for the PM to review — direct send only on explicit instruction (and Gmail can never send autonomously at all, by connector design).
