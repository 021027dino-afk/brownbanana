#!/bin/bash
# 클라우드 세션 시작 시 .claude/settings.json에 선언된 마켓플레이스·플러그인을 설치한다.
# 공식 마켓플레이스는 자동으로 로드되지만 im-not-ai 같은 서드파티는 등록되지 않아서 필요하다.
# 이미 설치된 항목은 건너뛰므로 여러 번 실행해도 안전하다.
set -uo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

settings="${CLAUDE_PROJECT_DIR:-$(pwd)}/.claude/settings.json"
if ! command -v jq >/dev/null || ! command -v claude >/dev/null || [ ! -f "$settings" ]; then
  echo "session-start: jq, claude 또는 $settings 가 없어 플러그인 설치를 건너뜀" >&2
  exit 0
fi

# 마켓플레이스 등록 (github 소스만 선언돼 있음)
jq -r '.extraKnownMarketplaces // {} | to_entries[] | select(.value.source.source == "github") | .value.source.repo' "$settings" |
  while read -r repo; do
    claude plugin marketplace add "$repo" >/dev/null 2>&1 ||
      echo "session-start: 마켓플레이스 추가 실패: $repo" >&2
  done

# 켜진 플러그인 중 아직 설치되지 않은 것만 설치
installed="$(claude plugin list --json 2>/dev/null | jq -r '.[].id' 2>/dev/null || true)"
jq -r '.enabledPlugins // {} | to_entries[] | select(.value == true) | .key' "$settings" |
  while read -r plugin; do
    if grep -qxF "$plugin" <<<"$installed"; then
      continue
    fi
    if claude plugin install "$plugin" --scope project >/dev/null 2>&1; then
      echo "session-start: 설치됨 $plugin"
    else
      echo "session-start: 플러그인 설치 실패: $plugin" >&2
    fi
  done

exit 0
