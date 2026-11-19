import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/portfolio_provider.dart';
import '../../features/admin/widgets/admin_banner.dart';
import '../../features/admin/widgets/admin_fab.dart';
import '../../features/admin/widgets/project_reorder_panel.dart';
import '../../features/career/widgets/career_section.dart';
import '../../features/hero/widgets/hero_section.dart';
import '../../features/intro/widgets/intro_section.dart';
import '../../features/projects/widgets/projects_section.dart';
import '../../features/skills/widgets/skills_section.dart';
import 'widgets/site_footer.dart';
import 'widgets/site_header.dart';

class PortfolioPage extends ConsumerStatefulWidget {
  const PortfolioPage({super.key});

  @override
  ConsumerState<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends ConsumerState<PortfolioPage> {
  final _scroll = ScrollController();
  final _introKey = GlobalKey();
  final _skillsKey = GlobalKey();
  final _careerKey = GlobalKey();
  final _projectsKey = GlobalKey();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(portfolioProvider).requireValue.profile;

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
                  controller: _scroll,
                  child: Column(
                    children: [
                      const HeroSection(),
                      KeyedSubtree(key: _introKey, child: const IntroSection()),
                      KeyedSubtree(
                          key: _skillsKey, child: const SkillsSection()),
                      // 띠 섹션 사이의 크림 배경이 이어지도록 감싼다
                      ColoredBox(
                        color: AppColors.band,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(AppRadius.band),
                            ),
                          ),
                          child: KeyedSubtree(
                              key: _careerKey, child: const CareerSection()),
                        ),
                      ),
                      KeyedSubtree(
                          key: _projectsKey, child: const ProjectsSection()),
                      SiteFooter(
                        name: profile.name,
                        githubUrl: profile.githubUrl,
                        githubDisplayUrl: profile.githubDisplayUrl,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SiteHeader(
                    name: profile.name,
                    githubUrl: profile.githubUrl,
                    onLogoTap: () => _scroll.animateTo(
                      0,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOutCubic,
                    ),
                    items: [
                      NavItem('소개', _introKey),
                      NavItem('기술 스택', _skillsKey),
                      NavItem('경력', _careerKey),
                      NavItem('프로젝트', _projectsKey),
                    ],
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
