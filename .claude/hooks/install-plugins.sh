#!/bin/bash
# Install the plugins enabled in .claude/settings.json.
# Cloud sessions never show the trust prompt that installs them, so do it here.
set -uo pipefail

[ "${CLAUDE_CODE_REMOTE:-}" = "true" ] || exit 0

settings="${CLAUDE_PROJECT_DIR:-$(pwd)}/.claude/settings.json"
[ -f "$settings" ] || exit 0

{
  jq -r '.extraKnownMarketplaces // {} | to_entries[] | select(.value.source.source == "github") | .value.source.repo' "$settings" |
    while read -r repo; do
      claude plugin marketplace add "$repo" || echo "marketplace add failed: $repo"
    done

  jq -r '.enabledPlugins // {} | to_entries[] | select(.value == true) | .key' "$settings" |
    while read -r plugin; do
      claude plugin install "$plugin" || echo "plugin install failed: $plugin"
    done
} >&2

exit 0
