# HANDOFF.md — Portfolio (Flutter Web)

> 다음 Claude 에이전트를 위한 인계 문서.

## 브랜치 & 커밋 상태
- 현재 브랜치: `main`
- 미커밋 변경사항: clean
- 최근 커밋

| 해시 | 메시지 |
|------|--------|
| d9910d1 | chore: 재배포 트리거 (VERCEL_PROJECT_ID 시크릿 수정 후) |
| 01ad30b | chore: 재배포 트리거 (Vercel Git 연동 해제 후) |
| 81805c6 | chore: 재배포 트리거 (Vercel 프로젝트명 변경 후) |
| b7ed606 | chore: 배포 트리거 (이메일 설정 변경 후) |
| db2bedd | fix: dev_constants 커밋 추가 및 gitignore 제거 (빌드 실패 수정) |

## 완료된 작업 (전체)

### UI / 위젯
- **StyledText 위젯** (`lib/core/design/shared/styled_text.dart`): `**굵게**` / `[[초록+굵게]]` 인라인 마크업 파서 및 렌더러
- **MarkupTextField 위젯** (`lib/core/design/shared/markup_text_field.dart`): B / B(green) 툴바 버튼. 드래그 선택 후 버튼 클릭 시 selection이 풀리는 Flutter Web 버그 존재 (포기 결정)
- **ProjectCard 그린 배너 헤더**: eyebrow + title + summary를 초록 배경 헤더로 통합 (`SurfaceCard(padding: EdgeInsets.zero)`)
- **InfoRow**: `showDivider` 파라미터, 수직 패딩 11px, 라벨 초록 색상(`AppColors.green`) 적용
- **SurfaceCard**: `clipBehavior: Clip.antiAlias` 추가
- **LandscapeGallery**: 수직 나열 → PortraitGallery와 동일한 수평 슬라이딩 애니메이션 (280×498, 60px/s)
- **CareerCard**: bullets / role에 `StyledText` 적용
- **EditIntroDialog / EditProjectDialog / EditCareerDialog**: `MarkupTextField` 적용

### 관리자 / Firebase
- **Admin Debug 로그인**: `kDebugMode`에서 `dev_constants.dart`의 계정(`admin@admin.com` / `admin1234`)으로 자동 Firebase 로그인
- **main.dart**: EngineFlutterView disposed 오류 필터링 (debug 전용)

### 배포 인프라
- **GitHub Actions** (`.github/workflows/deploy.yml`): main 브랜치 push 시 Flutter 빌드 → Vercel CLI 자동 배포
- **루트 index.html 삭제**: 구 HTML 포트폴리오 파일이 Vercel에서 Flutter 대신 서빙되던 문제 수정
- **web/index.html**: 중복 viewport 메타 태그 제거

## 배포 구성 (현재 정상 동작)

| 항목 | 내용 |
|------|------|
| 배포 URL | `https://melkk-portfolio.vercel.app/` |
| 배포 방식 | GitHub Actions → Vercel CLI (`vercel build/web --prod`) |
| Vercel 프로젝트명 | `melkk-portfolio` (melkkdevs-projects 팀) |
| GitHub Secret | `VERCEL_TOKEN`, `VERCEL_PROJECT_ID`, `VERCEL_ORG_ID` |
| Vercel Git 연동 | **Disconnect 상태** (네이티브 자동빌드 비활성화) |
| git user.email | `melkk.dev@gmail.com` (커밋 이메일이 Vercel 계정과 일치해야 배포 허용) |

## 실패한 접근 방식 (재시도 금지)

