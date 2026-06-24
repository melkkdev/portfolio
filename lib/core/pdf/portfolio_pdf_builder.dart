import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/models/career_model.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/project_model.dart';
import '../../data/models/skill_model.dart';
import '../../data/portfolio_state.dart';

// Isolate에 전달할 직렬화 가능한 데이터 묶음.
// - ByteData  : TtfFont.data (폰트 원본 바이트, Isolate 간 전송 가능)
// - Uint8List : 이미지 바이트 (전송 가능)
// - PortfolioState 하위 모델들: String/bool/List<String>만 포함 → 전송 가능
class _PdfBuildParams {
  final PortfolioState state;
  final ByteData regularFontData;
  final ByteData boldFontData;
  final Map<String, Uint8List> images;
  final double pageWidth;
  final double pageHeight;

  const _PdfBuildParams({
    required this.state,
    required this.regularFontData,
    required this.boldFontData,
    required this.images,
    required this.pageWidth,
    required this.pageHeight,
  });
}

class PortfolioPdfBuilder {
  static const _green = PdfColor.fromInt(0xFF006E51);
  static const _ink = PdfColor.fromInt(0xFF232826);
  static const _inkSoft = PdfColor.fromInt(0xFF3A423D);
  static const _muted = PdfColor.fromInt(0xFF6B746E);
  static const _line = PdfColor.fromInt(0xFFE3E7E3);

  // ─────────────────────────────────────────────────────────────────────────
  // ① 메인 스레드: 비동기 I/O (폰트 다운로드 + 이미지 fetch)
  // ─────────────────────────────────────────────────────────────────────────
  static Future<Uint8List> build(
    PortfolioState state, {
    PdfPageFormat? format,
  }) async {
    final effectiveFormat = format ?? PdfPageFormat.a4;

    // PdfGoogleFonts는 내부적으로 캐시를 사용하므로 두 번째 호출부터는 빠름.
    final regularFont = await PdfGoogleFonts.notoSansKRRegular();
    final boldFont = await PdfGoogleFonts.notoSansKRBold();

    final imageUrls = <String>{
      for (final p in state.projects) ...p.imageUrls,
    }.toList();
    final images = await _fetchImages(imageUrls);

    // ─────────────────────────────────────────────────────────────────────
    // ② 경로 분기
    //
    //   [정상] 폰트가 TtfFont로 로드됨 → ByteData를 Isolate에 전달.
    //          Isolate.run() = Flutter Web에서 Web Worker로 실행.
    //          메인 스레드가 블로킹되지 않으므로 인디케이터가 계속 돌아간다.
    //
    //   [폴백] 테스트 환경처럼 네트워크가 차단되면 PdfGoogleFonts가 Helvetica
    //          (BuiltinFont)를 반환 → TtfFont.data가 없으므로 Isolate 불가.
    //          메인 스레드에서 직접 빌드한다.
    // ─────────────────────────────────────────────────────────────────────
    if (regularFont is pw.TtfFont && boldFont is pw.TtfFont) {
      return _buildPdf(_PdfBuildParams(
        state: state,
        regularFontData: regularFont.data,
        boldFontData: boldFont.data,
        images: images,
        pageWidth: effectiveFormat.width,
        pageHeight: effectiveFormat.height,
      ));
    }

    // 폴백: 메인 스레드에서 직접 빌드 (테스트 환경 등)
    return _buildPdfOnMainThread(regularFont, boldFont, state, images, effectiveFormat);
  }

