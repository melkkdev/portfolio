# HANDOFF.md — Portfolio (Flutter Web)

> 다음 Claude 에이전트를 위한 인계 문서.

## 브랜치 & 커밋 상태
- 현재 브랜치: `main`
- 미커밋 변경사항: clean
- 최근 커밋

| 해시 | 메시지 |
|------|--------|
| db2bedd | fix: dev_constants 커밋 추가 및 gitignore 제거 (빌드 실패 수정) |
| 127dfea | feat: UI 개선 및 관리자 기능 강화 |
| 6ddad06 | chore: 불필요한 파일 정리 |
| e59c77f | fix: 폰트 경고 해결 및 index.html 정리 |
| ce6cef5 | feat: 프로필 히어로 이미지 Firebase Storage 업로드 방식으로 전환 |

## 이번 세션에서 완료된 작업

- **StyledText 위젯** (`lib/core/design/shared/styled_text.dart`): `**굵게**` / `[[초록+굵게]]` 인라인 마크업 파서 및 렌더러
- **MarkupTextField 위젯** (`lib/core/design/shared/markup_text_field.dart`): B / B(green) 툴바 버튼이 있는 서식 입력 필드. 드래그 선택 후 버튼 클릭 시 selection이 풀리는 Flutter Web 버그 있음 (onTapDown 방식 사용 중이나 완전히 해결되지 않음)
- **ProjectCard 그린 배너 헤더**: eyebrow + title + summary를 초록 배경 헤더로 통합 (`SurfaceCard(padding: EdgeInsets.zero)`)
- **InfoRow**: `showDivider` 파라미터, 수직 패딩 11px, 라벨 초록 색상(`AppColors.green`) 적용
- **SurfaceCard**: `clipBehavior: Clip.antiAlias` 추가
- **LandscapeGallery**: 수직 나열 → PortraitGallery와 동일한 수평 슬라이딩 애니메이션 (280×498, 60px/s)
- **CareerCard**: bullets / role에 `StyledText` 적용
- **EditIntroDialog / EditProjectDialog / EditCareerDialog**: `MarkupTextField` 적용 (요약, 행 내용, 직책/역할, 업무 내용)
- **Admin Debug 로그인**: `kDebugMode`에서 `dev_constants.dart`의 계정(`admin@admin.com` / `admin1234`)으로 자동 Firebase 로그인
- **GitHub Actions** (`.github/workflows/deploy.yml`): main 브랜치 push 시 Flutter 빌드 → Vercel 자동 배포
- **루트 index.html 삭제**: 구 HTML 포트폴리오 파일이 Vercel에서 Flutter 대신 서빙되던 문제 수정
- **web/index.html**: 중복 viewport 메타 태그 제거
- **main.dart**: EngineFlutterView disposed 오류 필터링 (debug 전용)

## 현재 진행 중이던 작업

GitHub Actions로 Vercel 자동 배포 진행 중 (워크플로우 #2 실행 중, 첫 빌드라 15~20분 소요 예상)

## 실패한 접근 방식 (재시도 금지)

| 시도 | 실패 이유 |
|------|-----------|
| `Listener.onPointerDown`으로 selection 저장 | Flutter Web에서 FocusManager가 같은 타이밍에 selection을 초기화함 |
| `Focus(canRequestFocus: false)`로 focus 탈취 방지 | Flutter Web Canvas 렌더러에서 효과 없음 |
| `_savedSel` + controller listener (non-collapsed만 저장) | 포커스 손실 시점에 이미 selection이 collapsed로 변경됨 |
| `GestureDetector.onTapDown`으로 wrap 실행 | Flutter Web에서 FocusManager보다 늦게 실행됨 |
| Firebase 익명 로그인으로 debug 진입 | Firebase Console에서 익명 인증이 비활성화되어 있어 Firestore 권한 오류 |
| `flutter_quill` 사용 | Delta ↔ 마크업 변환 복잡성으로 사용자가 포기 선택 |

## 남은 TODO

### 즉시 해결 필요
- 없음

### 나중에 해도 되는 것
- [ ] `MarkupTextField` 드래그 선택 후 버튼 클릭 시 selection 유지 문제 (`flutter_quill` 등 외부 패키지 대체 검토)
- [ ] Firebase Console에서 `admin@admin.com` 계정 생성 확인 (debug 로그인용)
- [ ] 기술 스택 섹션 등 다른 곳에 StyledText 추가 적용 검토

## 핵심 아키텍처 결정사항

- **마크업 형식**: `**텍스트**` = 굵게, `[[텍스트]]` = 굵게+초록. `[[**텍스트**]]` 사용 시 `**`는 자동 제거됨
- **이미지 저장**: Firebase Storage (`images/` 경로). 모델에는 파일명만 저장, URL은 getter로 생성
- **Vercel 배포**: `build/web/.vercel/project.json`을 GitHub Actions에서 동적 생성 후 `vercel` CLI로 배포
- **Vercel 프로젝트**: project name "web", projectId/orgId는 GitHub Secret에 저장

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
