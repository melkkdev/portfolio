# HANDOFF.md — Portfolio (Flutter Web)

> 다음 Claude 에이전트를 위한 인계 문서.

## 프로젝트 경로

`C:\Users\tkdals\dev\app\portfolio`

## 현재 상태

이번 세션은 새로 시작된 세션으로 코드 변경 없이 HANDOFF.md만 현재 저장소 상태에 맞춰 재정비함. 직전 커밋(`4c7a76a`)에서 프로젝트 이미지 확대 보기(핀치줌/슬라이드) 및 본문 내 GitHub 주소 자동 링크 기능이 이미 구현·커밋되어 있음. **working tree는 깨끗함** — 단, `devtools_options.yaml`이 추적되지 않은 파일로 남아 있음(Dart DevTools가 자동 생성한 로컬 설정 파일, git에 올릴 필요 없음 — `.gitignore` 추가 검토 가능). favicon 변경 작업은 여전히 미착수.

## 구현된 파일

### 상태관리 (Riverpod codegen)

| 파일 | 역할 |
|------|------|
| `lib/data/portfolio_provider.dart` | `@Riverpod(keepAlive: true) class Portfolio extends _$Portfolio` — `build()`에서 `PortfolioState.load()`, `reload()`로 화면 깜빡임 없이 재로드. 생성 provider: `portfolioProvider` |
| `lib/features/admin/admin_provider.dart` | `AdminUiState`(isAdmin, pendingOrderIds) + `@Riverpod(keepAlive: true) class Admin extends _$Admin` — `enter()`/`exit()`(재정렬 저장+reload 흡수)/`updateOrder()`. 추가로 `@riverpod Future<String> appVersion(Ref ref)` — `package_info_plus`로 pubspec version을 런타임에 읽어 `v1.0.0+1` 형식 반환 (admin 배너 전용). 생성 provider: `adminProvider`, `appVersionProvider` |
| `lib/data/portfolio_provider.g.dart`, `lib/features/admin/admin_provider.g.dart` | build_runner 생성 코드 (수동 수정 금지) |

### 이미지 확대 보기 / 마크업 링크 (최신 추가분, `4c7a76a`)

| 파일 | 역할 |
|------|------|
| `lib/core/design/shared/image_viewer.dart` | `showImageViewer(context, imageUrls, initialIndex, title)` — 흰 배경 `Dialog` + `PageView.builder` + `InteractiveViewer`(`minScale:1, maxScale:4`)로 핀치/드래그 줌. 이미지 2장 이상이면 좌우 `_SlideButton`과 `n / total` 캡션 표시 |
| `lib/core/common/modal_styles.dart` | 모달 공통 padding/텍스트 스타일(`radius`, `headerPadding`, `contentPadding`, `headerTitle`, `caption` 등) 한곳에 모음 — 다른 모달에서도 재사용 가능 |
| `lib/core/design/shared/styled_text.dart` | 인라인 마크업 렌더러. `**text**`(굵게), `[[text]]`(초록+굵게)에 더해 `_kToken` 정규식에 `github.com/...` 패턴을 named group(`url`)으로 추가해 자동 클릭 링크(`url_launcher`)로 변환 |
| `lib/features/projects/widgets/project_card.dart` | 갤러리 우측 하단에 `_ExpandButton`(반투명 원형, `Icons.add_rounded`) 추가 — 탭 시 `showImageViewer` 호출 |
| `lib/features/projects/widgets/desktop_gallery.dart`, `phone_gallery.dart` | 이미지가 적어 캐러셀 애니메이션이 없는 경우 섹션 폭에 맞춰 가운데 정렬되도록 레이아웃 보정 |

### 위젯 (ConsumerWidget/ConsumerStatefulWidget)

`lib/main.dart`(ProviderScope), `lib/app/app.dart`(AsyncValue.when으로 loading/error/data 분기), `lib/features/hero/widgets/hero_section.dart`, `intro_section.dart`, `skills_section.dart`, `career_section.dart`, `projects_section.dart`, `lib/features/admin/widgets/admin_banner.dart`(버전 표시 포함), `admin_fab.dart`, `login_dialog.dart`, `project_reorder_panel.dart`(가장 복잡 — `ref.listen`으로 동기화)

### 무수정 (의도적)

`lib/data/portfolio_state.dart`, `lib/data/repository/portfolio_repository.dart`, `lib/features/admin/admin_service.dart`, 편집 다이얼로그 5개(`edit_profile_dialog.dart`, `edit_intro_dialog.dart`, `edit_skills_dialog.dart`, `edit_career_dialog.dart`, `edit_project_dialog.dart`) — `onSaved` 콜백 시그니처가 그대로 유지됨

## 설치된 패키지 (pubspec.yaml 기준)

