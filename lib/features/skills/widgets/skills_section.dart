import 'package:flutter/material.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/cards/surface_card.dart';
import '../../../core/design/shared/section_header.dart';
import '../../../data/portfolio_scope.dart';
import 'skill_group_row.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final skills = PortfolioScope.of(context).skills;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(num: '02', title: '기술 스택'),
        const SizedBox(height: Spacing.lg),
        SurfaceCard(
          child: Column(
            children: skills.map((g) => SkillGroupRow(data: g)).toList(),
          ),
        ),
      ],
    );
  }
}
