import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/design/cards/surface_card.dart';
import '../../../core/design/shared/styled_text.dart';
import '../../../data/models/career_model.dart';

class CareerCard extends StatelessWidget {
  final CareerModel career;

  const CareerCard({super.key, required this.career});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  career.company,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                career.period,
                style: AppTheme.mono(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          StyledText(
            text: career.role,
            baseStyle: const TextStyle(fontSize: 13, color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.line, height: 1),
          const SizedBox(height: 16),
          ...career.bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 8, right: 10),
                    child: CircleAvatar(
                      radius: 3,
                      backgroundColor: AppColors.green,
                    ),
                  ),
                  Expanded(
                    child: StyledText(
                      text: b,
                      baseStyle: const TextStyle(
                        fontSize: 14,
                        color: AppColors.inkSoft,
                        height: 1.65,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
