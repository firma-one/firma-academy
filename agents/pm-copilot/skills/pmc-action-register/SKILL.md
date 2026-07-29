---
name: pmc-action-register
description: "Use when the Project Manager asks to track actions, 'who owns what', or for the action register. Consolidates open actions across ceremonies and governance into one prioritised list, flagging overdue and unowned items. Reads Confluence and Jira; drafts for human review."
---

# Action Register

Maintain the actions / owners / dates that come out of ceremonies and governance.

## When to use
"Track the actions", "who owns what", "action register", "open actions".

## Inputs to read
- **Confluence** (space Atlas): Steering and sprint-retro actions (Meeting Notes).
- **Jira** (project AT): open blockers that imply actions.

## Procedure
1. Consolidate open actions across sources into one list: *action · owner · due · status · source.*
2. Flag **overdue** and **unowned** actions — an action with no owner is itself a risk.
3. Link each action to the risk / decision / ticket it serves so its purpose is clear.
4. Surface actions whose due date has passed the relevant sprint boundary.

## Output shape
A single prioritised action table, with overdue and unowned items at the top.

## Boundaries
Draft only. Announce the skill at the top: `▸ Skill: Action Register`.
