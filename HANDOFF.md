# HANDOFF.md — Flutter Web Portfolio

> 다음 Claude 에이전트를 위한 인계 문서. 인간이 아닌 AI가 읽는다고 가정하고 작성됨.

---

## 브랜치 상태

- **현재 브랜치**: `feature/firestore-text-data`
- **작업 기준 브랜치**: `main` (병합 전)
- **워킹트리**: clean (미커밋 없음) ← 커밋 필요

### 커밋 히스토리 (최신순)

| 해시 | 내용 |
|------|------|
| `98dc738` | fix: 이미지 교체 시 가로/세로형 항상 재감지 |
| `e47f6a2` | feat: 드래그 순서 실시간 반영 + 이미지 방향 자동 감지 |
| `eacb468` | fix: EngineFlutterView 오류, 고정 행 잠금, 내용 없음 표시, 회사명 수정 |
| `ce35b72` | feat: admin mode CRUD + order management via drag & drop |
| `8d8dc4d` | feat: Firebase 연동 및 PhoneGallery 애니메이션 구현 |
| `31e2f68` | feat: Flutter web portfolio 초기 구현 |
| `091935e` | init: add portfolio HTML |

---

## 프로젝트 개요

Flutter web 포트폴리오 사이트. 정적 HTML에서 Flutter로 전환, Firebase 백엔드 연동.

- **Flutter**: 3.29.3 / Dart 3.7.2
- **패키지**: `firebase_core ^3.13.1`, `cloud_firestore ^5.6.7`, `firebase_storage ^12.4.5`, `firebase_auth ^5.3.1`, `file_picker ^8.1.2`
- **Firebase 프로젝트**: `melkk-dev`
- **Storage 버킷**: `melkk-dev.firebasestorage.app`
- **이미지 URL 패턴**: `https://firebasestorage.googleapis.com/v0/b/melkk-dev.firebasestorage.app/o/images%2F{filename}?alt=media`
- **Firestore 규칙**: `read: if true; write: if request.auth != null`

---

## 아키텍처 핵심

### 상태 관리 레이어

```
PortfolioApp (StatefulWidget)
  └─ AdminScope (InheritedNotifier<AdminNotifier>)      ← 관리자 모드 상태
       └─ PortfolioScope (InheritedWidget)               ← 포트폴리오 데이터
            └─ MaterialApp → PortfolioPage
```

- `AdminNotifier` — `isAdmin`, `pendingOrderIds` 보유. `exit()` 호출 시 `_handleAdminExit` 콜백 실행 (순서 WriteBatch 저장 후 signOut)
- `PortfolioScope` — `data: PortfolioState`, `onReload: Future<void> Function()` 보유. `reloadOf(context)` = reload 콜백 getter
- `_PortfolioAppState._reload()` — Firestore 재조회 후 setState

### Firestore 구조

```
portfolio/
  profile          → ProfileModel
  intro            → { paragraphs: List<String> }
  skills           → { groups: List }
  careers          → { items: List }
  projects/items/
    project_0      → ProjectModel (imageFilenames, rows, stats, order, isLandscape, ...)
    project_1      → ...
```

### 이미지 저장 방식

- Firestore에는 **파일명만** 저장: `imageFilenames: ['project_0_1.jpg', ...]`
- URL은 런타임에 `buildImageUrl(filename)` 으로 조합
- 업로드 시 파일명 자동생성 규칙: `project_{order}_{imageIndex+1}.{ext}`
- 구버전 `imageUrls` 포맷 → `fromMap`에서 regex로 파일명 추출하여 마이그레이션

---

## 완료된 기능

### 1. Flutter Web 포트폴리오 UI (커밋 `31e2f68`)
- Hero / Intro / Skills / Career / Projects 5개 섹션
- `PhoneMockup` + `LandscapeGallery` 컴포넌트
- `AnimationController` + `Transform.translate` + `OverflowBox` 무한 스크롤

### 2. Firebase 연동 (커밋 `8d8dc4d`)
- Firestore에서 모든 텍스트 데이터 로딩
- `PortfolioState.load()` → 5개 collection 병렬 조회
- `imageFilenames` 모델로 마이그레이션 (구버전 `imageUrls` 자동 변환)

### 3. 관리자 모드 (커밋 `ce35b72`)
- Firebase Auth 로그인 → `AdminScope.enter()`
- **프로필/인트로 편집**: `EditProfileDialog`, `EditIntroDialog`
- **프로젝트 추가/수정/삭제**: `EditProjectDialog`
  - `file_picker`로 이미지 선택 → Firebase Storage 업로드
  - `imageFilenames` Firestore 저장
  - 기본 5개 행 (소속·연계, 업무 기간, 플랫폼, 주요 기능, 기술 스택) `isFixed: true`로 잠금
- **순서 관리**: `ProjectReorderPanel` (우측 고정 패널, `ReorderableListView`)
  - 드래그 → `AdminNotifier.updateOrder()` 메모리 저장
  - 관리자 모드 종료 시 `WriteBatch`로 일괄 저장
- **바리어 클릭 방지**: 모든 편집 다이얼로그 `barrierDismissible: false`

