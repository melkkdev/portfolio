import 'package:flutter/material.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/cards/surface_card.dart';
import '../../../core/design/shared/section_header.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/portfolio_scope.dart';
import '../../admin/admin_scope.dart';
import '../../admin/widgets/edit_skills_dialog.dart';
import 'skill_group_row.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final skills = PortfolioScope.of(context).skills;
    final isAdmin = AdminScope.isAdmin(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
                child: SectionHeader(num: '02', title: '기술 스택')),
            if (isAdmin)
              TextButton.icon(
                onPressed: () => EditSkillsDialog.show(
                  context,
                  groups: skills,
                  onSaved: PortfolioScope.reloadOf(context),
                ),
                icon: const Icon(Icons.edit_rounded,
                    size: 16, color: AppColors.green),
                label: const Text(
                  '기술 스택 편집',
                  style: TextStyle(color: AppColors.green, fontSize: 13),
                ),
              ),
          ],
        ),
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
