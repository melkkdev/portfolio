import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../admin_scope.dart';
import '../admin_service.dart';
import 'login_dialog.dart';

class AdminFab extends StatelessWidget {
  const AdminFab({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = AdminScope.isAdmin(context);

    if (isAdmin) {
      return FloatingActionButton.extended(
        onPressed: () {
          // exit()이 order 저장을 처리한 뒤 admin 상태를 해제함
          AdminScope.of(context).exit().then((_) => AdminService.signOut());
        },
        backgroundColor: AppColors.green,
        icon: const Icon(Icons.lock_open_rounded, color: Colors.white),
        label: const Text(
          '관리자 모드 종료',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
