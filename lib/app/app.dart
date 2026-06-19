import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../data/portfolio_provider.dart';
import '../features/home/portfolio_page.dart';

class PortfolioApp extends ConsumerWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsync = ref.watch(portfolioProvider);

    return portfolioAsync.when(
      data: (state) => MaterialApp(
        title: state.profile.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const PortfolioPage(),
      ),
      loading: () => MaterialApp(
        title: 'Portfolio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const _LoadingScreen(),
      ),
      error: (error, stackTrace) => MaterialApp(
        title: 'Portfolio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const _ErrorScreen(),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(child: CircularProgressIndicator(color: AppColors.muted)),
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
