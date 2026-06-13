import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/portfolio_data.dart';
import 'skill_chip.dart';

class SkillGroupRow extends StatelessWidget {
  final SkillGroupData data;

  const SkillGroupRow({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                data.label,
                style: AppTheme.mono(
                  fontSize: 11,
                  color: AppColors.muted,
                  letterSpacing: 0.05,
                ),
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.skills
                  .map((s) => SkillChip(
                        label: s,
                        isHighlight: data.highlights.contains(s),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
