개인 프로젝트를 조사해서 초안을 만들고, 사용자 승인 후 `tools/portfolio-upload/upload-project.mjs`로 Firestore/Storage에 등록하세요.

인자($ARGUMENTS)로 프로젝트 폴더 경로 또는 이름(예: `coupley`)이 주어집니다. 없으면 사용자에게 어떤 프로젝트인지 물어보세요.

## 0. 사전 점검

- `tools/portfolio-upload/.secrets 대신 portfolio/.secrets/service-account.json` 존재 여부를 확인하세요 (`../../.secrets/service-account.json`, 즉 portfolio 루트의 `.secrets/service-account.json`). 없으면 중단하고 Firebase 콘솔 > 프로젝트 설정 > 서비스 계정에서 키를 발급받아 그 경로에 저장하도록 안내하세요.
- `tools/portfolio-upload/node_modules`가 없으면 그 디렉토리에서 `npm install`을 실행하세요.

## 1. 프로젝트 조사

인자로 받은 이름/경로로 해당 프로젝트 폴더를 찾으세요 (예: `dev/app/coupley_dev/coupley`, `dev/app/copick` 등 — 정확한 경로를 모르면 `dev/app` 아래를 검색). 다음을 읽어 프로젝트를 파악하세요:

- `README.md` (있으면)
- `pubspec.yaml` (Flutter 프로젝트명, 설명)
- `git log --oneline -20` (개발 기간·주요 작업 추정)
- 스크린샷/이미지 폴더 (`docs/`, `screenshots/`, `assets/` 등)를 찾아보세요. 찾지 못하면 사용자에게 스크린샷 파일 경로를 요청하세요 — **이미지 없이는 등록할 수 없습니다** (`ProjectModel`은 최소 1장 필요).

기존 portfolio 프로젝트들의 톤을 참고하려면 `lib/data/models/project_model.dart`와 이미 등록된 프로젝트 예시(`tools/portfolio-upload/example-project.json`)를 확인하세요.

## 2. 초안 작성

다음 필드로 `tools/portfolio-upload/draft-<프로젝트명>.json`을 작성하세요 (이 draft 파일은 임시 산출물이므로 커밋 대상 아님):

- `eyebrow`: 예) "Personal Project"
- `title`: 프로젝트명
- `summary`: 2~3문장. `**bold**`, `[text](url)` 마크업 지원(StyledText 규칙과 동일)
- `isLandscape`: 모르면 `null` (스크립트가 첫 이미지로 자동감지)
- `order`: `null` (스크립트가 맨 끝에 자동 배치)
- `rows`: 기본 레이블 5개를 채우세요 — "소속 · 연계"(개인 프로젝트), "업무 기간", "플랫폼", "주요 기능", "기술 스택". 필요하면 행 추가 가능
- `stats`: 있으면 추가(다운로드 수 등), 없으면 빈 배열
- `images`: 로컬 이미지 파일의 절대경로 배열

## 3. 사용자 확인

작성한 초안 내용을 채팅에 요약해서 보여주고, 등록해도 될지 확인을 받으세요. 수정 요청이 있으면 반영 후 다시 확인받으세요. **승인 없이 4단계로 넘어가지 마세요.**

## 4. 검증 실행 (dry-run)

```
cd tools/portfolio-upload
node upload-project.mjs draft-<프로젝트명>.json --dry-run
```

출력된 업로드 계획(파일명, order, 방향 등)을 사용자에게 보여주고 문제없는지 재확인하세요.

## 5. 실제 업로드

```
node upload-project.mjs draft-<프로젝트명>.json
```

성공하면 Firestore 문서 ID와 확인 URL을 사용자에게 알려주세요. 실패하면 오류 메시지를 그대로 보여주고, 서비스 계정 키/이미지 경로 등 흔한 원인을 먼저 점검하세요.

## 6. 마무리

- draft json 파일은 삭제하지 말고 남겨두세요 (재실행/수정 참고용, gitignore 대상은 아니지만 커밋 여부는 사용자 판단에 맡기세요).
- 완료 후 "포트폴리오에 [프로젝트명] 등록 완료했습니다." 라고 답하세요.
