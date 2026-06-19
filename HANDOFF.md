# HANDOFF.md — Portfolio (Flutter Web)

> 다음 Claude 에이전트를 위한 인계 문서.

## 프로젝트 경로

`C:\Users\tkdals\dev\app\portfolio`

## 현재 상태

상태관리를 손으로 만든 InheritedWidget(`PortfolioScope`)/`InheritedNotifier`(`AdminScope`)에서 **Riverpod codegen(`@riverpod`)으로 마이그레이션 완료**. `flutter analyze` 0 issues, `flutter run -d chrome`로 실제 실행하여 전체 섹션이 Firestore 데이터로 정상 렌더링되는 것을 스크린샷으로 확인. **단, admin 로그인 → 편집 다이얼로그 저장 → 드래그 재정렬 → 로그아웃까지의 인터랙션 흐름은 클릭 단위로 직접 테스트하지 않았음** — 다음 세션 또는 사용자가 수동 확인 필요. 변경사항은 아직 커밋되지 않은 상태(unstaged).

## 구현된 파일 (이번 세션 변경분)

### 신규

| 파일 | 역할 |
|------|------|
| `lib/data/portfolio_provider.dart` | `@Riverpod(keepAlive: true) class Portfolio extends _$Portfolio` — `build()`에서 `PortfolioState.load()` 호출, `reload()` 메서드 제공 (state를 AsyncLoading으로 바꾸지 않아 리로드 시 화면 깜빡임 없음). 생성 provider: `portfolioProvider` |
| `lib/features/admin/admin_provider.dart` | `AdminUiState`(isAdmin, pendingOrderIds) + `@Riverpod(keepAlive: true) class Admin extends _$Admin` — `enter()`/`exit()`/`updateOrder()`. `exit()`이 기존 `app.dart`의 `_handleAdminExit` 로직(드래그 재정렬 저장 + reload)을 `ref`를 통해 직접 흡수. 생성 provider: `adminProvider` |
| `lib/data/portfolio_provider.g.dart`, `lib/features/admin/admin_provider.g.dart` | build_runner 생성 코드 (수동 수정 금지, 변경 시 재생성 필요) |

### 삭제

- `lib/data/portfolio_scope.dart` (PortfolioScope InheritedWidget)
- `lib/features/admin/admin_scope.dart` (AdminNotifier + AdminScope InheritedNotifier)

### 수정 (StatelessWidget/StatefulWidget → ConsumerWidget/ConsumerStatefulWidget 전환)

`lib/main.dart`(ProviderScope 적용), `lib/app/app.dart`(`PortfolioApp`을 ConsumerWidget으로, `AsyncValue.when`으로 loading/error/data 분기), `lib/features/hero/widgets/hero_section.dart`, `lib/features/intro/widgets/intro_section.dart`, `lib/features/skills/widgets/skills_section.dart`, `lib/features/career/widgets/career_section.dart`, `lib/features/projects/widgets/projects_section.dart`, `lib/features/projects/widgets/project_card.dart`, `lib/features/admin/widgets/admin_banner.dart`, `lib/features/admin/widgets/admin_fab.dart`, `lib/features/admin/widgets/login_dialog.dart`, `lib/features/admin/widgets/project_reorder_panel.dart`(가장 복잡 — `didChangeDependencies` 동기화 로직을 `ref.listen`으로 재구현)

### 무수정 (의도적)

`lib/data/portfolio_state.dart`, `lib/data/repository/portfolio_repository.dart`, `lib/features/admin/admin_service.dart`, 편집 다이얼로그 5개(`edit_profile_dialog.dart`, `edit_intro_dialog.dart`, `edit_skills_dialog.dart`, `edit_career_dialog.dart`, `edit_project_dialog.dart`) — `onSaved` 콜백 시그니처(`Future<void> Function()`)가 그대로 유지되어 호출부(`ref.read(portfolioProvider.notifier).reload`)만 바뀌고 다이얼로그 자체는 손대지 않음.

## 설치된 패키지 (pubspec.yaml 기준)

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  firebase_core: ^3.13.1
  cloud_firestore: ^5.6.7
  firebase_storage: ^12.4.5
  firebase_auth: ^5.3.1
  google_fonts: ^6.3.2
  url_launcher: ^6.3.2
  cached_network_image: ^3.4.1
  file_picker: ^8.1.2
  cupertino_icons: ^1.0.8

