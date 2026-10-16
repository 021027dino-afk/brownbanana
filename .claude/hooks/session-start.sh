#!/bin/bash
# Installs the marketplaces and plugins declared in .claude/settings.json
# (extraKnownMarketplaces + enabledPlugins). Cloud sessions don't install
# them on their own, so this hook does it at session start.
set -uo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

SETTINGS="$CLAUDE_PROJECT_DIR/.claude/settings.json"
[ -f "$SETTINGS" ] || exit 0

log() { echo "[session-start] $*" >&2; }

# 1. Marketplaces
known=$(claude plugin marketplace list --json 2>/dev/null | jq -r '.[].name' || true)
jq -r '.extraKnownMarketplaces // {} | to_entries[] | select(.value.source.source == "github") | "\(.key) \(.value.source.repo)"' "$SETTINGS" |
while read -r name repo; do
  if grep -qx "$name" <<<"$known"; then
    continue
  fi
  log "adding marketplace $name ($repo)"
  claude plugin marketplace add "$repo" >&2 || log "WARN: failed to add marketplace $name"
done

# 2. Plugins
installed=$(claude plugin list --json 2>/dev/null | jq -r '.[].id // empty' || true)
jq -r '.enabledPlugins // {} | to_entries[] | select(.value == true) | .key' "$SETTINGS" |
while read -r plugin; do
  if grep -qx "$plugin" <<<"$installed"; then
    continue
  fi
  log "installing $plugin"
  claude plugin install "$plugin" --scope user >&2 || log "WARN: failed to install $plugin"
done

exit 0
