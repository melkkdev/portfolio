import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/project_model.dart';

/// 프로젝트 카드 안의 숫자 타일 (Firestore 프로젝트 stats 값)
class StatItem extends StatelessWidget {
  final StatModel data;

  const StatItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isLong = data.value.length > 8;
    return Container(
      constraints: const BoxConstraints(minWidth: 84),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.peach,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.value,
            style: AppTheme.display(
              fontSize: isLong ? 16 : 24,
              color: AppColors.ink,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