dev_dependencies:
  riverpod_generator: ^2.6.3
  build_runner: ^2.4.13
  flutter_lints: ^5.0.0
```

**⚠️ 버전 고정 이유**: `flutter pub add`가 처음 최신 Riverpod 3.3.2를 자동 설치했으나, 설치된 Dart SDK가 3.7.2(Flutter 3.29.3, 2025-04 릴리스 — 1년 넘게 미업그레이드)라 최신 `riverpod_generator`(analyzer ^8.2.0 이상 요구 → Dart SDK ^3.9.0 필요)와 충돌. 전역 Flutter SDK를 업그레이드하는 대신 **이 프로젝트 범위 내에서** 호환되는 2.6.x 라인으로 고정해 해결함. Flutter를 업그레이드하면 3.x 라인으로 다시 올릴 수 있지만, 다른 프로젝트에도 영향을 주는 전역 작업이라 사용자 확인 없이는 진행하지 않았음.

## 차단 이슈

없음 (analyze 통과, 실행 확인됨). 다만 아래 "다음 구현할 기능" 참고.

## 다음 구현할 기능 (체크리스트)

- [x] Riverpod codegen 마이그레이션 (provider 작성, 위젯 전환, 구 파일 삭제)
- [x] `flutter analyze` 통과 확인
- [x] `flutter run -d chrome` 실행 + 스크린샷으로 초기 렌더 확인
- [ ] **admin 로그인 → 편집 다이얼로그(프로필/인트로/스킬/경력/프로젝트) 저장 → 화면 갱신** 수동 클릭 테스트
- [ ] **프로젝트 드래그 재정렬 → admin 종료 → Firestore에 순서 저장되고 재로드 후에도 유지** 수동 테스트 (`project_reorder_panel.dart`가 가장 손이 많이 간 파일이라 우선 확인 권장)
- [ ] 로그아웃 후 일반 화면 복귀 확인
- [ ] 변경사항 git commit (현재 unstaged 상태)
- [ ] (선택) Flutter SDK 업그레이드 후 Riverpod 3.x로 재마이그레이션 — 지금은 보류 상태

## 핵심 코드 패턴

- **Provider 접근 패턴**: 기존 `PortfolioScope.of(context).X` → `ref.watch(portfolioProvider).requireValue.X` / `PortfolioScope.reloadOf(context)` → `ref.read(portfolioProvider.notifier).reload` / `AdminScope.isAdmin(context)` → `ref.watch(adminProvider.select((s) => s.isAdmin))` / `AdminScope.of(context)`(전체 notifier 필요 시) → `ref.watch(adminProvider)`
- **reload()는 AsyncLoading을 거치지 않음**: `state = await AsyncValue.guard(() => PortfolioState.load());` — 새 데이터가 준비될 때까지 기존 데이터를 유지해 화면 깜빡임이 없음. 이 패턴을 깨지 않도록 주의.
- **AdminNotifier의 exit()이 ref로 다른 provider를 직접 조작**: `ref.read(portfolioProvider).value?.projects`로 현재 프로젝트 목록을 읽고, `PortfolioRepository.saveProjects()` 저장 후 `ref.read(portfolioProvider.notifier).reload()` 호출 — Riverpod에서 cross-provider 오케스트레이션은 Notifier 내부에서 `ref`로 처리하는 것이 정석.
- **`.g.dart` 파일은 직접 수정 금지** — `portfolio_provider.dart`/`admin_provider.dart`를 고치면 `dart run build_runner build --delete-conflicting-outputs`로 재생성해야 함.
- **`ProjectReorderPanel`의 동기화**: 과거 `didChangeDependencies`로 처리하던 것을 `build()` 안의 `ref.listen(adminProvider.select((s) => s.isAdmin), ...)` (admin 진입/이탈 감지) + `ref.listen(portfolioProvider, ...)` (프로젝트 추가/삭제 시 재동기화) 두 개로 분리. 첫 빌드 시점에 이미 admin 상태인 핫리로드 같은 엣지 케이스는 의도적으로 커버하지 않음(실사용 흐름에서는 발생하지 않음).
