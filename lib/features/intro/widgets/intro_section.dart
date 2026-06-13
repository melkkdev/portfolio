import 'package:flutter/material.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/cards/surface_card.dart';
import '../../../core/design/shared/section_header.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/portfolio_scope.dart';

class IntroSection extends StatelessWidget {
  const IntroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final paragraphs = PortfolioScope.of(context).intro;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(num: '01', title: '소개'),
        const SizedBox(height: Spacing.lg),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: paragraphs
                .expand(
                  (text) => [
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.inkSoft,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                )
                .toList()
              ..removeLast(),
          ),
        ),
      ],
    );
  }
}
