import 'package:flutter/material.dart';
import '../../common/spacing.dart';
import '../../theme/app_theme.dart';

/// 화면 전체 폭의 섹션 띠. 안쪽 내용은 [Spacing.pageMaxWidth]로 가운데 정렬한다.
/// [tinted]이면 피치 크림 배경에 위쪽 모서리를 크게 둥글린다.
class SectionBand extends StatelessWidget {
  final Widget child;
  final bool tinted;

  const SectionBand({super.key, required this.child, this.tinted = false});

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width < Spacing.mobileBreakpoint;
    final vertical =
        isMobile ? Spacing.sectionVertical * 0.6 : Spacing.sectionVertical;

    return Container(
      width: double.infinity,
      decoration: tinted
          ? const BoxDecoration(
              color: AppColors.band,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.band),
              ),
            )
          : null,
      padding: EdgeInsets.symmetric(vertical: vertical),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Spacing.pageMaxWidth),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: Spacing.pagePadding),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 섹션 제목 줄 오른쪽에 붙는 관리자 편집 버튼
class AdminTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  const AdminTextButton({
    super.key,
    required this.onPressed,
    this.label = '편집',
    this.icon = Icons.edit_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: AppColors.accent),
      label: Text(
        label,
        style: const TextStyle(color: AppColors.accent, fontSize: 13),
      ),
    );
  }
}
