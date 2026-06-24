# HANDOFF.md — Portfolio (Flutter Web)

> 다음 Claude 에이전트를 위한 인계 문서.

## 프로젝트 경로

`C:\Users\tkdals\dev\app\portfolio`

## 현재 상태

이번 세션에서 **포트폴리오 전체를 PDF로 다운로드하는 기능**을 구현하고, 관련 버그를 수정했습니다.

### 완료된 작업

1. **PDF 다운로드 기능 추가**
   - Hero 섹션 "PDF 다운로드" 버튼 → `showPortfolioPdfPreview()` 호출
   - `PdfPreview` 미리보기 다이얼로그 (인쇄 버튼 / 웹에서는 공유 버튼 숨김)

2. **`PdfTooBigPageException` 수정** (두 차례)
   - 1차: `pw.Container`/`pw.Column`으로 섹션을 통째로 감싸면 페이지 분할이 안 됨 → 각 항목을 `MultiPage` 최상위 리스트 요소로 분리
   - 2차: `pw.Image(fit: BoxFit.cover)` + 높이 미지정 → pdf 패키지가 이미지를 페이지 전체 높이로 렌더링 → `PdfTooBigPageException`. 명시적 `width`/`height` + `BoxFit.contain` + 행별 분리(`pw.Row`)로 수정. **테스트는 이미지를 실제로 다운로드하지 못해 이 경로가 실행되지 않아 통과했었음**.

3. **UI/UX 개선**
   - 웹에서 공유 버튼 숨김 (`allowSharing: !kIsWeb`)
   - 프로젝트마다 새 페이지 시작 (`pw.NewPage()`)
   - `StatefulWidget` + `Future.delayed(80ms)`: 다이얼로그가 로딩 인디케이터를 먼저 렌더링한 뒤 PDF 생성 시작
   - `Isolate.run()` 논블로킹 시도 → **dart4web에서 `dart:isolate` 미지원** → 제거. 현재는 `Future.delayed(80ms)` 구조가 UX를 담당함

4. **회귀 테스트 추가** (`test/pdf_smoke_test.dart`)

### working tree

`flutter analyze` — No issues found.  
`flutter test` — All tests passed.  
모든 변경사항 **이번 세션 마지막에 커밋됨**.

---

## 이번 세션에 추가/수정된 파일

| 파일 | 역할 |
|------|------|
| `lib/core/pdf/portfolio_pdf_builder.dart` | PDF 문서 생성 로직. `PortfolioPdfBuilder.build()` 공개 API. `_buildContent()`를 별도 메서드로 분리해 폰트 폴백 경로와 공유. |
| `lib/core/pdf/pdf_export_dialog.dart` | PDF 미리보기 다이얼로그. `StatefulWidget`으로 로딩 상태 관리. `allowSharing: !kIsWeb`. `canChangePageFormat: false`. |
| `lib/features/hero/widgets/hero_section.dart` | Hero 섹션에 PDF 다운로드 버튼(`_PdfDownloadButton`) 추가. 전체 `PortfolioState`를 watch하도록 변경. |
| `test/pdf_smoke_test.dart` | 회귀 테스트. 실제 운영 규모(이미지 9장/프로젝트 × 4개)로 예외 없이 PDF 생성되는지 + 페이지 수 50 미만인지 검증. |
| `pubspec.yaml` | `pdf: ^3.13.0`, `printing: ^5.15.0`, `http: ^1.6.0` 추가 |

---

## 설치된 패키지 (이번 세션에 추가됨)

```yaml
dependencies:
  pdf: ^3.13.0       # PDF 문서 생성 (순수 Dart)
  printing: ^5.15.0  # PdfGoogleFonts (한글 폰트), PdfPreview 위젯
  http: ^1.6.0       # 이미지 바이트 fetch (PDF 임베드용)
```

---

## 다음 구현할 기능 (체크리스트)

- [x] Riverpod codegen 마이그레이션
- [x] Flutter 3.44.2 업그레이드 + Riverpod 3.x 적용
- [x] admin 배너 버전 표시 추가
- [x] 프로젝트 이미지 확대 보기 추가
- [x] 본문 텍스트 내 GitHub 주소 자동 링크 변환
- [x] PDF 다운로드 기능 (Hero 버튼 → 미리보기 → 인쇄/다운로드)
- [x] PDF PdfTooBigPageException 버그 수정 (2회)
- [x] 프로젝트 섹션마다 새 페이지 / 웹에서 공유 버튼 숨김
- [x] 로딩 인디케이터 UX 개선 (StatefulWidget + Future.delayed)
- [ ] **favicon 변경/디자인** — ImageMagick/Inkscape/PIL 미설치. 사용자에게 이미지 파일을 받거나 도구 설치 후 진행. 위치: `web/favicon.png`, `web/icons/`
- [ ] (선택) admin 전체 플로우 회귀 테스트

---

## 핵심 코드 패턴

- **Provider 접근**: `ref.watch(portfolioProvider).requireValue.X` / `ref.read(portfolioProvider.notifier).reload` / `ref.watch(adminProvider.select((s) => s.isAdmin))`
- **`reload()`는 AsyncLoading을 거치지 않음**: `state = await AsyncValue.guard(...)` — 기존 데이터 유지, 화면 깜빡임 없음.
- **Riverpod 3.x**: `.value`가 nullable 값 반환 (2.x의 `valueOrNull`과 동일). `requireValue`는 그대로.
- **`.g.dart` 직접 수정 금지** — `dart run build_runner build`로 재생성.
- **모달 스타일**: `lib/core/common/modal_styles.dart`의 `ModalStyles` 상수 재사용.
- **`pdf` MultiPage 페이지 분할 규칙**: 최상위 리스트 항목이 `SpanningWidget`(`RichText`, `Table` 등)이 아니면 한 페이지 안에 통째로 들어가야 함. `Container`/`Column`으로 묶으면 `PdfTooBigPageException` 발생. 이미지는 `width`/`height` 모두 명시 + `BoxFit.contain` + 행(Row)별로 분리.
- **PDF 한글 폰트**: `PdfGoogleFonts.notoSansKRRegular()`(printing 패키지) — 내부 캐시 있음. `TtfFont.data`가 공개 `ByteData` 필드이므로 직렬화 가능. 테스트 환경에서는 네트워크 차단으로 Helvetica 폴백 반환 → `regularFont is pw.TtfFont` 체크 후 분기 필요.
- **`dart:isolate` Flutter Web 미지원**: `Isolate.run()`은 dart4web에서 크래시. `compute()`는 web에서 동기 실행(실질적 논블로킹 없음). Flutter Web PDF 논블로킹은 현재 불가능 — `Future.delayed`로 인디케이터 먼저 보여주는 것이 최선.
- **PDF 미리보기 로딩 흐름**: `StatefulWidget._generatePdf()` → `Future.delayed(80ms)` → 폰트/이미지 fetch(인디케이터 돌아감) → `doc.addPage()` + `doc.save()` (동기 블로킹, 불가피) → `PdfPreview(build: (_) => Future.value(bytes))`.
- **웹 PDF 다운로드**: `PdfPreview`의 인쇄 버튼(브라우저 인쇄 다이얼로그) 사용. 공유 버튼(`allowSharing: !kIsWeb`)은 웹에서 숨김.
- **ReorderableListView**: Flutter 3.44.2부터 `onReorderItem` 사용 — `newIndex` 수동 보정 불필요.
- **`StyledText` 토큰 규칙 동기화**: `styled_text.dart`의 `_kToken` 정규식을 바꾸면 `portfolio_pdf_builder.dart`의 `_parseStyledSpans`도 같이 수정해야 함.
