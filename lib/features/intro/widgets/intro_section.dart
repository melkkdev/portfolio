import 'package:flutter/material.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/cards/surface_card.dart';
import '../../../core/design/shared/section_header.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/portfolio_scope.dart';
import '../../admin/admin_scope.dart';
import '../../admin/widgets/edit_intro_dialog.dart';

class IntroSection extends StatelessWidget {
  const IntroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final paragraphs = PortfolioScope.of(context).intro;
    final isAdmin = AdminScope.isAdmin(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: SectionHeader(num: '01', title: '소개')),
            if (isAdmin)
              _EditButton(
                onTap: () => EditIntroDialog.show(
                  context,
                  paragraphs: paragraphs,
                  onSaved: PortfolioScope.reloadOf(context),
                ),
              ),
          ],
        ),
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

class _EditButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EditButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.edit_rounded, size: 14, color: AppColors.green),
      label: const Text(
        '편집',
        style: TextStyle(color: AppColors.green, fontSize: 13),
      ),
    );
  }
}