```yaml
environment:
  sdk: ^3.9.0   # Flutter 3.44.2 / Dart 3.12.2

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

**⚠️ Flutter SDK 전역 업그레이드 이력**: 기존 Flutter 3.29.3(Dart 3.7.2)에서 `flutter upgrade --force`로 3.44.2(Dart 3.12.2)까지 올림. 이 과정에서 전역 SDK 설치본(`C:\Users\tkdals\Desktop\sdk\flutter`)에 있던 로컬 패치(`flutter_tools/chrome.dart`의 `--disable-web-security` 플래그, CORS 회피용)가 사라짐 — 사용자 확인 후 의도적으로 버린 것. 필요시 `flutter run -d chrome --web-browser-flag="--disable-web-security"`로 동일 효과 재현 가능.

## 차단 이슈

- **favicon 디자인/변경 미착수**: 사용자가 favicon 변경 + 디자인 요청. 이미지 생성 AI 툴 없음, 시스템에 ImageMagick(`magick`/`convert`)·Inkscape·`rsvg-convert`·Python PIL 모두 미설치 확인됨(`/c/Windows/system32/convert`는 Windows 자체 유틸리티로 무관). SVG를 코드로 작성해 변환할 도구가 없는 상태 — 다음 세션에서 ① 사용자에게 이미지 파일을 받거나 ② ImageMagick/Pillow 설치 후 진행 필요. 기존 favicon 위치: `web/favicon.png`, `web/icons/`(`Icon-192.png`, `Icon-512.png`, `Icon-maskable-192.png`, `Icon-maskable-512.png`).
- **`devtools_options.yaml` 미추적 상태**: Dart DevTools가 로컬에서 자동 생성한 파일로, 추적/커밋 불필요. 신경 쓰지 않아도 무방하나 거슬리면 `.gitignore`에 추가.

## 다음 구현할 기능 (체크리스트)

- [x] Riverpod codegen 마이그레이션
- [x] Flutter/Dart SDK 최신 업그레이드 + Riverpod 3.x 적용
- [x] admin 배너 버전 표시 추가
- [x] 프로젝트 이미지 확대 보기(핀치줌/슬라이드) 추가
- [x] 본문 텍스트 내 GitHub 주소 자동 링크 변환 추가
- [x] 전체 변경사항 commit + push (origin/main 최신: `4c7a76a`)
- [ ] **favicon 변경/디자인** — 위 차단 이슈 참고, 도구 설치 또는 사용자 제공 이미지 필요
- [ ] (선택) admin 로그인 → 편집 다이얼로그 → 드래그 재정렬 전체 플로우 추가 회귀 테스트
- [ ] (선택) 새로 추가된 이미지 뷰어/링크 기능에 대한 실제 브라우저 클릭 검증 (이번 세션에서는 미수행)

## 핵심 코드 패턴

- **Provider 접근 패턴**: `ref.watch(portfolioProvider).requireValue.X` (데이터 읽기) / `ref.read(portfolioProvider.notifier).reload` (재로드 콜백, dialog의 `onSaved`에 그대로 전달) / `ref.watch(adminProvider.select((s) => s.isAdmin))` (admin 여부만 watch) / `ref.watch(adminProvider)` (전체 상태 필요 시)
- **`reload()`는 AsyncLoading을 거치지 않음**: `state = await AsyncValue.guard(() => PortfolioState.load());` — 새 데이터 준비 전까지 기존 데이터 유지, 화면 깜빡임 없음. 이 패턴 유지할 것.
- **Riverpod 3.x AsyncValue API 차이**: `valueOrNull` getter는 없고 `.value`가 바로 nullable 값을 반환함(2.x의 `valueOrNull`과 동일 역할). `requireValue`는 그대로 존재.
- **`.g.dart` 파일 직접 수정 금지** — 수정 필요시 `dart run build_runner build`로 재생성 (Riverpod 3.x에서는 `--delete-conflicting-outputs` 옵션이 제거됨/기본 동작으로 흡수됨).
- **모달 스타일은 `ModalStyles`로 통일**: 새 모달을 추가할 때 padding/타이틀/캡션 스타일을 직접 하드코딩하지 말고 `lib/core/common/modal_styles.dart`의 상수를 재사용할 것.
- **`StyledText`의 토큰 정규식 확장 패턴**: `_kToken`에 named group(`?<name>...`)을 추가하고 `_parse()`에서 `m.namedGroup('name')`으로 분기하는 방식으로 새로운 인라인 마크업(굵게/색상/링크 등)을 추가함. 새 토큰 추가 시 이 패턴을 따를 것.
- **UI 검증 시 PowerShell 스크린샷+클릭 자동화 패턴**: 이 환경엔 별도 브라우저 자동화 툴(Playwright 등) 미설치. `flutter run -d chrome --web-port=PORT`로 백그라운드 실행 후, PowerShell의 `user32.dll` P/Invoke(`EnumWindows`/`GetWindowRect`/`SetCursorPos`/`mouse_event`)로 실제 Chrome 창을 찾아 좌표 클릭 + `System.Drawing`으로 스크린샷 캡처하는 방식으로 인터랙션을 실제 검증함. 다중 모니터 환경이라 좌표가 음수일 수 있음에 주의(`SystemInformation.VirtualScreen` 기준).
- **ReorderableListView**: Flutter 3.44.2부터 `onReorder`가 deprecated, `onReorderItem` 사용 — newIndex가 이미 보정되어 들어오므로 `if (newIndex > oldIndex) newIndex--;` 같은 수동 보정 코드 넣지 말 것.
