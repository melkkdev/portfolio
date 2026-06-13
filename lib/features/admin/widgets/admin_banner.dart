import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/portfolio_scope.dart';
import '../../../data/repository/portfolio_repository.dart';
import '../admin_scope.dart';

class AdminBanner extends StatefulWidget {
  const AdminBanner({super.key});

  @override
  State<AdminBanner> createState() => _AdminBannerState();
}

class _AdminBannerState extends State<AdminBanner> {
  bool _migrating = false;

  @override
  Widget build(BuildContext context) {
    if (!AdminScope.isAdmin(context)) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: AppColors.green,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '관리자 모드 — 각 섹션의 ✏️ 버튼으로 편집하세요',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // 회사명 "(Poien)→(fouren)" 1회성 마이그레이션 버튼
          TextButton(
            onPressed: _migrating ? null : _runMigration,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: _migrating
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Poien→fouren 수정',
                    style: TextStyle(fontSize: 11),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _runMigration() async {
    setState(() => _migrating = true);
    try {
      final count = await PortfolioRepository.fixCompanyName();
      if (!mounted) return;
      if (count > 0) await PortfolioScope.reloadOf(context)();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(count > 0 ? '$count개 프로젝트 업데이트 완료' : '변경 없음 (이미 최신)'),
          backgroundColor: AppColors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('마이그레이션 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _migrating = false);
    }
  }
}
