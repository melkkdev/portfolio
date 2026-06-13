import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String num;
  final String title;

  const SectionHeader({super.key, required this.num, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          num,
          style: AppTheme.mono(
            fontSize: 13,
            color: AppColors.green,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.26,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}
