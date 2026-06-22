# HANDOFF.md — Portfolio (Flutter Web)

> 다음 Claude 에이전트를 위한 인계 문서.

## 프로젝트 경로

`C:\Users\tkdals\dev\app\portfolio`

## 현재 상태

상태관리를 Riverpod codegen으로 마이그레이션하고 Flutter/Dart SDK를 최신으로 업그레이드 완료. admin 배너에 앱 버전 표시 기능 추가. **모든 변경사항 commit + push 완료 (working tree clean)**. 다음 작업으로 favicon 변경 요청이 들어왔으나 이미지 생성/변환 도구 부재로 미착수 상태.

## 구현된 파일

### 상태관리 (Riverpod codegen)

| 파일 | 역할 |
|------|------|
| `lib/data/portfolio_provider.dart` | `@Riverpod(keepAlive: true) class Portfolio extends _$Portfolio` — `build()`에서 `PortfolioState.load()`, `reload()`로 화면 깜빡임 없이 재로드. 생성 provider: `portfolioProvider` |
| `lib/features/admin/admin_provider.dart` | `AdminUiState`(isAdmin, pendingOrderIds) + `@Riverpod(keepAlive: true) class Admin extends _$Admin` — `enter()`/`exit()`(재정렬 저장+reload 흡수)/`updateOrder()`. 추가로 `@riverpod Future<String> appVersion(Ref ref)` — `package_info_plus`로 pubspec version을 런타임에 읽어 `v1.0.0+1` 형식 반환 (admin 배너 전용). 생성 provider: `adminProvider`, `appVersionProvider` |
| `lib/data/portfolio_provider.g.dart`, `lib/features/admin/admin_provider.g.dart` | build_runner 생성 코드 (수동 수정 금지) |

### 위젯 (ConsumerWidget/ConsumerStatefulWidget)

`lib/main.dart`(ProviderScope), `lib/app/app.dart`(AsyncValue.when으로 loading/error/data 분기), `lib/features/hero/widgets/hero_section.dart`, `intro_section.dart`, `skills_section.dart`, `career_section.dart`, `projects_section.dart`, `project_card.dart`, `lib/features/admin/widgets/admin_banner.dart`(버전 표시 포함), `admin_fab.dart`, `login_dialog.dart`, `project_reorder_panel.dart`(가장 복잡 — `ref.listen`으로 동기화)

### 무수정 (의도적)

`lib/data/portfolio_state.dart`, `lib/data/repository/portfolio_repository.dart`, `lib/features/admin/admin_service.dart`, 편집 다이얼로그 5개(`edit_profile_dialog.dart`, `edit_intro_dialog.dart`, `edit_skills_dialog.dart`, `edit_career_dialog.dart`, `edit_project_dialog.dart`) — `onSaved` 콜백 시그니처가 그대로 유지됨

## 설치된 패키지 (pubspec.yaml 기준)

```yaml
environment:
  sdk: ^3.9.0   # Flutter 3.44.2 / Dart 3.12.2로 전역 업그레이드됨

dependencies:
  flutter_riverpod: ^3.3.2
  riverpod_annotation: ^4.0.3
  package_info_plus: ^9.0.1
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
  riverpod_generator: ^4.0.4
  build_runner: ^2.15.0
  flutter_lints: ^5.0.0
```

**⚠️ Flutter SDK 전역 업그레이드 이력**: 기존 Flutter 3.29.3(Dart 3.7.2, 2025-04 릴리스)에서 `flutter upgrade --force`로 3.44.2(Dart 3.12.2)까지 올림. 이 과정에서 전역 SDK 설치본(`C:\Users\tkdals\Desktop\sdk\flutter`)에 있던 로컬 패치(`flutter_tools/chrome.dart`의 `--disable-web-security` 플래그, CORS 회피용)가 사라짐 — 사용자 확인 후 의도적으로 버린 것. 필요시 `flutter run -d chrome --web-browser-flag="--disable-web-security"`로 동일 효과 재현 가능.

## 차단 이슈

- **favicon 디자인/변경 미착수**: 사용자가 favicon 변경 + 디자인 요청. 이미지 생성 AI 툴 없음, 시스템에 ImageMagick(`magick`/`convert`)·Inkscape·`rsvg-convert`·Python PIL 모두 미설치 확인됨(`/c/Windows/system32/convert`는 Windows 자체 유틸리티로 무관). SVG를 코드로 작성해 변환할 도구가 없는 상태 — 다음 세션에서 ① 사용자에게 이미지 파일을 받거나 ② ImageMagick/Pillow 설치 후 진행 필요. 기존 favicon 위치: `web/favicon.png`, `web/icons/`.

## 다음 구현할 기능 (체크리스트)

- [x] Riverpod codegen 마이그레이션
- [x] Flutter/Dart SDK 최신 업그레이드 + Riverpod 3.x 적용
- [x] admin 배너 버전 표시 추가
- [x] 전체 변경사항 commit + push (origin/main 최신: `e41bca7`)
- [ ] **favicon 변경/디자인** — 위 차단 이슈 참고, 도구 설치 또는 사용자 제공 이미지 필요
- [ ] (선택) admin 로그인 → 편집 다이얼로그 → 드래그 재정렬 전체 플로우 추가 회귀 테스트 (지금까지는 핵심 경로만 클릭 테스트함)

## 핵심 코드 패턴

- **Provider 접근 패턴**: `ref.watch(portfolioProvider).requireValue.X` (데이터 읽기) / `ref.read(portfolioProvider.notifier).reload` (재로드 콜백, dialog의 `onSaved`에 그대로 전달) / `ref.watch(adminProvider.select((s) => s.isAdmin))` (admin 여부만 watch) / `ref.watch(adminProvider)` (전체 상태 필요 시)
- **`reload()`는 AsyncLoading을 거치지 않음**: `state = await AsyncValue.guard(() => PortfolioState.load());` — 새 데이터 준비 전까지 기존 데이터 유지, 화면 깜빡임 없음. 이 패턴 유지할 것.
- **Riverpod 3.x AsyncValue API 차이**: `valueOrNull` getter는 없고 `.value`가 바로 nullable 값을 반환함(2.x의 `valueOrNull`과 동일 역할). `requireValue`는 그대로 존재.
- **`.g.dart` 파일 직접 수정 금지** — 수정 필요시 `dart run build_runner build`로 재생성 (Riverpod 3.x에서는 `--delete-conflicting-outputs` 옵션이 제거됨/기본 동작으로 흡수됨).
- **UI 검증 시 PowerShell 스크린샷+클릭 자동화 패턴**: 이 환경엔 별도 브라우저 자동화 툴(Playwright 등) 미설치. `flutter run -d chrome --web-port=PORT`로 백그라운드 실행 후, PowerShell의 `user32.dll` P/Invoke(`EnumWindows`/`GetWindowRect`/`SetCursorPos`/`mouse_event`)로 실제 Chrome 창을 찾아 좌표 클릭 + `System.Drawing`으로 스크린샷 캡처하는 방식으로 admin 로그인 등 인터랙션을 실제 검증함. 다중 모니터 환경이라 좌표가 음수일 수 있음에 주의(`SystemInformation.VirtualScreen` 기준).
- **ReorderableListView**: Flutter 3.44.2부터 `onReorder`가 deprecated, `onReorderItem` 사용 — newIndex가 이미 보정되어 들어오므로 `if (newIndex > oldIndex) newIndex--;` 같은 수동 보정 코드 넣지 말 것.
