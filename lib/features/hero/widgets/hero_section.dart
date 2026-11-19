import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/shared/reveal.dart';
import '../../../core/pdf/pdf_export_dialog.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/portfolio_provider.dart';
import '../../admin/admin_provider.dart';
import '../../admin/widgets/edit_profile_dialog.dart';
import 'phone_mockup.dart';

/// 이름 끝 글자에 받침이 있으면 "이에요", 없으면 "예요"
String nameWithCopula(String name) {
  if (name.isEmpty) return name;
  final code = name.runes.last;
  if (code < 0xAC00 || code > 0xD7A3) return '$name이에요';
  final hasBatchim = (code - 0xAC00) % 28 != 0;
  return hasBatchim ? '$name이에요' : '$name예요';
}

class HeroSection extends ConsumerWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(portfolioProvider).requireValue;
    final profile = state.profile;
    final isAdmin = ref.watch(adminProvider.select((s) => s.isAdmin));
    final isMobile =
        MediaQuery.sizeOf(context).width < Spacing.mobileBreakpoint;

    void openPdf() => showPortfolioPdfPreview(context, state);

    final left = _HeroText(profile: profile, onDownloadPdf: openPdf);
    final phones = _HeroPhones(
      imageUrls: profile.heroImageUrls,
      scale: isMobile ? 0.78 : 1,
    );

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF4E8), Color(0xFFFDEBDD), Color(0xFFFFF6EC)],
        ),
      ),
      child: Stack(
        children: [
          // 흐릿한 색 덩어리 배경
          const Positioned(
              left: -160, top: 220, child: _Blob(color: Color(0x33F28B6B))),
          const Positioned(
              right: -120, top: -80, child: _Blob(color: Color(0x40FBC896))),
          Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: Spacing.pageMaxWidth),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Spacing.pagePadding,
                  Spacing.headerHeight + (isMobile ? 40 : 72),
                  Spacing.pagePadding,
                  isMobile ? 56 : 88,
                ),
                child: Reveal(
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            left,
                            const SizedBox(height: 48),
                            Center(child: phones),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: left),
                            const SizedBox(width: 24),
                            phones,
                          ],
                        ),
                ),
              ),
            ),
          ),
          if (isAdmin)
            Positioned(
              top: Spacing.headerHeight + 12,
              right: 16,
              child: _AdminEditButton(
                onTap: () => EditProfileDialog.show(
                  context,
                  profile: profile,
                  onSaved: ref.read(portfolioProvider.notifier).reload,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  const _Blob({required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 460,
        height: 460,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

class _AdminEditButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AdminEditButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accent,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

class _HeroText extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onDownloadPdf;

  const _HeroText({required this.profile, required this.onDownloadPdf});

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width < Spacing.mobileBreakpoint;
    final titleSize = isMobile ? 40.0 : 56.0;
    final greeting = nameWithCopula(profile.name);
    final suffix = greeting.substring(profile.name.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 역할 알약
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.sage,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  [profile.role, profile.careerYears]
                      // 저장된 값 앞의 "●" 같은 장식 기호는 떼고 쓴다
                      .map((s) => s.replaceFirst(RegExp(r'^[\s•●·\-]+'), ''))
                      .where((s) => s.isNotEmpty)
                      .join(' · '),
                  style: AppTheme.mono(
                    fontSize: 12,
                    color: AppColors.accentDeep,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('안녕하세요,', style: AppTheme.display(fontSize: titleSize)),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: profile.name,
                style: AppTheme.display(
                  fontSize: titleSize,
                  color: AppColors.accent,
                ),
              ),
              TextSpan(
                text: suffix,
                style: AppTheme.display(fontSize: titleSize),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          profile.tagline,
          style: const TextStyle(
            fontSize: 18,
            height: 1.6,
            color: AppColors.inkSoft,
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _PillButton(
              icon: Icons.description_outlined,
              label: '이력서 PDF',
              filled: true,
              onTap: onDownloadPdf,
            ),
            _PillButton(
              icon: Icons.code_rounded,
              label: 'GitHub',
              filled: false,
              onTap: () => launchUrl(Uri.parse(profile.githubUrl)),
            ),
          ],
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _PillButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : AppColors.ink;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: filled
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: filled ? AppColors.accent : Colors.white,
        shape: StadiumBorder(
          side: filled
              ? BorderSide.none
              : const BorderSide(color: AppColors.line),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 17, color: fg),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 가운데 폰을 크게, 양옆 폰을 기울여 겹친 배치
class _HeroPhones extends StatelessWidget {
  final List<String> imageUrls;
  final double scale;

  const _HeroPhones({required this.imageUrls, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    final side = (w: 150.0 * scale, h: 320.0 * scale);
    final main = (w: 190.0 * scale, h: 400.0 * scale);
    final totalWidth = 440.0 * scale;
    final totalHeight = 430.0 * scale;

    if (imageUrls.length < 3) {
      return SizedBox(
        width: totalWidth,
        height: totalHeight,
        child: Center(
          child: PhoneMockup(
              imageUrl: imageUrls.first, width: main.w, height: main.h),
        ),
      );
    }

    return SizedBox(
      width: totalWidth,
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 50 * scale,
            child: PhoneMockup(
              imageUrl: imageUrls[0],
              rotateDeg: -9,
              width: side.w,
              height: side.h,
            ),
          ),
          Positioned(
            right: 0,
            top: 50 * scale,
            child: PhoneMockup(
              imageUrl: imageUrls[2],
              rotateDeg: 9,
              width: side.w,
              height: side.h,
            ),
          ),
          Positioned(
            left: (totalWidth - main.w) / 2,
            top: 0,
            child: PhoneMockup(
              imageUrl: imageUrls[1],
              width: main.w,
              height: main.h,
            ),
          ),
        ],
      ),
    );
  }
}
