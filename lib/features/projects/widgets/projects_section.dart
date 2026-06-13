import 'package:flutter/material.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/shared/section_header.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/portfolio_scope.dart';
import '../../admin/admin_scope.dart';
import '../../admin/widgets/edit_project_dialog.dart';
import 'project_card.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = PortfolioScope.of(context).projects;
    final isAdmin = AdminScope.isAdmin(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
                child: SectionHeader(num: '04', title: '대표 프로젝트')),
            if (isAdmin)
              TextButton.icon(
                onPressed: () => EditProjectDialog.show(
                  context,
                  allProjects: projects,
                  onSaved: PortfolioScope.reloadOf(context),
                ),
                icon: const Icon(Icons.add_rounded,
                    size: 16, color: AppColors.green),
                label: const Text(
                  '프로젝트 추가',
                  style: TextStyle(color: AppColors.green, fontSize: 13),
                ),
              ),
          ],
        ),
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
