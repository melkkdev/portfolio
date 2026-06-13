import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/common/app_constants.dart';
import '../../../core/common/image_paths.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/cards/surface_card.dart';
import '../../../core/theme/app_theme.dart';
import 'phone_mockup.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return SurfaceCard(
      padding: const EdgeInsets.all(Spacing.xl),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroLeft(),
                const SizedBox(height: 32),
                _HeroPhones(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _HeroLeft()),
                const SizedBox(width: 36),
                SizedBox(width: 300, child: _HeroPhones()),
              ],
            ),
    );
  }
}

class _HeroLeft extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConstants.role,
          style: AppTheme.mono(
            fontSize: 12,
            color: AppColors.muted,
            letterSpacing: 2.64,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          AppConstants.name,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: AppColors.green,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          AppConstants.tagline,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.56,
            height: 1.28,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 22,
          runSpacing: 10,
          children: [
            const Text(
              AppConstants.careerYears,
              style: TextStyle(fontSize: 14, color: AppColors.inkSoft),
            ),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse(AppConstants.githubUrl)),
              child: const Text(
                '🔗 ${AppConstants.githubDisplayUrl}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroPhones extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 30,
            child: PhoneMockup(imagePath: ImagePaths.copickHero[0], rotateDeg: -7),
          ),
          Positioned(
            left: 78,
            top: 8,
            child: PhoneMockup(imagePath: ImagePaths.copickHero[1], rotateDeg: 4),
          ),
          Positioned(
            right: -16,
            top: 38,
            child: PhoneMockup(imagePath: ImagePaths.copickHero[2], rotateDeg: 9),
          ),
        ],
      ),
    );
  }
}
