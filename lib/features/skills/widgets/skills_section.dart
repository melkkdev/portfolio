import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/shared/reveal.dart';
import '../../../core/design/shared/section_band.dart';
import '../../../core/design/shared/section_header.dart';
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

    return SectionBand(
      tinted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Reveal(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                    child: SectionHeader(num: '02', title: '기술 스택')),
                if (isAdmin)
                  AdminTextButton(
                    label: '기술 스택 편집',
                    onPressed: () => EditSkillsDialog.show(
                      context,
                      groups: skills,
                      onSaved: ref.read(portfolioProvider.notifier).reload,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 20.0;
              final columns = constraints.maxWidth >= 680 ? 2 : 1;
              final cardWidth =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final (i, g) in skills.indexed)
                    SizedBox(
                      width: cardWidth,
                      child: Reveal(
                        delay: Duration(milliseconds: 80 * (i % columns)),
                        child: SkillGroupCard(data: g, index: i),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
