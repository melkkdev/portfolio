# HANDOFF.md — Portfolio (Flutter Web)

> 다음 Claude 에이전트를 위한 인계 문서.

## 브랜치 & 커밋 상태
- 현재 브랜치: `main`
- 미커밋 변경사항: `devtools_options.yaml` (untracked, 무해한 IDE 설정 파일 — 신경 쓰지 않아도 됨)
- 최근 커밋 5개:

| hash | message |
|------|---------|
| 8aecaaa | security: dev_constants.dart 추적 해제 + gitignore 추가 |
| 92a7203 | fix: PDF 미리보기 DataCloneError 수정 (ArrayBuffer detach) |
| 0b9b955 | ci: Flutter 버전 3.29.3 → 3.44.2로 올리기 |
| 881de18 | feat: 포트폴리오 PDF 다운로드 기능 추가 및 버그 수정 |
| 4da4e38 | docs: HANDOFF.md 업데이트 (이미지 뷰어/GitHub 링크 기능 반영) |

> ⚠️ `8aecaaa` 이전 이력은 **`git-filter-repo`로 재작성되어 GitHub에 force-push된 상태**입니다 (아래 참고). 로컬에 이 저장소를 이미 클론해둔 다른 환경이 있다면 반드시 새로 clone 받아야 합니다 (fetch/merge/rebase로는 정합이 안 맞음).

## 이번 세션에서 완료된 작업

### 1. 개인 프로젝트 → 포트폴리오 자동 업로드 도구 구축
브라우저 로그인 없이 CLI 한 번으로 개인 프로젝트를 포트폴리오 Firestore/Storage에 등록할 수 있도록 구축했습니다.

- **`tools/portfolio-upload/upload-project.mjs`**: Node.js CLI (`firebase-admin` 사용). JSON 스펙을 읽어서
  - 이미지들을 Firebase Storage `images/`에 업로드 (파일명은 `project_{order}_{i}.{ext}` 규칙으로 `ProjectModel`과 동일하게 자동 생성)
  - 첫 이미지 크기로 `isLandscape` 자동 감지(`image-size` 패키지, 미지정 시)
  - Firestore `portfolio/projects/items/{id}`에 문서 write (`ProjectModel.toMap()`과 완전히 동일한 스키마)
  - `--dry-run` 플래그로 실제 업로드 없이 계획만 미리보기 가능
  - `id`/`order`를 JSON에 명시하면 **기존 문서 수정(덮어쓰기)**, 비우면(`null`) 새 프로젝트로 맨 끝에 추가
- **`tools/portfolio-upload/example-project.json`**: 입력 JSON 형식 예시
- **`.claude/commands/portfolio-add.md`**: `/portfolio-add <프로젝트명>` 슬래시커맨드. 프로젝트 폴더(README/git log/스크린샷) 조사 → 초안 작성 → 사용자 확인 → dry-run → 실제 업로드까지 자동 진행하는 워크플로 정의
- 의존성 설치 완료 (`tools/portfolio-upload/node_modules`), `package-lock.json` 커밋됨

**사전 준비물 (완료됨)**: Firebase 서비스 계정 키를 `portfolio/.secrets/service-account.json`에 저장함 (`.gitignore` 처리, git에는 없음). **이 키는 로컬에만 있고 재발급 전까지 이 컴퓨터가 아니면 도구가 동작하지 않음.**

