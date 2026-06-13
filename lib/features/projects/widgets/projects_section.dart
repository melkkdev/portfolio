import 'package:flutter/material.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/shared/section_header.dart';
import '../../../data/portfolio_scope.dart';
import 'project_card.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = PortfolioScope.of(context).projects;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(num: '04', title: '대표 프로젝트'),
        const SizedBox(height: Spacing.lg),
        ...projects.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ProjectCard(project: p),
          ),
        ),
      ],
    );
  }
}
