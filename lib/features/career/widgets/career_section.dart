import 'package:flutter/material.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/shared/section_header.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/portfolio_scope.dart';
import '../../admin/admin_scope.dart';
import '../../admin/widgets/edit_career_dialog.dart';
import 'career_card.dart';

class CareerSection extends StatelessWidget {
  const CareerSection({super.key});

  @override
  Widget build(BuildContext context) {
    final careers = PortfolioScope.of(context).careers;
    final isAdmin = AdminScope.isAdmin(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: SectionHeader(num: '03', title: '경력')),
            if (isAdmin)
              TextButton.icon(
                onPressed: () => EditCareerDialog.show(
                  context,
                  careers: careers,
                  onSaved: PortfolioScope.reloadOf(context),
                ),
                icon: const Icon(Icons.edit_rounded,
                    size: 16, color: AppColors.green),
                label: const Text(
                  '경력 편집',
                  style: TextStyle(color: AppColors.green, fontSize: 13),
                ),
              ),
          ],
        ),
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
