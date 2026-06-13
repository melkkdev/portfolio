import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data/portfolio_scope.dart';
import '../data/portfolio_state.dart';
import '../data/repository/portfolio_repository.dart';
import '../features/admin/admin_scope.dart';
import '../features/home/portfolio_page.dart';

class PortfolioApp extends StatefulWidget {
  final PortfolioState? initialState;

  const PortfolioApp({super.key, PortfolioState? state}) : initialState = state;

  @override
  State<PortfolioApp> createState() => _PortfolioAppState();
}

class _PortfolioAppState extends State<PortfolioApp> {
  PortfolioState? _state;
  late final AdminNotifier _adminNotifier;

  @override
  void initState() {
    super.initState();
    _state = widget.initialState;
    _adminNotifier = AdminNotifier(_handleAdminExit);
  }

  Future<void> _handleAdminExit(List<String>? pendingOrderIds) async {
    if (pendingOrderIds == null || pendingOrderIds.isEmpty || _state == null) {
      return;
    }
    final idToProject = {for (final p in _state!.projects) p.id: p};
    final reordered = pendingOrderIds.asMap().entries
        .where((e) => idToProject.containsKey(e.value))
        .map((e) => idToProject[e.value]!.copyWith(order: e.key))
        .toList();
    try {
      await PortfolioRepository.saveProjects(reordered);
      await _reload();
    } catch (e) {
      debugPrint('order save failed: $e');
    }
  }

  @override
  void dispose() {
    _adminNotifier.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    try {
      final next = await PortfolioState.load();
      if (mounted) setState(() => _state = next);
    } catch (e) {
      debugPrint('reload failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_state == null) {
      return MaterialApp(
        title: 'Portfolio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const _ErrorScreen(),
      );
    }

    return AdminScope(
      notifier: _adminNotifier,
      child: PortfolioScope(
        data: _state!,
        onReload: _reload,
        child: MaterialApp(
          title: _state!.profile.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          home: const PortfolioPage(),
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.muted),
            SizedBox(height: 16),
            Text(
              'Firestore 데이터를 불러오지 못했습니다.\nFirebase 콘솔에서 데이터를 확인해 주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.inkSoft, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
