import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

/// 인라인 마크업 렌더러
///   **text**  → 굵게 (inkSoft 색상 유지)
///   [[text]]  → 초록 + 굵게 (AppColors.green)
///   github.com/... 또는 https://github.com/... → 클릭 가능한 링크
class StyledText extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;

  const StyledText({super.key, required this.text, required this.baseStyle});

  // **...**, [[...]], GitHub 주소를 한 번에 찾는 패턴
  static final _kToken = RegExp(
    r'\*\*(.+?)\*\*|\[\[(.+?)\]\]|(?<url>(?:https?://)?(?:www\.)?github\.com/[^\s,)\]]+)',
    caseSensitive: false,
  );

  List<InlineSpan> _parse() {
    final spans = <InlineSpan>[];
    int cursor = 0;

    for (final m in _kToken.allMatches(text)) {
      if (m.start > cursor) {
        spans.add(TextSpan(
          text: text.substring(cursor, m.start),
          style: baseStyle,
        ));
      }

      final url = m.namedGroup('url');
      if (url != null) {
        final fullUrl = url.startsWith('http') ? url : 'https://$url';
        spans.add(TextSpan(
          text: url,
          style: baseStyle.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.green,
            decoration: TextDecoration.underline,
          ),
          mouseCursor: SystemMouseCursors.click,
          recognizer: TapGestureRecognizer()
            ..onTap = () => launchUrl(Uri.parse(fullUrl)),
        ));
        cursor = m.end;
        continue;
      }

      final isBold = m.group(1) != null;
      final raw = isBold ? m.group(1)! : m.group(2)!;
      final content = isBold ? raw : raw.replaceAll('**', '');
      spans.add(TextSpan(
        text: content,
        style: isBold
            ? baseStyle.copyWith(fontWeight: FontWeight.w700)
            : baseStyle.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.green,
              ),
      ));
      cursor = m.end;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: baseStyle));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(TextSpan(children: _parse()));
  }
}
