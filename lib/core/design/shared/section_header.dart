import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// "01" 코랄 알약 + 둥근 제목
class SectionHeader extends StatelessWidget {
  final String num;
  final String title;

  const SectionHeader({super.key, required this.num, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            num,
            style: AppTheme.mono(
              fontSize: 11,
              color: AppColors.accentDeep,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(title, style: AppTheme.display(fontSize: 36)),
      ],
    );
  }
}
