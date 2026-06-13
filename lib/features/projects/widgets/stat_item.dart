import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/project_model.dart';

class StatItem extends StatelessWidget {
  final StatModel data;

  const StatItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isLong = data.value.length > 8;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.value,
          style: TextStyle(
            fontSize: isLong ? 15 : 22,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: -0.5,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          data.label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.muted,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
