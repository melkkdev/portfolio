import 'package:flutter/material.dart';
import '../../core/common/spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../features/admin/widgets/admin_banner.dart';
import '../../features/admin/widgets/admin_fab.dart';
import '../../features/admin/widgets/project_reorder_panel.dart';
import '../../features/hero/widgets/hero_section.dart';
import '../../features/intro/widgets/intro_section.dart';
import '../../features/skills/widgets/skills_section.dart';
import '../../features/career/widgets/career_section.dart';
import '../../features/projects/widgets/projects_section.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      floatingActionButton: const AdminFab(),
      body: Column(
        children: [
          const AdminBanner(),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: Spacing.pageMaxWidth),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.pagePadding,
                          vertical: 48,
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HeroSection(),
                            SizedBox(height: Spacing.sectionGap),
                            IntroSection(),
                            SizedBox(height: Spacing.sectionGap),
                            SkillsSection(),
                            SizedBox(height: Spacing.sectionGap),
                            CareerSection(),
                            SizedBox(height: Spacing.sectionGap),
                            ProjectsSection(),
                            SizedBox(height: 48),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // 관리자 모드 시 우측에 드래그 순서 패널
                const Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  child: ProjectReorderPanel(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
