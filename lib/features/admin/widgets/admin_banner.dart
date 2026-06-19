import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../admin_provider.dart';

class AdminBanner extends ConsumerWidget {
  const AdminBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(adminProvider.select((s) => s.isAdmin));
    if (!isAdmin) return const SizedBox.shrink();

    final version = ref.watch(appVersionProvider).value;

    return Container(
      width: double.infinity,
      color: AppColors.green,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
          const SizedBox(width: 8),
          const Text(
            '관리자 모드 — 각 섹션의 ✏️ 버튼으로 편집하세요',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (version != null) ...[
            const SizedBox(width: 8),
            Text(
              '· $version',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
