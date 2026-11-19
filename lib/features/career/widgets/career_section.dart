import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/shared/reveal.dart';
import '../../../core/design/shared/section_band.dart';
import '../../../core/design/shared/section_header.dart';
import '../../../data/portfolio_provider.dart';
import '../../admin/admin_provider.dart';
import '../../admin/widgets/edit_career_dialog.dart';
import 'career_card.dart';

class CareerSection extends ConsumerWidget {
  const CareerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final careers = ref.watch(portfolioProvider).requireValue.careers;
    final isAdmin = ref.watch(adminProvider.select((s) => s.isAdmin));

    return SectionBand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Reveal(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(child: SectionHeader(num: '03', title: '경력')),
                if (isAdmin)
                  AdminTextButton(
                    label: '경력 편집',
                    onPressed: () => EditCareerDialog.show(
                      context,
                      careers: careers,
                      onSaved: ref.read(portfolioProvider.notifier).reload,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),
          for (final (i, c) in careers.indexed)
            Reveal(
              child: CareerTimelineItem(
                career: c,
                isFirst: i == 0,
                isLast: i == careers.length - 1,
              ),
            ),
        ],
      ),
    );
  }
}
