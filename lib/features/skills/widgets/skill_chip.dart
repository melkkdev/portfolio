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
        color: isHighlight ? AppColors.greenLight : AppColors.lineSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHighlight
              ? AppColors.green.withValues(alpha: 0.3)
              : AppColors.line,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
          color: isHighlight ? AppColors.greenDeep : AppColors.inkSoft,
        ),
      ),
    );
  }
}
