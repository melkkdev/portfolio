import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/cards/surface_card.dart';
import '../../../core/design/shared/section_header.dart';
import '../../../core/design/shared/styled_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/portfolio_provider.dart';
import '../../admin/admin_provider.dart';
import '../../admin/widgets/edit_intro_dialog.dart';

class IntroSection extends ConsumerWidget {
  const IntroSection({super.key});

  static const _baseStyle = TextStyle(
    fontSize: 15,
    color: AppColors.inkSoft,
    height: 1.8,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paragraphs = ref.watch(portfolioProvider).requireValue.intro;
    final isAdmin = ref.watch(adminProvider.select((s) => s.isAdmin));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: SectionHeader(num: '01', title: '소개')),
            if (isAdmin)
              TextButton.icon(
                onPressed: () => EditIntroDialog.show(
                  context,
                  paragraphs: paragraphs,
                  onSaved: ref.read(portfolioProvider.notifier).reload,
                ),
                icon: const Icon(Icons.edit_rounded,
                    size: 14, color: AppColors.green),
                label: const Text('편집',
                    style: TextStyle(color: AppColors.green, fontSize: 13)),
              ),
          ],
        ),
        const SizedBox(height: Spacing.lg),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: paragraphs
                .expand((text) => [
                      StyledText(text: text, baseStyle: _baseStyle),
                      const SizedBox(height: 16),
                    ])
                .toList()
              ..removeLast(),
          ),
        ),
      ],
    );
  }
}
