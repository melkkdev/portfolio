import 'package:flutter/material.dart';
import '../../../core/design/cards/surface_card.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/skill_model.dart';
import 'skill_chip.dart';

/// 기술 그룹 하나를 담는 카드 (아이콘 + 그룹명 + 칩)
class SkillGroupCard extends StatelessWidget {
  final SkillGroupModel data;
  final int index;

  const SkillGroupCard({super.key, required this.data, this.index = 0});

  static const _tints = [
    (bg: AppColors.accentSoft, fg: AppColors.accentDeep),
    (bg: AppColors.peach, fg: Color(0xFFB8732E)),
    (bg: AppColors.sageSoft, fg: AppColors.sage),
  ];

  static IconData _iconFor(String label) {
    final l = label.toLowerCase();
    if (l.contains('mobile') || l.contains('모바일') || l.contains('app')) {
      return Icons.phone_iphone_rounded;
    }
    if (l.contains('front') || l.contains('web') || l.contains('웹')) {
      return Icons.web_rounded;
    }
    if (l.contains('back') || l.contains('server') || l.contains('서버')) {
      return Icons.dns_rounded;
    }
    if (l.contains('db') || l.contains('data') || l.contains('데이터')) {
      return Icons.storage_rounded;
    }
    if (l.contains('tool') || l.contains('도구') || l.contains('협업')) {
      return Icons.handyman_rounded;
    }
    return Icons.auto_awesome_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final tint = _tints[index % _tints.length];

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tint.bg,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(_iconFor(data.label), size: 20, color: tint.fg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(data.label, style: AppTheme.display(fontSize: 22)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: data.skills
                .map((s) => SkillChip(
                      label: s,
                      isHighlight: data.highlights.contains(s),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
