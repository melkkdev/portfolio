import 'package:flutter/material.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/shared/section_header.dart';
import '../../../data/portfolio_scope.dart';
import 'career_card.dart';

class CareerSection extends StatelessWidget {
  const CareerSection({super.key});

  @override
  Widget build(BuildContext context) {
    final careers = PortfolioScope.of(context).careers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(num: '03', title: '경력'),
        const SizedBox(height: Spacing.lg),
        ...careers.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CareerCard(career: c),
          ),
        ),
      ],
    );
  }
}
