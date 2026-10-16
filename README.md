# brownbanana

Claude Code 세션 구성(스킬 + 플러그인)을 보관하는 저장소입니다. 이 저장소로 세션을 열면 아래 구성이 자동으로 적용됩니다.

## 스킬 (`.agents/skills/`, `.claude/skills/`는 심링크)

| 스킬 | 출처 | 용도 |
|---|---|---|
| frontend-design | anthropics/skills | UI 디자인 방향 가이드 |
| ui-ux-pro-max | nextlevelbuilder/ui-ux-pro-max-skill | 스타일·팔레트·폰트·UX 가이드 검색 DB |
| impeccable | pbakaus/impeccable | 기존 UI 진단·비평·다듬기 |
| canvas-design | anthropics/skills | 포스터·아트 PNG/PDF 제작 (한글 폰트 Pretendard, Noto Serif KR 추가) |

출처와 해시는 `skills-lock.json`에 있습니다. 갱신: `npx skills add <저장소> --skill <이름>`

## 플러그인 (`.claude/settings.json`)

- 마켓플레이스: `anthropics/claude-plugins-official`, `epoko77-ai/im-not-ai`
- code-review, code-simplifier, commit-commands, feature-dev, hookify, plugin-dev, pr-review-toolkit, security-guidance, skill-creator
- humanize-korean (한국어 AI 티 제거)

클라우드 세션은 위 플러그인을 스스로 설치하지 않으므로, `.claude/hooks/session-start.sh`(SessionStart 훅)가 세션 시작 때 `settings.json`의 마켓플레이스와 `enabledPlugins`를 읽어 빠진 것만 설치합니다. 플러그인을 추가·삭제할 때는 `settings.json`만 고치면 됩니다.

## 원칙

기능이 겹치는 스킬·플러그인은 설치하지 않습니다.
