import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../admin_scope.dart';

class AdminBanner extends StatelessWidget {
  const AdminBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AdminScope.isAdmin(context)) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: AppColors.green,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_rounded, size: 14, color: Colors.white),
          SizedBox(width: 8),
          Text(
            '관리자 모드 — 각 섹션의 ✏️ 버튼으로 편집하세요',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
