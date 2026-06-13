import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/design/cards/surface_card.dart';
import '../../../core/design/shared/info_row.dart';
import '../../../data/models/project_model.dart';
import '../../../data/portfolio_scope.dart';
import '../../../data/repository/portfolio_repository.dart';
import '../../admin/admin_scope.dart';
import '../../admin/widgets/edit_project_dialog.dart';
import 'desktop_gallery.dart';
import 'phone_gallery.dart';
import 'stat_item.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final isAdmin = AdminScope.isAdmin(context);

    return Stack(
      children: [
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.eyebrow,
                style: AppTheme.mono(fontSize: 11, color: AppColors.muted),
              ),
              const SizedBox(height: 8),
              Text(
                project.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              if (project.summary.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  project.summary,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.inkSoft,
                    height: 1.75,
                  ),
                ),
              ],
              if (project.imageUrls.isNotEmpty) ...[
                const SizedBox(height: 24),
                project.isDesktop
                    ? DesktopGallery(imageUrls: project.imageUrls)
                    : PhoneGallery(imageUrls: project.imageUrls),
              ],
              const SizedBox(height: 24),
              const Divider(color: AppColors.line, height: 1),
              const SizedBox(height: 16),
              ...project.rows.map(
                (r) => InfoRow(label: r.label, value: r.value, url: r.url),
              ),
              if (project.stats.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Divider(color: AppColors.line, height: 1),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 32,
                  runSpacing: 16,
                  children:
                      project.stats.map((s) => StatItem(data: s)).toList(),
                ),
              ],
            ],
          ),
        ),
        if (isAdmin)
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionButton(
                  icon: Icons.edit_rounded,
                  color: AppColors.green,
                  label: '편집',
                  onTap: () => EditProjectDialog.show(
                    context,
                    project: project,
                    allProjects: PortfolioScope.of(context).projects,
                    onSaved: PortfolioScope.reloadOf(context),
                  ),
                ),
                const SizedBox(width: 6),
                _ActionButton(
                  icon: Icons.delete_rounded,
                  color: Colors.red,
                  label: '삭제',
                  onTap: () => _confirmDelete(context),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final reload = PortfolioScope.reloadOf(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('프로젝트 삭제',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          "'${project.title}'을(를) 삭제하시겠습니까?",
          style: const TextStyle(color: AppColors.inkSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await PortfolioRepository.deleteProject(project.id);
      await reload();
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
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
