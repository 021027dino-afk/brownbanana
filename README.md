# brownbanana

Claude Code 세션 구성(스킬 + 플러그인)을 보관하는 저장소입니다. 이 저장소로 세션을 열면 아래 구성이 자동으로 적용됩니다.

## 스킬 (`.agents/skills/`, `.claude/skills/`는 심링크)

| 스킬 | 출처 | 용도 |
|---|---|---|
| frontend-design | anthropics/skills | UI 디자인 방향 가이드 |
| ui-ux-pro-max | nextlevelbuilder/ui-ux-pro-max-skill | 스타일·팔레트·폰트·UX 가이드 검색 DB |
| impeccable | pbakaus/impeccable | 기존 UI 진단·비평·다듬기 |
| canvas-design | anthropics/skills | 포스터·아트 PNG/PDF 제작 (한글 폰트 Pretendard, Noto Serif KR 추가) |
| huashu-design (정리본) | alchaincyf/huashu-design v3.5.0 | 슬라이드·편집 가능한 PPTX, 애니메이션·영상(MP4/GIF), App Store 홍보 이미지, 샤오훙수 카드, 위챗 미니프로그램 |
| mineru | opendatalab/MinerU | PDF·스캔 이미지·오피스 문서를 Markdown으로 변환하고 OCR (표·수식, 긴 문서 이어 읽기). 실행에 필요한 `mineru` 패키지는 처음 쓸 때 설치. 텔레메트리는 `.claude/settings.json`의 `MINERU_TELEMETRY_DISABLED=1`로 끔 |

출처와 해시는 `skills-lock.json`에 있습니다. 갱신: `npx skills add <저장소> --skill <이름>`

huashu-design은 기존 스킬과 겹치는 모듈(웹·랜딩·대시보드, 앱 프로토타입 화면, 인포그래픽, 디자인 평가)과 데모·쇼케이스를 빼고 넣은 정리본이라 `skills-lock.json`에 넣지 않았습니다. `npx skills add`로 갱신하면 원본 전체가 다시 설치되므로, 갱신할 때는 원본을 받은 뒤 같은 모듈을 다시 빼야 합니다.

## 플러그인 (`.claude/settings.json`)

- 마켓플레이스: `anthropics/claude-plugins-official`, `epoko77-ai/im-not-ai`, `morluto/rea`
- code-review, code-simplifier, commit-commands, feature-dev, hookify, plugin-dev, pr-review-toolkit, security-guidance, skill-creator
- humanize-korean (한국어 AI 티 제거)
- rea (리버스 엔지니어링 MCP + 조사 스킬: 네이티브 바이너리, JS/Electron 앱, .NET, 웹사이트, Android 분석)

## MCP 서버 (`.mcp.json`)

| 서버 | 출처 | 용도 |
|---|---|---|
| chrome-devtools | ChromeDevTools/chrome-devtools-mcp | 브라우저 조작·스크린샷·콘솔/네트워크 확인·성능 트레이스·Lighthouse |

`scripts/chrome-devtools-mcp.sh`로 실행합니다. 로컬에서는 설치된 Chrome을 쓰고, 클라우드 세션에서는 내장 Chromium을 헤드리스로 띄웁니다.

## 원칙

기능이 겹치는 스킬·플러그인은 설치하지 않습니다.
