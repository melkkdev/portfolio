import 'package:flutter/material.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/cards/surface_card.dart';
import '../../../core/design/shared/section_header.dart';
import '../../../data/portfolio_data.dart';
import 'skill_group_row.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(num: '02', title: '기술 스택'),
        const SizedBox(height: Spacing.lg),
        SurfaceCard(
          child: Column(
            children: PortfolioData.skills
                .map((g) => SkillGroupRow(data: g))
                .toList(),
          ),
        ),
      ],
    );
  }
}
