import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/common/spacing.dart';
import '../../../core/theme/app_theme.dart';

class SiteFooter extends StatelessWidget {
  final String name;
  final String githubUrl;
  final String githubDisplayUrl;

  const SiteFooter({
    super.key,
    required this.name,
    required this.githubUrl,
    required this.githubDisplayUrl,
  });

  @override
  Widget build(BuildContext context) {
    const faint = Color(0xFFB9A89C);

    return Container(
      width: double.infinity,
      color: AppColors.dark,
      padding: const EdgeInsets.symmetric(vertical: 72),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Spacing.pageMaxWidth),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: Spacing.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '함께 따뜻한 앱을 만들어요',
                  style: AppTheme.display(fontSize: 34, color: Colors.white),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => launchUrl(Uri.parse(githubUrl)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.code_rounded,
                          size: 16, color: Color(0xFFF2A673)),
                      const SizedBox(width: 8),
                      Text(
                        githubDisplayUrl,
                        style: const TextStyle(
                          color: Color(0xFFF2A673),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Divider(color: Colors.white.withValues(alpha: 0.12)),
                const SizedBox(height: 20),
                Text(
                  '© ${DateTime.now().year} $name. All rights reserved.',
                  style: const TextStyle(color: faint, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