  static Future<Uint8List> _buildPdfOnMainThread(
    pw.Font regular,
    pw.Font bold,
    PortfolioState state,
    Map<String, Uint8List> images,
    PdfPageFormat format,
  ) async {
    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );
    doc.addPage(pw.MultiPage(
      maxPages: 200,
      pageFormat: format,
      margin: const pw.EdgeInsets.fromLTRB(36, 40, 36, 40),
      build: (_) => _buildContent(state, images),
    ));
    return doc.save();
  }

  static Future<Map<String, Uint8List>> _fetchImages(
    List<String> urls,
  ) async {
    final result = <String, Uint8List>{};
    await Future.wait(urls.map((url) async {
      try {
        final res = await http.get(Uri.parse(url));
        if (res.statusCode == 200) result[url] = res.bodyBytes;
      } catch (_) {
        // 다운로드 실패한 이미지는 PDF에서 건너뜀
      }
    }));
    return result;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 백그라운드 Isolate에서 실행되는 순수 Dart 함수.
  // Flutter 플랫폼 채널 / rootBundle 등 Flutter 의존성 사용 금지.
  // ─────────────────────────────────────────────────────────────────────────
  static Future<Uint8List> _buildPdf(_PdfBuildParams p) async {
    final regular = pw.TtfFont(p.regularFontData);
    final bold = pw.TtfFont(p.boldFontData);
    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );
    doc.addPage(pw.MultiPage(
      maxPages: 200,
      pageFormat: PdfPageFormat(p.pageWidth, p.pageHeight),
      margin: const pw.EdgeInsets.fromLTRB(36, 40, 36, 40),
      build: (_) => _buildContent(p.state, p.images),
    ));
    return doc.save();
  }

  // 메인 스레드·Isolate 양쪽에서 공유하는 순수 위젯 빌더
  static List<pw.Widget> _buildContent(
    PortfolioState state,
    Map<String, Uint8List> images,
  ) =>
      [
        _buildProfile(state.profile),
        if (state.intro.isNotEmpty) ...[
          pw.SizedBox(height: 28),
          _sectionTitle('소개'),
          pw.SizedBox(height: 10),
          ..._buildIntro(state.intro),
        ],
        if (state.skills.isNotEmpty) ...[
          pw.SizedBox(height: 28),
          _sectionTitle('기술 스택'),
          pw.SizedBox(height: 10),
          ..._buildSkills(state.skills),
        ],
        if (state.careers.isNotEmpty) ...[
          pw.SizedBox(height: 28),
          _sectionTitle('경력'),
          pw.SizedBox(height: 10),
          ..._buildCareers(state.careers),
        ],
        if (state.projects.isNotEmpty) ...[
          pw.SizedBox(height: 28),
          _sectionTitle('대표 프로젝트'),
          pw.SizedBox(height: 14),
          for (int i = 0; i < state.projects.length; i++) ...[
            if (i > 0) pw.NewPage(),
            ..._buildProject(state.projects[i], images),
            pw.SizedBox(height: 18),
          ],
        ],
      ];

  // ── PDF 위젯 빌더 (아래부터는 메인/Isolate 양쪽에서 호출 가능한 순수 함수) ──

  static pw.Widget _sectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
        color: _green,
      ),
    );
  }

  static pw.Widget _buildProfile(ProfileModel profile) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          profile.role,
          style: pw.TextStyle(
            fontSize: 10,
            color: _muted,
            letterSpacing: 1.2,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          profile.name,
          style: pw.TextStyle(
            fontSize: 26,
            fontWeight: pw.FontWeight.bold,
            color: _green,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          profile.tagline,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: _ink,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            pw.Text(
              profile.careerYears,
              style: pw.TextStyle(fontSize: 10, color: _inkSoft),
            ),
            pw.SizedBox(width: 18),
            pw.UrlLink(
              destination: profile.githubUrl,
              child: pw.Text(
                profile.githubDisplayUrl,
                style: pw.TextStyle(
                  fontSize: 10,
                  color: _green,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static List<pw.Widget> _buildIntro(List<String> paragraphs) {
    return [
      for (final text in paragraphs)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.RichText(
            text: pw.TextSpan(
              children: _parseStyledSpans(
                text,
                pw.TextStyle(fontSize: 11, color: _inkSoft, lineSpacing: 3),
              ),
            ),
          ),
        ),
    ];
  }

  static List<pw.Widget> _buildSkills(List<SkillGroupModel> groups) {
    return [
      for (final g in groups)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: 90,
                child: pw.Text(
                  g.label,
                  style: pw.TextStyle(fontSize: 9, color: _muted),
                ),
              ),
              pw.Expanded(
                child: pw.Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: g.skills
                      .map((s) => _skillChip(s, g.highlights.contains(s)))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
    ];
  }

  static pw.Widget _skillChip(String label, bool highlight) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: highlight ? _green : PdfColors.white,
        border: highlight ? null : pw.Border.all(color: _line),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        label,
        style: pw.TextStyle(
          fontSize: 9,
          color: highlight ? PdfColors.white : _inkSoft,
        ),
      ),
    );
  }

  static List<pw.Widget> _buildCareers(List<CareerModel> careers) {
    final widgets = <pw.Widget>[];

    for (final c in careers) {
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4, bottom: 6),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      c.company,
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: _ink,
                      ),
                    ),
                  ),
                  pw.Text(
                    c.period,
                    style: pw.TextStyle(fontSize: 9, color: _muted),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.RichText(
                text: pw.TextSpan(
                  children: _parseStyledSpans(
                    c.role,
                    pw.TextStyle(fontSize: 10, color: _muted),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      for (final b in c.bullets) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  margin: const pw.EdgeInsets.only(top: 4, right: 6),
                  width: 4,
                  height: 4,
                  decoration: const pw.BoxDecoration(
                    color: _green,
                    shape: pw.BoxShape.circle,
                  ),
                ),
                pw.Expanded(
                  child: pw.RichText(
                    text: pw.TextSpan(
                      children: _parseStyledSpans(
                        b,
                        pw.TextStyle(
                          fontSize: 10.5,
                          color: _inkSoft,
                          lineSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      widgets.add(pw.SizedBox(height: 10));
    }

    return widgets;
  }

  static List<pw.Widget> _buildProject(
    ProjectModel project,
    Map<String, Uint8List> images,
  ) {
    final availableImages =
        project.imageUrls.where(images.containsKey).toList();

    final widgets = <pw.Widget>[
      pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 8),
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: _line, width: 1)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              project.eyebrow,
              style: pw.TextStyle(fontSize: 9, color: _muted),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              project.title,
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
                color: _green,
              ),
            ),
            if (project.summary.isNotEmpty) ...[
              pw.SizedBox(height: 6),
              pw.Text(
                project.summary,
                style:
                    pw.TextStyle(fontSize: 10, color: _inkSoft, lineSpacing: 2),
              ),
            ],
          ],
        ),
      ),
    ];

    if (availableImages.isNotEmpty) {
      widgets.add(pw.SizedBox(height: 10));

      final imgW = project.isLandscape ? 200.0 : 100.0;
      final imgH = project.isLandscape ? 115.0 : 220.0;
      const spacing = 8.0;
      final perRow = ((523 + spacing) / (imgW + spacing)).floor().clamp(1, 9);

      for (int i = 0; i < availableImages.length; i += perRow) {
        final rowUrls = availableImages.sublist(
          i,
          (i + perRow).clamp(0, availableImages.length),
        );
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                for (int j = 0; j < rowUrls.length; j++) ...[
                  if (j > 0) pw.SizedBox(width: spacing),
                  pw.Image(
                    pw.MemoryImage(images[rowUrls[j]]!),
                    width: imgW,
                    height: imgH,
                    fit: pw.BoxFit.contain,
                  ),
                ],
              ],
            ),
          ),
        );
      }
    }

    if (project.rows.isNotEmpty) {
      widgets.add(pw.SizedBox(height: 10));
      for (final r in project.rows) {
        widgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: 70,
                  child: pw.Text(
                    r.label,
                    style: pw.TextStyle(
                      fontSize: 9.5,
                      color: _green,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: r.value.isEmpty
                      ? pw.Text(
                          '없음',
                          style: pw.TextStyle(fontSize: 9.5, color: _muted),
                        )
                      : pw.RichText(
                          text: pw.TextSpan(
                            children: _parseStyledSpans(
                              r.value,
                              pw.TextStyle(fontSize: 9.5, color: _inkSoft),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      }
    }

    if (project.stats.isNotEmpty) {
      widgets.add(pw.SizedBox(height: 4));
      widgets.add(
        pw.Wrap(
          spacing: 20,
          runSpacing: 8,
          children: project.stats
              .map((s) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        s.value,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: _ink,
                        ),
                      ),
                      pw.Text(
                        s.label,
                        style: pw.TextStyle(fontSize: 8.5, color: _muted),
                      ),
                    ],
                  ))
              .toList(),
        ),
      );
    }

    return widgets;
  }

  // **text** → 굵게, [[text]] → 초록+굵게, github.com/... → 클릭 가능한 링크.
  // styled_text.dart의 토큰 규칙을 PDF RichText로 동일하게 재현한다.
  static final _kToken = RegExp(
    r'\*\*(.+?)\*\*|\[\[(.+?)\]\]|(?<url>(?:https?://)?(?:www\.)?github\.com/[^\s,)\]]+)',
    caseSensitive: false,
  );

  static List<pw.TextSpan> _parseStyledSpans(String text, pw.TextStyle base) {
    final spans = <pw.TextSpan>[];
    int cursor = 0;

    for (final m in _kToken.allMatches(text)) {
      if (m.start > cursor) {
        spans.add(pw.TextSpan(
            text: text.substring(cursor, m.start), style: base));
      }

      final url = m.namedGroup('url');
      if (url != null) {
        final fullUrl = url.startsWith('http') ? url : 'https://$url';
        spans.add(pw.TextSpan(
          text: url,
          style: base.copyWith(color: _green, fontWeight: pw.FontWeight.bold),
          annotation: pw.AnnotationUrl(fullUrl),
        ));
        cursor = m.end;
        continue;
      }

      final isBold = m.group(1) != null;
      final raw = isBold ? m.group(1)! : m.group(2)!;
      spans.add(pw.TextSpan(
        text: raw,
        style: isBold
            ? base.copyWith(fontWeight: pw.FontWeight.bold)
            : base.copyWith(fontWeight: pw.FontWeight.bold, color: _green),
      ));
      cursor = m.end;
    }

    if (cursor < text.length) {
      spans.add(pw.TextSpan(text: text.substring(cursor), style: base));
    }
    return spans;
  }
}