### 2. Coupley 프로젝트를 포트폴리오에 실제 등록
- 조사: `dev/app/coupley_dev/coupley` — README, git log(2026-06-12~06-27 개발), `docs/screenshots/`의 스크린샷 10장 중 8장 선정
- Firestore 문서: `portfolio/projects/items/project_1788348737981` (order=6, 세로형/Phone)
- rows 6개: 소속·연계 / 업무 기간 / 플랫폼 / 주요 기능 / 기술 스택 / **GitHub(→ https://github.com/melkkdev/coupley)**
- 이미지 8장 → Storage `images/project_6_1.png` ~ `project_6_8.png`
- 사용한 draft 파일: `tools/portfolio-upload/draft-coupley.json` (재실행 시 `id`/`order` 그대로 두면 같은 문서를 계속 수정 가능)

### 3. 보안 사고 발견 및 조치 — 관리자 계정 정보 git 이력 노출
관리자 로그인 계정을 확인하던 중, `lib/core/constants/dev_constants.dart`(email: `admin@admin.com`, password: `admin1234`)가 과거 커밋(`db2bedd: "dev_constants 커밋 추가 및 gitignore 제거"`)에서 `.gitignore`가 제거되며 **public 저장소(`melkkdev/portfolio`)에 평문으로 커밋되어 있던 것**을 발견, 다음과 같이 조치했습니다.

1. 파일을 다시 git 추적에서 해제(`git rm --cached`)하고 `.gitignore`에 재등록 (커밋 `8aecaaa`) — 워킹 디렉토리 파일 자체는 유지되어 `kDevAdminEmail`/`kDevAdminPassword` 참조 코드는 정상 컴파일됨
2. `git-filter-repo --path lib/core/constants/dev_constants.dart --invert-paths --force`로 **전체 커밋 이력에서 파일을 완전히 제거** (filter-repo가 안전장치로 `origin` remote를 자동 삭제 → 재등록함)
3. `git push --force origin main`으로 GitHub에 재작성된 이력 반영, 원격에서도 해당 파일 이력이 사라진 것 확인 완료

## 현재 진행 중이던 작업
없음 — 위 3가지 작업 모두 완료된 상태에서 세션 종료.

## 실패한 접근 방식 (재시도 금지)

| 시도 | 실패 이유 |
|------|-----------|
| `pip install git-filter-repo`로 실행 스크립트(`git-filter-repo.exe`) 설치 | Scripts 폴더 쓰기 권한 문제로 실패(WinError 2). 대신 `python C:/Python312/Lib/site-packages/git_filter_repo.py <args>`로 직접 실행하면 정상 동작함 |
| Claude가 직접 `git push --force` 실행 | 자동 승인 분류기가 force-push를 파괴적 작업으로 차단. 사용자가 `!` 프리픽스로 직접 실행해야 함 (`git filter-repo` 실행도 최초 1회는 같은 이유로 차단되어 사용자 재승인 필요했음) |

## 남은 TODO

### 즉시 해결 필요
- [ ] **Firebase 콘솔에서 `admin@admin.com` 비밀번호 변경**. git 이력에서 지워도 이미 유출됐던 비밀번호 자체는 무효화되지 않음 (GitHub 캐시나 이미 받아간 클론에 남아있을 수 있음). 변경 후 로컬 `lib/core/constants/dev_constants.dart`의 `kDevAdminPassword`도 새 값으로 갱신할 것 (그래야 관리자 로그인 다이얼로그의 "Debug 진입" 버튼이 계속 동작함)

### 나중에 해도 되는 것
- [ ] favicon 변경/디자인 — ImageMagick/Inkscape/PIL 미설치 상태로 이전 세션부터 보류 중. 위치: `web/favicon.png`, `web/icons/`
- [ ] (선택) copick, agrodoctor 등 다른 회사 프로젝트도 `/portfolio-add`로 재정비하고 싶다면, 이미 등록된 기존 항목은 Firestore 콘솔이나 admin UI에서 문서 ID 확인 후 `id`/`order`를 지정한 draft json으로 수정 가능
- [ ] (선택) admin 전체 플로우 회귀 테스트

## 핵심 아키텍처 결정사항

- **포트폴리오 자동 업로드는 "반자동"으로 설계함**: Claude가 프로젝트 조사 + 초안 작성까지는 하지만, 실제 Firestore/Storage 쓰기 전 항상 사용자 확인(`--dry-run` 결과 리뷰)을 거치도록 슬래시커맨드에 명시함. 실제 서비스 데이터를 확인 없이 덮어쓰는 완전자동화는 위험하다고 판단해 배제.
- **서비스 계정 키는 로컬 전용, git에 절대 포함하지 않음** (`portfolio/.secrets/`, `.gitignore` 처리). 이 컴퓨터를 벗어나면 도구가 동작하지 않으므로, 다른 환경에서 쓰려면 Firebase 콘솔에서 키를 다시 발급받아 같은 경로에 저장해야 함.
- **git 이력 재작성(filter-repo)은 개인 저장소(단독 작업자, 협업자 없음)라서 감행함.** 여러 명이 clone해서 쓰는 저장소였다면 force-push 후 전원이 재클론해야 하는 부담이 있어 신중히 판단할 것.

## 주요 파일 위치

| 파일 | 역할 |
|------|------|
| `tools/portfolio-upload/upload-project.mjs` | 개인 프로젝트 → Firestore/Storage 업로드 CLI |
| `tools/portfolio-upload/example-project.json` | 업로드 JSON 스펙 예시 |
| `tools/portfolio-upload/draft-coupley.json` | coupley 등록에 실제 사용한 스펙 (재수정 시 참고/재사용) |
| `.claude/commands/portfolio-add.md` | `/portfolio-add` 슬래시커맨드 정의 |
| `.secrets/service-account.json` | Firebase 서비스 계정 키 (git 미포함, 로컬 전용) |
| `lib/data/models/project_model.dart` | `ProjectModel` 스키마 — 업로드 스크립트와 필드 반드시 동기화 |
| `lib/data/repository/portfolio_repository.dart` | Firestore 경로(`portfolio/projects/items`) 정의 |
| `lib/features/admin/widgets/login_dialog.dart` | 관리자 로그인 UI, `kDevAdminEmail`/`kDevAdminPassword` 사용(Debug 모드 전용) |
| `lib/core/constants/dev_constants.dart` | 관리자 계정 정보 — **반드시 gitignore 상태 유지, 커밋 금지** |