| 시도 | 실패 이유 |
|------|-----------|
| `Listener.onPointerDown`으로 selection 저장 | Flutter Web에서 FocusManager가 같은 타이밍에 selection을 초기화함 |
| `Focus(canRequestFocus: false)`로 focus 탈취 방지 | Flutter Web Canvas 렌더러에서 효과 없음 |
| `_savedSel` + controller listener (non-collapsed만 저장) | 포커스 손실 시점에 이미 selection이 collapsed로 변경됨 |
| `GestureDetector.onTapDown`으로 wrap 실행 | Flutter Web에서 FocusManager보다 늦게 실행됨 |
| Firebase 익명 로그인으로 debug 진입 | Firebase Console에서 익명 인증이 비활성화되어 있어 Firestore 권한 오류 |
| `flutter_quill` 사용 | Delta ↔ 마크업 변환 복잡성으로 사용자가 포기 선택 |
| Vercel Deployment Protection 끄기 | 이미 꺼져 있었음. 실제 원인은 커밋 이메일 불일치 |
| Vercel 네이티브 Git 연동 + GitHub Actions CLI 동시 사용 | 네이티브 연동이 빈 Flutter 빌드를 덮어써서 NOT_FOUND 발생 |
| GitHub Secret VERCEL_PROJECT_ID 구버전 유지 | 프로젝트 rename 후 project.json이 삭제된 프로젝트 ID를 가리켜 `web` 프로젝트로 오배포 |
| Vercel 도메인에 오타 (`melkk-portfoilo`) | `melkk-portfolio`와 달라서 404 발생 |

## Vercel 배포 트러블슈팅 (이번 세션에서 해결한 문제들)

1. **Deployment Blocked**: 커밋 이메일(`dltkdalsdla@gmail.com`)이 Vercel 계정과 불일치 → `git config user.email`을 `melkk.dev@gmail.com`으로 변경 후 재커밋
2. **도메인 오타**: Vercel 도메인이 `melkk-portfoilo.vercel.app`으로 잘못 등록 → 삭제 후 `melkk-portfolio.vercel.app`으로 재등록
3. **프로젝트명 충돌**: `melkk-portfolio.vercel.app`이 다른 프로젝트에 점유됨 → Vercel 프로젝트명을 `melkk-portfolio`로 변경
4. **네이티브 Git 연동 충돌**: Vercel이 Flutter 프로젝트를 직접 빌드해 빈 결과물 배포 → Vercel Settings → Git → **Disconnect** (GitHub Actions CLI 단독 배포로 전환)
5. **VERCEL_PROJECT_ID 불일치**: Secret이 구버전 프로젝트 ID를 가리켜 `web` 프로젝트로 오배포 → Secret을 `melkk-portfolio` 프로젝트 ID로 업데이트

## 남은 TODO

- [ ] `MarkupTextField` 드래그 선택 후 버튼 클릭 시 selection 유지 문제 (`flutter_quill` 등 외부 패키지 대체 검토)
- [ ] Firebase Console에서 `admin@admin.com` 계정 생성 확인 (debug 로그인용)
- [ ] 기술 스택 섹션 등 다른 곳에 StyledText 추가 적용 검토

## 핵심 아키텍처 결정사항

- **마크업 형식**: `**텍스트**` = 굵게, `[[텍스트]]` = 굵게+초록. `[[**텍스트**]]` 사용 시 `**`는 자동 제거됨
- **이미지 저장**: Firebase Storage (`images/` 경로). 모델에는 파일명만 저장, URL은 getter로 생성
- **Vercel 배포**: `build/web/.vercel/project.json`을 GitHub Actions에서 동적 생성 후 `vercel` CLI로 배포. Vercel 네이티브 Git 연동은 반드시 Disconnect 상태 유지
- **Vercel 프로젝트**: `melkk-portfolio` (melkkdevs-projects 팀). projectId/orgId는 GitHub Secret에 저장

## 주요 파일 위치

| 파일 | 역할 |
|------|------|
| `lib/core/design/shared/styled_text.dart` | 인라인 마크업 렌더러 |
| `lib/core/design/shared/markup_text_field.dart` | B/B(green) 툴바 텍스트 에디터 |
| `lib/core/design/shared/info_row.dart` | 프로젝트 상세 정보 행 |
| `lib/core/design/cards/surface_card.dart` | 카드 컨테이너 |
| `lib/features/projects/widgets/project_card.dart` | 프로젝트 카드 (그린 배너 헤더) |
| `lib/features/projects/widgets/desktop_gallery.dart` | 가로 이미지 슬라이딩 갤러리 |
| `lib/features/projects/widgets/phone_gallery.dart` | 세로 이미지 슬라이딩 갤러리 |
| `lib/features/admin/widgets/login_dialog.dart` | 관리자 로그인 (debug 자동 로그인 포함) |
| `lib/core/constants/dev_constants.dart` | debug 로그인용 계정 상수 |
| `.github/workflows/deploy.yml` | GitHub Actions Vercel 자동 배포 |
| `lib/data/repository/portfolio_repository.dart` | Firestore CRUD |
