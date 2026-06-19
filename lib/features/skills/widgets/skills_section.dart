import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/cards/surface_card.dart';
import '../../../core/design/shared/section_header.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/portfolio_provider.dart';
import '../../admin/admin_provider.dart';
import '../../admin/widgets/edit_skills_dialog.dart';
import 'skill_group_row.dart';

class SkillsSection extends ConsumerWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skills = ref.watch(portfolioProvider).requireValue.skills;
    final isAdmin = ref.watch(adminProvider.select((s) => s.isAdmin));

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
                  onSaved: ref.read(portfolioProvider.notifier).reload,
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
