import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../admin_provider.dart';
import '../admin_service.dart';
import 'login_dialog.dart';

class AdminFab extends ConsumerStatefulWidget {
  const AdminFab({super.key});

  @override
  ConsumerState<AdminFab> createState() => _AdminFabState();
}

class _AdminFabState extends ConsumerState<AdminFab> {
  bool _exiting = false;

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(adminProvider.select((s) => s.isAdmin));

    if (isAdmin) {
      return FloatingActionButton.extended(
        onPressed: _exiting
            ? null
            : () async {
                setState(() => _exiting = true);
                try {
                  await ref.read(adminProvider.notifier).exit();
                  if (mounted) AdminService.signOut();
                } finally {
                  if (mounted) setState(() => _exiting = false);
                }
              },
        backgroundColor: _exiting ? AppColors.inkSoft : AppColors.green,
        icon: _exiting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.lock_open_rounded, color: Colors.white),
        label: Text(
          _exiting ? '저장 중...' : '관리자 모드 종료',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Opacity(
      opacity: 0.35,
      child: FloatingActionButton.small(
        onPressed: () => LoginDialog.show(context),
        backgroundColor: AppColors.inkSoft,
        child: const Icon(Icons.lock_rounded, color: Colors.white, size: 18),
      ),
    );
  }
}