### 4. 버그 픽스 및 개선 (커밋 `eacb468`, `e47f6a2`, `98dc738`)
- `PortraitGallery` EngineFlutterView 오류: `deactivate()`에서 `_controller.stop()` + `addPostFrameCallback`으로 루프 시작 지연
- `PortraitGallery.didUpdateWidget`: 이미지 개수 변경 시 `_controller.duration` 갱신
- `InfoRow`: 내용(value)이 비면 이탤릭 "없음" 표시 (레이블 기준 X)
- 이미지 방향 자동 감지: `dart:ui.instantiateImageCodec`으로 width/height 비교, 항상 재감지
- `isDesktop` → `isLandscape` 리네임 (fromMap에서 구버전 `isDesktop` 필드도 마이그레이션)
- 갤러리 클래스 리네임: `DesktopGallery` → `LandscapeGallery`, `PhoneGallery` → `PortraitGallery`
- 드래그 순서 변경이 본 화면에 즉시 반영 (`AdminNotifier.updateOrder` → `notifyListeners` → `ProjectsSection` 재빌드)
- `AdminFab`: `StatefulWidget`으로 전환, 종료 중 스피너 + 버튼 비활성화
- `AdminBanner`: 회사명 마이그레이션 버튼 추가 (`fixCompanyName()` 트리거)

---

## 현재 알려진 미완성 사항 / TODO

### 즉시 해결 필요

1. **Firestore 실데이터 회사명 수정**
   - 관리자 모드 진입 → 상단 배너의 **"Poien→fouren 수정"** 버튼 클릭으로 해결 가능
   - `PortfolioRepository.fixCompanyName()` 이 영향받은 문서만 `rows` 필드 업데이트

2. **`main` 브랜치 병합 미완료**
   - `feature/firestore-text-data` → `main` PR/merge 아직 안 함
   - `git checkout main && git merge feature/firestore-text-data` 실행 필요

### 장기 개선 사항

3. **`EditProjectDialog` 이미지 순서 변경 불가**
   - 기존 이미지를 드래그로 순서 바꾸는 기능 없음
   - 현재는 삭제 후 재업로드해야 함
   - 구현 시: `ReorderableListView` + 이미지 썸네일 + `_filenames` 리스트 재정렬

---

## 핵심 파일 맵

```
lib/
  app/
    app.dart                     # _PortfolioAppState, _handleAdminExit(WriteBatch 순서저장)
  core/
    design/shared/info_row.dart  # value 비면 "없음" (이탤릭)
    theme/app_theme.dart         # AppColors, AppTheme
    common/spacing.dart          # Spacing 상수
  data/
    models/
      project_model.dart         # imageFilenames, imageUrls getter, copyWith(order), isLandscape
      profile_model.dart         # toMap() 포함
    portfolio_scope.dart         # InheritedWidget + reloadOf()
    portfolio_state.dart         # 전체 데이터 holder
    repository/
      portfolio_repository.dart  # saveProject / saveProjects(batch) / deleteProject / fixCompanyName()
    seed/seed_firestore.dart     # 초기 데이터 (회사명 수정됨)
  features/
    admin/
      admin_scope.dart           # AdminNotifier(onExit) + AdminScope
      admin_service.dart         # Firebase Auth signIn/signOut
      widgets/
        admin_banner.dart        # 상단 배너 + 회사명 마이그레이션 버튼 (StatefulWidget)
        admin_fab.dart           # 잠금버튼 / "종료" FAB (StatefulWidget, 로딩 스피너)
        edit_profile_dialog.dart # barrierDismissible: false
        edit_intro_dialog.dart   # barrierDismissible: false
        edit_project_dialog.dart # isFixed 행, 파일명 자동생성, 방향 자동감지, barrierDismissible: false
        login_dialog.dart        # barrierDismissible: false
        project_reorder_panel.dart # ReorderableListView, updateOrder()
    home/portfolio_page.dart     # Stack + Positioned(reorder panel)
    projects/widgets/
      desktop_gallery.dart       # LandscapeGallery (가로형 이미지)
      phone_gallery.dart         # PortraitGallery (세로형 이미지, didUpdateWidget 포함)
      project_card.dart          # 편집/삭제 버튼 (isAdmin)
      projects_section.dart      # 프로젝트 추가 버튼 (isAdmin) + pendingIds 실시간 반영
```

---

## 실패한 접근 방식 (재시도 금지)

| 시도 | 실패 이유 |
|------|-----------|
| `ScrollController` + `Timer` + `jumpTo()` 무한스크롤 | Flutter web에서 scroll layout이 매 프레임 재계산되어 "disposed EngineFlutterView" 크래시 |
| `SingleChildScrollView` + `NeverScrollableScrollPhysics` + `jumpTo()` | `NeverScrollableScrollPhysics`가 `jumpTo()` 차단 |
| `AnimationController.repeat()` in `initState` (deactivate 없음) | hot reload 시 dispose 후에도 pending 프레임이 발생해 EngineFlutterView 오류 |
| 편집 다이얼로그에서 순서 변경 + saveProjects (매 저장마다) | 사용자 요청으로 "모드 종료 시 일괄 저장"으로 변경 |
| `generateProjectId()` async (Firestore 쿼리로 다음 번호 계산) | 동시성 문제 가능성 + 불필요한 읽기 → sync timestamp 방식으로 교체 |
| `_pickFiles`에서 `_isLandscape == null` 조건 확인 후 감지 | 기존 프로젝트는 이미 `_isLandscape` 값이 있어 조건 false → 항상 재감지로 변경 |

---

## 환경 정보

- **OS**: Windows 11 Pro
- **Shell**: PowerShell (primary) + Bash (Git Bash)
- **Firebase 사용자**: `dltkdalsdla@gmail.com`
- **Git 사용자**: `melkkdev`
- **작업 디렉토리**: `c:\Users\tkdals\dev\app\portfolio`
