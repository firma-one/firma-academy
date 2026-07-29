#!/usr/bin/env bash
#
# build-skills.sh — package every agent's skills into upload-ready ZIPs.
#
# For each agents/<agent>/skills/<skill>/ directory it creates
# dist/<agent>/<skill>.zip with SKILL.md at the archive root (the layout the
# Claude "Customize -> Skills" uploader expects). A skill's scripts/ folder
# (e.g. pmc-outcome-dashboard's) is included automatically.
#
# Usage:
#   ./scripts/build-skills.sh              # build every agent
#   ./scripts/build-skills.sh pm-copilot   # build one agent
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS_DIR="$REPO_ROOT/agents"
DIST_DIR="$REPO_ROOT/dist"

command -v zip >/dev/null 2>&1 || { echo "error: 'zip' is required"; exit 1; }

# Which agents to build: all by default, or the ones named as arguments.
if [ "$#" -gt 0 ]; then
  AGENTS=("$@")
else
  AGENTS=()
  for d in "$AGENTS_DIR"/*/; do
    [ -d "${d}skills" ] && AGENTS+=("$(basename "$d")")
  done
fi

built=0
for agent in "${AGENTS[@]}"; do
  skills_dir="$AGENTS_DIR/$agent/skills"
  if [ ! -d "$skills_dir" ]; then
    echo "skip: $agent (no skills/ dir)"; continue
  fi
  out_dir="$DIST_DIR/$agent"
  mkdir -p "$out_dir"
  echo "==> $agent"
  for skill in "$skills_dir"/*/; do
    [ -f "${skill}SKILL.md" ] || { echo "  skip $(basename "$skill") (no SKILL.md)"; continue; }
    name="$(basename "$skill")"
    zip_path="$out_dir/$name.zip"
    rm -f "$zip_path"
    ( cd "$skill" && zip -rq "$zip_path" . -x '*.DS_Store' '*/__pycache__/*' '*.pyc' )
    echo "  packaged $name -> dist/$agent/$name.zip"
    built=$((built + 1))
  done
done

echo "done: $built skill ZIP(s) written to dist/"
