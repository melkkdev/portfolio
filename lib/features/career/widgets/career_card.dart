import 'package:flutter/material.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/cards/surface_card.dart';
import '../../../core/design/shared/styled_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/career_model.dart';

/// 기간 · 점선 타임라인 · 경력 카드 한 줄
class CareerTimelineItem extends StatelessWidget {
  final CareerModel career;
  final bool isFirst;
  final bool isLast;

  const CareerTimelineItem({
    super.key,
    required this.career,
    this.isFirst = false,
    this.isLast = false,
  });

  bool get _isCurrent =>
      career.period.contains('현재') ||
      career.period.toLowerCase().contains('present');

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width < Spacing.mobileBreakpoint;

    final period = Text(
      career.period,
      style: AppTheme.mono(fontSize: 12, color: AppColors.muted),
    );

    final card = Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 28),
      child: CareerCard(career: career, isCurrent: _isCurrent),
    );

    const railWidth = 36.0;
    final periodWidth = isMobile ? 0.0 : 150.0;

    // 카드 높이는 내용이 정하고, 점선 레일은 Stack으로 그 높이에 맞춰 겹쳐 그린다.
    // (IntrinsicHeight는 줄바꿈되는 Wrap/RichText 높이를 작게 잡아 오버플로우가 났음)
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(left: periodWidth + railWidth),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 22, bottom: 8),
                      child: period,
                    ),
                    card,
                  ],
                )
              : card,
        ),
        if (!isMobile)
          Positioned(
            left: 0,
            top: 26,
            width: periodWidth - 4,
            child: Align(alignment: Alignment.topRight, child: period),
          ),
        Positioned(
          left: periodWidth,
          top: 0,
          bottom: 0,
          width: railWidth,
          child: CustomPaint(
            painter: _RailPainter(
              isFirst: isFirst,
              isLast: isLast,
              isCurrent: _isCurrent,
            ),
          ),
        ),
      ],
    );
  }
}

class _RailPainter extends CustomPainter {
  final bool isFirst;
  final bool isLast;
  final bool isCurrent;

  _RailPainter({
    required this.isFirst,
    required this.isLast,
    required this.isCurrent,
  });

  static const _dotY = 32.0;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final line = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.35)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // 점선
    final startY = isFirst ? _dotY : 0.0;
    final endY = isLast ? _dotY : size.height;
    for (var y = startY; y < endY; y += 9) {
      canvas.drawLine(Offset(x, y), Offset(x, (y + 4).clamp(0, endY)), line);
    }

    // 점
    if (isCurrent) {
      canvas.drawCircle(Offset(x, _dotY), 10,
          Paint()..color = AppColors.accent.withValues(alpha: 0.2));
      canvas.drawCircle(
          Offset(x, _dotY), 6, Paint()..color = AppColors.accent);
      canvas.drawCircle(Offset(x, _dotY), 2.5, Paint()..color = Colors.white);
    } else {
      canvas.drawCircle(
          Offset(x, _dotY), 5, Paint()..color = const Color(0xFFF2A673));
    }
  }

  @override
  bool shouldRepaint(_RailPainter old) =>
      old.isFirst != isFirst ||
      old.isLast != isLast ||
      old.isCurrent != isCurrent;
}

class CareerCard extends StatelessWidget {
  final CareerModel career;
  final bool isCurrent;

  const CareerCard({super.key, required this.career, this.isCurrent = false});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 6,
            children: [
              Text(career.company, style: AppTheme.display(fontSize: 24)),
              if (isCurrent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.sageSoft,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: const Text(
                    '재직 중',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.sage,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          StyledText(
            text: career.role,
            baseStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.accent,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ...career.bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4, right: 10),
                    child: Icon(Icons.auto_awesome_rounded,
                        size: 14, color: Color(0xFFF2A673)),
                  ),
                  Expanded(
                    child: StyledText(
                      text: b,
                      baseStyle: const TextStyle(
                        fontSize: 15,
                        color: AppColors.inkSoft,
                        height: 1.65,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
