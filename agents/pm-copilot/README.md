# PM Copilot

A Claude-based **digital teammate for a Software Project Manager**, built for the NIIT agentic-AI proof of concept. It reads the live enterprise toolchain (Jira + Confluence), synthesises the true state of a delivery programme, drafts executive governance artefacts, and can publish them (Drive/Slack/Gmail) under a governed action boundary. It **drafts by default; the human approves anything that reaches stakeholders** — human-in-the-loop is enforced at the tool-permission layer, not just by policy.

Standing assignment: **Project Atlas** — a retail-banking digital loan initiative (Jira project `AT`, Confluence space `Atlas`), whose business outcome is **+20% digital loan conversion**.

## Repository layout
```
pm-copilot/
├── README.md                 ← this file
├── DEPLOY.md                 ← how to package + install skills and build the Project
├── instructions.md           ← paste into the Project's custom-instructions field
├── .claude-plugin/
│   └── plugin.json           ← plugin manifest (installable via the repo's marketplace)
├── .gitignore
└── skills/                   ← one folder per skill (each zips to a native Skill)
    ├── pmc-executive-brief/SKILL.md
    ├── pmc-risk-intelligence/SKILL.md
    ├── pmc-stakeholder-email/SKILL.md
    ├── pmc-decision-register/SKILL.md
    ├── pmc-action-register/SKILL.md
    ├── pmc-outcome-dashboard/
    │   ├── SKILL.md
    │   └── scripts/
    │       ├── compute_metrics.py   ← runnable: computes velocity/spillover + chart
    │       └── sample_output.png    ← example chart
    ├── pmc-drive-report-publisher/SKILL.md
    ├── pmc-slack-notifier/SKILL.md
    └── pmc-gmail-stakeholder-update/SKILL.md
```

## The nine skills
| Skill | Type | What it produces |
|---|---|---|
| pmc-executive-brief | prose | One-page sponsor status, anchored to the outcome |
| pmc-risk-intelligence | prose | Ranked, causal, decision-oriented risk radar |
| pmc-stakeholder-email | prose | Drafts the PM's update email content (never sends) |
| pmc-decision-register | prose | Decisions made + decisions needed (with recommendations) |
| pmc-action-register | prose | Consolidated actions; overdue/unowned flagged |
| pmc-outcome-dashboard | **code** | Progress vs. the business outcome; computes + charts metrics |
| pmc-drive-report-publisher | **write** | Writes a finished report to the Atlas Shared Drive (direct write — internal artefact) |
| pmc-slack-notifier | **write** | Posts an update to `#atlas` (drafts for review by default; direct send only on explicit instruction) |
| pmc-gmail-stakeholder-update | **write** | Places the stakeholder email into Gmail as a draft (never sends autonomously) |

The first six are reasoning procedures the model follows (**pmc-outcome-dashboard** additionally runs `compute_metrics.py` so its numbers are calculated, not estimated). The last three are **publishing** skills that write to the live toolchain, under a governance gradient: internal artefacts (Drive) write directly; anything reaching stakeholders (Slack, Gmail) defaults to a draft for human review.

## Design stance (why this is an agent, not a chatbot)
Persistent role + scoped tools (connectors) + a reusable, versioned skill library + a governed action boundary. The boundary is deliberate: the further an action reaches toward external stakeholders, the more it defaults to human review — the agent is never able to send email or notify stakeholders unreviewed.

## Two runtimes, one repo
- **Claude app (Projects + native Skills):** the primary target. Zip each skill → upload via Customize → Skills; paste `instructions.md` into a Project. See `DEPLOY.md`.
- **Claude Code:** this same `skills/` tree drops into `.claude/skills/` and is loaded natively from disk — no rework — if you ever want the developer-flavoured, fully filesystem-managed version.

## Cleanup after the demo
The synthetic Atlas data lives in Jira (project `AT`, label `atlas`) and Confluence (space `Atlas`, under "Project Atlas — Governance"). Remove both when the interview is done.
