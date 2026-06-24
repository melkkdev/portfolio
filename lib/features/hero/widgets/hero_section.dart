import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/cards/surface_card.dart';
import '../../../core/pdf/pdf_export_dialog.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/portfolio_provider.dart';
import '../../admin/admin_provider.dart';
import '../../admin/widgets/edit_profile_dialog.dart';
import 'phone_mockup.dart';

class HeroSection extends ConsumerWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(portfolioProvider).requireValue;
    final profile = state.profile;
    final isAdmin = ref.watch(adminProvider.select((s) => s.isAdmin));
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Stack(
      children: [
        SurfaceCard(
          padding: const EdgeInsets.all(Spacing.xl),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroLeft(
                      profile: profile,
                      onDownloadPdf: () =>
                          showPortfolioPdfPreview(context, state),
                    ),
                    const SizedBox(height: 32),
                    _HeroPhones(imageUrls: profile.heroImageUrls),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _HeroLeft(
                        profile: profile,
                        onDownloadPdf: () =>
                            showPortfolioPdfPreview(context, state),
                      ),
                    ),
                    const SizedBox(width: 36),
                    SizedBox(
                      width: 300,
                      child: _HeroPhones(imageUrls: profile.heroImageUrls),
                    ),
                  ],
                ),
        ),
        if (isAdmin)
          Positioned(
            top: 8,
            right: 8,
            child: _AdminEditButton(
              onTap: () => EditProfileDialog.show(
                context,
                profile: profile,
                onSaved: ref.read(portfolioProvider.notifier).reload,
              ),
            ),
          ),
      ],
    );
  }
}

class _AdminEditButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AdminEditButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.green,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_rounded, size: 14, color: Colors.white),
              SizedBox(width: 4),
              Text(
                '편집',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroLeft extends StatelessWidget {
  final dynamic profile;
  final VoidCallback onDownloadPdf;

  const _HeroLeft({required this.profile, required this.onDownloadPdf});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          profile.role,
          style: AppTheme.mono(
            fontSize: 12,
            color: AppColors.muted,
            letterSpacing: 2.64,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          profile.name,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: AppColors.green,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          profile.tagline,
          style: const TextStyle(
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
            Text(
              profile.careerYears,
              style: const TextStyle(fontSize: 14, color: AppColors.inkSoft),
            ),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse(profile.githubUrl)),
              child: Text(
                '🔗 ${profile.githubDisplayUrl}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _PdfDownloadButton(onTap: onDownloadPdf),
      ],
    );
  }
}

class _PdfDownloadButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PdfDownloadButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.greenLight,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.picture_as_pdf_rounded,
                  size: 16, color: AppColors.greenDeep),
              SizedBox(width: 6),
              Text(
                'PDF 다운로드',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.greenDeep,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroPhones extends StatelessWidget {
  final List<String> imageUrls;

  const _HeroPhones({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    if (imageUrls.length < 3) return const SizedBox.shrink();

    return SizedBox(
      height: 300,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 30,
            child: PhoneMockup(imageUrl: imageUrls[0], rotateDeg: -7),
          ),
          Positioned(
            left: 78,
            top: 8,
            child: PhoneMockup(imageUrl: imageUrls[1], rotateDeg: 4),
          ),
          Positioned(
            right: -16,
            top: 38,
            child: PhoneMockup(imageUrl: imageUrls[2], rotateDeg: 9),
          ),
        ],
      ),
    );
  }
}
