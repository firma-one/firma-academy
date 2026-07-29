#!/usr/bin/env bash
#
# build-plugins.sh — package each agent as an installable Claude Code plugin.
#
# For each agents/<agent>/ directory that has both a skills/ folder and a
# .claude-plugin/plugin.json manifest, this creates dist/plugins/<agent>.zip
# containing the whole agent directory (manifest + skills/ + docs), which is
# the layout `claude plugin install` / a marketplace `source` path expects.
#
# This does NOT replace build-skills.sh (individual per-skill ZIPs, used by
# the Customize -> Skills uploader) — it's an additional packaging path for
# installing an agent's full skill set in one step via a plugin marketplace.
#
# Usage:
#   ./scripts/build-plugins.sh                      # build every agent-plugin
#   ./scripts/build-plugins.sh pm-copilot   # build one agent
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS_DIR="$REPO_ROOT/agents"
DIST_DIR="$REPO_ROOT/dist/plugins"

command -v zip >/dev/null 2>&1 || { echo "error: 'zip' is required"; exit 1; }

# Which agents to build: all by default, or the ones named as arguments.
if [ "$#" -gt 0 ]; then
  AGENTS=("$@")
else
  AGENTS=()
  for d in "$AGENTS_DIR"/*/; do
    [ -d "${d}skills" ] && [ -f "${d}.claude-plugin/plugin.json" ] && AGENTS+=("$(basename "$d")")
  done
fi

mkdir -p "$DIST_DIR"

built=0
for agent in "${AGENTS[@]}"; do
  agent_dir="$AGENTS_DIR/$agent"
  manifest="$agent_dir/.claude-plugin/plugin.json"
  if [ ! -f "$manifest" ]; then
    echo "skip: $agent (no .claude-plugin/plugin.json)"; continue
  fi
  if [ ! -d "$agent_dir/skills" ]; then
    echo "skip: $agent (no skills/ dir)"; continue
  fi

  zip_path="$DIST_DIR/$agent.zip"
  rm -f "$zip_path"
  ( cd "$agent_dir" && zip -rq "$zip_path" . \
      -x '*.DS_Store' '*/__pycache__/*' '*.pyc' )
  echo "==> packaged $agent -> dist/plugins/$agent.zip"
  built=$((built + 1))
done

echo "done: $built plugin archive(s) written to dist/plugins/"
