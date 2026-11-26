import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/common/spacing.dart';
import '../../../core/theme/app_theme.dart';

class NavItem {
  final String label;
  final GlobalKey target;
  const NavItem(this.label, this.target);
}

/// 상단 고정 헤더: 로고 · 섹션 이동 메뉴 · GitHub 버튼
class SiteHeader extends StatelessWidget {
  final String name;
  final String githubUrl;
  final List<NavItem> items;
  final VoidCallback onLogoTap;

  const SiteHeader({
    super.key,
    required this.name,
    required this.githubUrl,
    required this.items,
    required this.onLogoTap,
  });

  static void scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width < Spacing.mobileBreakpoint;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: Spacing.headerHeight,
          color: AppColors.bg.withValues(alpha: 0.78),
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
          child: Row(
            children: [
              InkWell(
                onTap: onLogoTap,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        name.isNotEmpty ? name.characters.last : '',
                        style: AppTheme.display(
                            fontSize: 16, color: Colors.white, height: 1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(name, style: AppTheme.display(fontSize: 19)),
                  ],
                ),
              ),
              const Spacer(),
              if (!isMobile) ...[
                for (final item in items)
                  TextButton(
                    onPressed: () => scrollTo(item.target),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.inkSoft,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    child: Text(item.label,
                        style: const TextStyle(fontSize: 14)),
                  ),
                const Spacer(),
              ],
              Material(
                color: AppColors.dark,
                shape: const StadiumBorder(),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: () => launchUrl(Uri.parse(githubUrl)),
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.code_rounded,
                            size: 15, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'GitHub',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
