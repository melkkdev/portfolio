import 'package:flutter/material.dart';
import '../core/common/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../features/home/portfolio_page.dart';

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      theme: AppTheme.theme,
      home: const PortfolioPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
