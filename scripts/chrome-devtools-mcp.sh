#!/usr/bin/env bash
# chrome-devtools-mcp 실행 래퍼.
# 로컬: 설치된 Chrome을 그대로 사용.
# 클라우드 세션(Chromium이 /opt/pw-browsers에 있는 환경): 헤드리스 + 프록시 설정으로 실행.
set -euo pipefail

args=(-y chrome-devtools-mcp@1.13.0)  # 검증한 버전으로 고정. 올릴 때 여기만 바꾸면 됨

if [[ -x /opt/pw-browsers/chromium ]]; then
  args+=(--headless --isolated --executablePath /opt/pw-browsers/chromium
         --chromeArg=--no-sandbox)
  proxy="${HTTPS_PROXY:-${https_proxy:-}}"
  if [[ -n "$proxy" ]]; then
    # 클라우드 프록시는 자체 CA로 TLS를 다시 서명하므로 인증서 오류를 무시
    args+=(--proxyServer "$proxy" --acceptInsecureCerts)
  fi
fi

exec npx "${args[@]}" "$@"
