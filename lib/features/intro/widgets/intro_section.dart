import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/shared/reveal.dart';
import '../../../core/design/shared/section_band.dart';
import '../../../core/design/shared/section_header.dart';
import '../../../core/design/shared/styled_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/portfolio_provider.dart';
import '../../admin/admin_provider.dart';
import '../../admin/widgets/edit_intro_dialog.dart';

class IntroSection extends ConsumerWidget {
  const IntroSection({super.key});

  static const _baseStyle = TextStyle(
    fontSize: 17,
    color: AppColors.inkSoft,
    height: 1.85,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paragraphs = ref.watch(portfolioProvider).requireValue.intro;
    final isAdmin = ref.watch(adminProvider.select((s) => s.isAdmin));
    final isMobile =
        MediaQuery.sizeOf(context).width < Spacing.mobileBreakpoint;

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, p) in paragraphs.indexed) ...[
          if (i > 0) const SizedBox(height: 16),
          StyledText(text: p, baseStyle: _baseStyle),
        ],
      ],
    );

    return SectionBand(
      child: Reveal(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(child: SectionHeader(num: '01', title: '소개')),
                if (isAdmin)
                  AdminTextButton(
                    onPressed: () => EditIntroDialog.show(
                      context,
                      paragraphs: paragraphs,
                      onSaved: ref.read(portfolioProvider.notifier).reload,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Spacing.xl),
            if (isMobile) ...[
              const _ProfilePlaceholder(size: 140),
              const SizedBox(height: Spacing.lg),
              text,
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ProfilePlaceholder(size: 200),
                  const SizedBox(width: 64),
                  Expanded(child: text),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// 프로필 사진 자리. 사진이 정해질 때까지 빈칸으로 둔다.
class _ProfilePlaceholder extends StatelessWidget {
  final double size;
  const _ProfilePlaceholder({required this.size});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.04,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.peach, AppColors.accentSoft],
          ),
          borderRadius: BorderRadius.circular(size * 0.22),
        ),
      ),
    );
  }
}
