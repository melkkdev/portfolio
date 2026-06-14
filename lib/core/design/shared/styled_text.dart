import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// 인라인 마크업 렌더러
///   **text**  → 굵게 (inkSoft 색상 유지)
///   [[text]]  → 초록 + 굵게 (AppColors.green)
class StyledText extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;

  const StyledText({super.key, required this.text, required this.baseStyle});

  // **...** 또는 [[...]] 를 한 번에 찾는 패턴
  static final _kToken = RegExp(r'\*\*(.+?)\*\*|\[\[(.+?)\]\]');

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
