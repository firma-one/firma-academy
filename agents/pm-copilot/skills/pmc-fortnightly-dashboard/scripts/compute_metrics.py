#!/usr/bin/env python3
"""
compute_metrics.py — Fortnightly Dashboard metrics + chart.

PURE CALCULATOR. It does NOT talk to Jira. The skill must pull LIVE sprint data
from Jira (Atlassian connector, project AT) and write it to a JSON file FIRST,
then run this script on that file. There is deliberately no built-in sample data:
a real report is computed from live Jira points, never from a fixture.

Reads per-sprint committed/completed/goal-linked points, computes velocity,
spillover, and a simple completion projection, renders a chart, and prints a
JSON summary the agent can quote verbatim (numbers are computed, not estimated).

Usage:
    python compute_metrics.py --input sprints.json --out outcome_dashboard.png

sprints.json (produced by the skill from a LIVE Jira query):
    [{"sprint":"S11","committed":25,"completed":20,"goal_points":18}, ...]
  committed    = points committed at sprint start
  completed    = points actually completed
  goal_points  = subset of completed points that move the business outcome
                 (delivery vs. delivering-value distinction)
Optional: --remaining-goal-scope N (remaining outcome-linked points to go-live).
"""
import argparse
import json
import sys


def compute(sprints, remaining_goal_scope=None, in_progress_last=True):
    rows = []
    for s in sprints:
        committed = float(s.get("committed", 0) or 0)
        completed = float(s.get("completed", 0) or 0)
        goal = float(s.get("goal_points", 0) or 0)
        spill = committed - completed
        spill_pct = (spill / committed * 100.0) if committed else 0.0
        rows.append({
            "sprint": s.get("sprint", "?"),
            "committed": committed,
            "completed": completed,
            "goal_points": goal,
            "spillover_points": round(spill, 1),
            "spillover_pct": round(spill_pct, 1),
            "completion_pct": round((completed / committed * 100.0) if committed else 0.0, 1),
        })

    # Velocity baseline uses only completed sprints (exclude the in-progress last one).
    completed_rows = rows[:-1] if (in_progress_last and len(rows) > 1) else rows
    velocities = [r["completed"] for r in completed_rows]
    avg_velocity = round(sum(velocities) / len(velocities), 1) if velocities else 0.0

    projection = None
    if remaining_goal_scope is not None and avg_velocity > 0:
        projection = round(float(remaining_goal_scope) / avg_velocity, 1)

    total_committed = sum(r["committed"] for r in rows)
    total_completed = sum(r["completed"] for r in rows)
    total_goal = sum(r["goal_points"] for r in rows)

    summary = {
        "per_sprint": rows,
        "avg_velocity_completed_sprints": avg_velocity,
        "velocity_series": velocities,
        "total_committed": total_committed,
        "total_completed": total_completed,
        "total_goal_linked_completed": total_goal,
        "goal_linked_share_pct": round((total_goal / total_completed * 100.0) if total_completed else 0.0, 1),
        "remaining_goal_scope": remaining_goal_scope,
        "projected_sprints_to_clear_goal_scope": projection,
        "caveats": [
            "Velocity baseline excludes the in-progress sprint.",
            "Sprint 11 spillover and any mid-sprint re-pointing reduce velocity reliability.",
            "goal_points captures delivering-value, distinct from raw completed (delivered).",
        ],
    }
    return summary


def render_chart(summary, out_path):
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
    except Exception as e:  # pragma: no cover
        return {"chart": None, "chart_error": f"matplotlib unavailable: {e}"}

    rows = summary["per_sprint"]
    sprints = [r["sprint"] for r in rows]
    committed = [r["committed"] for r in rows]
    completed = [r["completed"] for r in rows]
    goal = [r["goal_points"] for r in rows]

    x = range(len(sprints))
    w = 0.26
    fig, ax = plt.subplots(figsize=(8, 4.5))
    ax.bar([i - w for i in x], committed, width=w, label="Committed", color="#8FA8C8")
    ax.bar([i for i in x], completed, width=w, label="Completed", color="#1F3864")
    ax.bar([i + w for i in x], goal, width=w, label="Outcome-linked", color="#548235")

    avg = summary["avg_velocity_completed_sprints"]
    if avg:
        ax.axhline(avg, linestyle="--", linewidth=1, color="#C00000",
                   label=f"Avg velocity ({avg})")

    ax.set_xticks(list(x))
    ax.set_xticklabels(sprints)
    ax.set_ylabel("Story points")
    ax.set_title("Project Atlas — Delivery vs. Outcome-linked Work by Sprint")
    ax.legend(fontsize=8, loc="upper right")
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    fig.tight_layout()
    fig.savefig(out_path, dpi=130)
    plt.close(fig)
    return {"chart": out_path, "chart_error": None}


def main(argv=None):
    ap = argparse.ArgumentParser(
        description="Compute Fortnightly Dashboard metrics from LIVE Jira sprint data "
                    "(the skill writes --input from a Jira query; no sample data exists).")
    ap.add_argument("--input", required=True,
                    help="Path to sprints JSON produced by the skill from a live Jira query")
    ap.add_argument("--out", default="outcome_dashboard.png", help="Chart output path")
    ap.add_argument("--remaining-goal-scope", type=float, default=None,
                    help="Remaining outcome-linked points to deliver toward go-live")
    args = ap.parse_args(argv)

    try:
        with open(args.input) as f:
            sprints = json.load(f)
    except FileNotFoundError:
        ap.error(f"input file not found: {args.input}. The skill must query Jira "
                 f"(project AT) and write real sprint points to this file FIRST.")
    except json.JSONDecodeError as e:
        ap.error(f"input is not valid JSON ({e}).")

    if not isinstance(sprints, list) or not sprints:
        ap.error("input JSON must be a non-empty list of sprint objects pulled from Jira. "
                 "Refusing to compute a report with no live data.")

    summary = compute(sprints, remaining_goal_scope=args.remaining_goal_scope)
    chart = render_chart(summary, args.out)
    summary.update(chart)
    print(json.dumps(summary, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
