import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SkillChip extends StatelessWidget {
  final String label;
  final bool isHighlight;

  const SkillChip({super.key, required this.label, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlight ? AppColors.accentSoft : AppColors.lineSoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: isHighlight
              ? AppColors.accent.withValues(alpha: 0.35)
              : AppColors.line,
        ),
      ),
      child: Text(
        label,
        style: AppTheme.mono(
          fontSize: 12,
          fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
          color: isHighlight ? AppColors.accentDeep : AppColors.inkSoft,
        ),
      ),
    );
  }
}
