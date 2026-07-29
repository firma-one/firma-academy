#!/usr/bin/env bash
#
# validate.sh — sanity-check plugin & marketplace manifests before publishing.
#
# Checks, without any extra dependencies beyond python3 (already required by
# `make test`):
#   - repo-level .claude-plugin/marketplace.json is present and well-formed
#     JSON with the required `name`, `owner.name`, `plugins[]` fields
#   - every plugins[].source in the marketplace resolves to an agent dir that
#     exists and has a .claude-plugin/plugin.json
#   - every agents/*/.claude-plugin/plugin.json (if present) is well-formed
#     JSON with the required `name` field
#   - every skill referenced under an agent's skills/ has a SKILL.md, and
#     every SKILL.md has non-empty YAML front-matter with a `name:` field
#
# Usage:
#   ./scripts/validate.sh
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS_DIR="$REPO_ROOT/agents"
MARKETPLACE_FILE="$REPO_ROOT/.claude-plugin/marketplace.json"

command -v python3 >/dev/null 2>&1 || { echo "error: 'python3' is required"; exit 1; }

errors=0
warn() { echo "warn:  $1"; }
fail() { echo "error: $1"; errors=$((errors + 1)); }

json_valid() {
  python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$1" >/dev/null 2>&1
}

json_get() {
  # json_get <file> <dotted.path> -> prints value or empty string if missing
  python3 - "$1" "$2" <<'PY'
import json, sys
path = sys.argv[2].split(".")
try:
    obj = json.load(open(sys.argv[1]))
    for p in path:
        obj = obj[p]
    print(obj if isinstance(obj, str) else json.dumps(obj))
except Exception:
    print("")
PY
}

# --- 1. marketplace manifest -------------------------------------------------
echo "==> checking marketplace manifest"
if [ ! -f "$MARKETPLACE_FILE" ]; then
  fail "missing $MARKETPLACE_FILE"
else
  if ! json_valid "$MARKETPLACE_FILE"; then
    fail "$MARKETPLACE_FILE is not valid JSON"
  else
    name="$(json_get "$MARKETPLACE_FILE" name)"
    owner_name="$(json_get "$MARKETPLACE_FILE" owner.name)"
    [ -n "$name" ] || fail "marketplace.json: missing required field 'name'"
    [ -n "$owner_name" ] || fail "marketplace.json: missing required field 'owner.name'"

    plugin_count="$(python3 -c "import json; print(len(json.load(open('$MARKETPLACE_FILE')).get('plugins', [])))" 2>/dev/null || echo 0)"
    if [ "$plugin_count" -eq 0 ]; then
      fail "marketplace.json: 'plugins' array is missing or empty"
    else
      i=0
      while [ "$i" -lt "$plugin_count" ]; do
        p_name="$(python3 -c "import json; print(json.load(open('$MARKETPLACE_FILE'))['plugins'][$i].get('name',''))")"
        p_source="$(python3 -c "import json; print(json.load(open('$MARKETPLACE_FILE'))['plugins'][$i].get('source',''))")"
        [ -n "$p_name" ] || fail "marketplace.json: plugins[$i] missing 'name'"
        [ -n "$p_source" ] || fail "marketplace.json: plugins[$i] missing 'source'"
        if [ -n "$p_source" ]; then
          case "$p_source" in
            ./*)
              src_dir="$REPO_ROOT/${p_source#./}"
              if [ ! -d "$src_dir" ]; then
                fail "marketplace.json: plugins[$i] source '$p_source' does not exist"
              elif [ ! -f "$src_dir/.claude-plugin/plugin.json" ]; then
                fail "marketplace.json: plugins[$i] source '$p_source' has no .claude-plugin/plugin.json"
              fi
              ;;
            *)
              warn "marketplace.json: plugins[$i] source '$p_source' is not a local path, skipping existence check"
              ;;
          esac
        fi
        i=$((i + 1))
      done
    fi
  fi
fi

# --- 2. per-agent plugin manifests -------------------------------------------
echo "==> checking agent plugin manifests"
for d in "$AGENTS_DIR"/*/; do
  agent="$(basename "$d")"
  manifest="${d}.claude-plugin/plugin.json"
  [ -f "$manifest" ] || { warn "$agent: no .claude-plugin/plugin.json (skipped by build-plugins)"; continue; }

  if ! json_valid "$manifest"; then
    fail "$agent: plugin.json is not valid JSON"
    continue
  fi
  p_name="$(json_get "$manifest" name)"
  [ -n "$p_name" ] || fail "$agent: plugin.json missing required field 'name'"
  if [ -n "$p_name" ] && echo "$p_name" | LC_ALL=C grep -Eq '[A-Z]| '; then
    fail "$agent: plugin.json 'name' ($p_name) should be kebab-case, no spaces/uppercase"
  fi
done

# --- 3. skills have SKILL.md with front-matter -------------------------------
echo "==> checking skill directories"
for d in "$AGENTS_DIR"/*/; do
  agent="$(basename "$d")"
  skills_dir="${d}skills"
  [ -d "$skills_dir" ] || continue
  for s in "$skills_dir"/*/; do
    [ -d "$s" ] || continue
    skill="$(basename "$s")"
    skill_md="${s}SKILL.md"
    if [ ! -f "$skill_md" ]; then
      fail "$agent/$skill: missing SKILL.md"
      continue
    fi
    if ! head -n 1 "$skill_md" | grep -q '^---$'; then
      fail "$agent/$skill: SKILL.md has no YAML front-matter (must start with '---')"
      continue
    fi
    if ! awk '/^---$/{c++} c==1 && /^name:/{f=1} c>=2{exit} END{exit !f}' "$skill_md"; then
      fail "$agent/$skill: SKILL.md front-matter missing 'name:' field"
    fi
  done
done

echo "----------------------------------------"
if [ "$errors" -gt 0 ]; then
  echo "validate: FAILED with $errors error(s)"
  exit 1
fi
echo "validate: all manifests and skills OK"
