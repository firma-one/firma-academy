# Contributing to firma-academy

House rules for adding an agent or a skill. Keeping these consistent is what lets the library scale without drift.

## Add a new agent
1. Create `agents/<agent-name>/` with:
   - `README.md` — the agent's purpose, standing assignment, design stance.
   - `instructions.md` — pasted into the Claude Project's custom-instructions field.
   - `DEPLOY.md` — package + install + build-the-Project steps.
   - `skills/` — one folder per skill (see below).
   - `.claude-plugin/plugin.json` — plugin manifest, so the agent is installable as a plugin (see below).
2. Add a row to the agents table in the root `README.md`.
3. Add a `plugins[]` entry for the agent to the repo-level `.claude-plugin/marketplace.json`.
4. `make build-<agent-name>` to package the individual skill ZIPs, and/or `make build-plugins` to package it as a plugin; `make validate` to check everything is well-formed; then follow the agent's `DEPLOY.md`.

### Make the agent an installable plugin

Add `agents/<agent-name>/.claude-plugin/plugin.json`:

```json
{
  "name": "<agent-name>",
  "displayName": "Human Readable Name",
  "version": "1.0.0",
  "description": "One or two sentences: what this agent does and its human-in-the-loop boundary.",
  "author": { "name": "firma-academy" }
}
```

- `name` must be kebab-case and match the directory name.
- Keep `skills/` exactly where it already is — the plugin manifest sits alongside it in `.claude-plugin/`, it doesn't move anything.
- Then add a matching entry under `plugins[]` in the root `.claude-plugin/marketplace.json`:

  ```json
  { "name": "<agent-name>", "source": "./agents/<agent-name>", "version": "1.0.0" }
  ```

- `make validate` checks both manifests parse and that the marketplace entry's `source` points at a real plugin.

Keep each agent **self-contained**: its skills live under its own `skills/`. Only promote a skill to a top-level `shared/skills/` when a *second* agent genuinely needs it — don't pre-share.

## Author a skill
Each skill is a folder containing at minimum a `SKILL.md`. Front-matter is required:

```markdown
---
name: kebab-case-name
description: "One or two sentences. Say WHEN to use it (the trigger phrases) and WHAT it produces. This is what the model matches on, so make the triggers concrete."
---

# Human-Readable Skill Name

## When to use
## Inputs to read
## Procedure          (numbered steps)
## Output shape
## Boundaries         (draft-only; announce `▸ Skill: <Name>` at top of output)
```

House conventions:
- **Draft, never publish.** Every skill states it drafts for human review and takes no irreversible action.
- **Announce itself.** Output starts with `▸ Skill: <Name>` for visibility.
- **Synthesize, cite, caveat.** Connect facts into insight; trace claims to sources; flag stale/soft data.
- **Prose by default; code only where it earns it.** Most skills are procedures the model follows. Add a `scripts/` folder with runnable code only when deterministic computation is genuinely needed (e.g. metrics, charts). Code skills require Code execution & File creation enabled in the Claude app, and must degrade gracefully to prose when it's off.

## Skill folder shape
```
skills/<skill-name>/
├── SKILL.md
└── scripts/            (optional — only for code skills)
    └── *.py
```
The build script zips each skill so `SKILL.md` is at the archive root — required by the uploader. Don't nest the skill inside an extra directory.

## Test before committing
- `make test` runs each script's `--demo` self-check; keep it green.
- `make validate` checks every plugin/marketplace manifest parses and every skill has a `SKILL.md` with front-matter; keep it green.
- For prose skills, dry-run the agent in a Project with a representative prompt and confirm the skill triggers and announces itself.

## Commit hygiene
- `dist/` is build output — git-ignored, never committed.
- Keep `sample_output.png` next to a code skill as a reference artefact (allow-listed in `.gitignore`).
