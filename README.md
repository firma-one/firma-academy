# firma-academy

A monorepo of **Claude-based agents** — reusable "digital teammates" built on Claude Projects and Agent Skills. Each agent is a self-contained package of Project instructions plus a versioned library of skills; some skills run code. The repo is the source of truth; the Claude app (Customize → Skills + a Project) is the deploy target.

## Repository layout
```
firma-academy/
├── README.md              ← this file (index of agents)
├── CONTRIBUTING.md        ← how to author an agent + skills (house style)
├── Makefile               ← make build / build-<agent> / build-plugins / validate / test / clean / list
├── .claude-plugin/
│   └── marketplace.json   ← repo-level marketplace manifest (lists every agent-plugin)
├── .gitignore
├── scripts/
│   ├── build-skills.sh    ← packages every agent's skills into dist/<agent>/*.zip
│   ├── build-plugins.sh   ← packages each agent as a plugin archive into dist/plugins/<agent>.zip
│   └── validate.sh        ← sanity-checks plugin/marketplace manifests + skill files
├── dist/                  ← build output (git-ignored)
└── agents/
    └── project-coordinator/   ← first agent
        ├── .claude-plugin/
        │   └── plugin.json    ← plugin manifest (makes this agent an installable plugin)
        ├── README.md
        ├── DEPLOY.md
        ├── instructions.md
        └── skills/
            ├── executive-brief/SKILL.md
            ├── risk-intelligence/SKILL.md
            ├── stakeholder-email/SKILL.md
            ├── decision-register/SKILL.md
            ├── action-register/SKILL.md
            ├── outcome-dashboard/
            │   ├── SKILL.md
            │   └── scripts/compute_metrics.py + sample_output.png
            ├── drive-report-publisher/SKILL.md
            ├── slack-notifier/SKILL.md
            └── gmail-stakeholder-update/SKILL.md
```

## Agents
| Agent | Role | Skills | Notes |
|---|---|---|---|
| **project-coordinator** | Digital teammate to a Software PM: reads Jira + Confluence, drafts executive governance artefacts, and publishes them (Drive/Slack/Gmail) under review | 9 (5 prose, 1 code, 3 publishing) | Standing assignment: Project Atlas. Human-in-the-loop; internal artefacts write directly, stakeholder-facing actions draft first. |

*(Add a row per agent as the library grows.)*

## Build & deploy
```bash
make build                       # zip all agents' skills into dist/ (per-skill ZIPs)
make build-project-coordinator   # or just one agent
make build-plugins                # package each agent as an installable plugin -> dist/plugins/<agent>.zip
make validate                    # sanity-check plugin/marketplace manifests + skill files
make list                        # see agents and their skills
make test                        # run script self-checks (demo modes)
```
Two ways to install skills, both built from the same `skills/` folders — pick per situation:

- **Individual skill ZIPs** (`make build`): upload each `dist/<agent>/<skill>.zip` via **Customize → Skills** one at a time. Per an agent's `DEPLOY.md`, also paste that agent's `instructions.md` into a new **Claude Project** with the right connectors.
- **Plugin, via a marketplace** (`make build-plugins`): install the whole agent's skill set in one step through Claude Code's plugin system. See [Publish & install as a plugin marketplace](#publish--install-as-a-plugin-marketplace) below.

## Publish & install as a plugin marketplace

This repo is also a **Claude Code plugin marketplace**: `.claude-plugin/marketplace.json` lists every agent that has a `.claude-plugin/plugin.json`, and each such agent's `skills/` folder installs in one step as a plugin — no per-skill ZIP uploads.

**Publish** (repo maintainer): push the repo (with `.claude-plugin/marketplace.json` and each agent's `.claude-plugin/plugin.json`) to your org's git remote. Nothing else to build or host — the marketplace is read directly from the git URL.

**Add the marketplace and install a plugin** (org admin / user), from the repo's git URL:
```bash
# in Claude Code
/plugin marketplace add git@github.com:firma-one/firma-academy.git
/plugin install project-coordinator@firma-academy
```
This delivers all of `project-coordinator`'s skills in one install — equivalent to uploading all nine ZIPs, done in a single step and kept in sync with this repo. Adding a new agent to the marketplace is just: give it a `skills/` folder, drop a `.claude-plugin/plugin.json` next to it, and add a `plugins[]` entry to the repo's `.claude-plugin/marketplace.json` (`make validate` checks both).

**Security note:** only add and install marketplaces your organization has reviewed and publishes itself (like this repo, once vetted) — treat third-party/community plugin marketplaces the same as any other unreviewed code source, and don't add them by default.

## Conventions
When `shared/` scope is needed later (a skill reused by two agents, or common conventions), add a top-level `shared/` folder — deferred until a second agent actually reuses something. See `CONTRIBUTING.md` for authoring rules.

## Design stance
Every agent here follows the same doctrine: a persistent role, scoped tools (connectors), a reusable skill library, and a governed action boundary (read the systems of record; draft artefacts; the further an action reaches toward external stakeholders, the more it defaults to human review). That boundary is what makes these agents, not chatbots — and safe to place next to enterprise systems.
