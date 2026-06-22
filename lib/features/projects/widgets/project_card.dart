import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/design/cards/surface_card.dart';
import '../../../core/design/shared/image_viewer.dart';
import '../../../core/design/shared/info_row.dart';
import '../../../data/models/project_model.dart';
import '../../../data/portfolio_provider.dart';
import '../../../data/repository/portfolio_repository.dart';
import '../../admin/admin_provider.dart';
import '../../admin/widgets/edit_project_dialog.dart';
import 'desktop_gallery.dart';
import 'phone_gallery.dart';
import 'stat_item.dart';

class ProjectCard extends ConsumerWidget {
  final ProjectModel project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(adminProvider.select((s) => s.isAdmin));
    final rows = project.rows;

    return Stack(
      children: [
        SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 그린 배너 헤더 ──────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                decoration: const BoxDecoration(
                  color: AppColors.green,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.eyebrow,
                      style: AppTheme.mono(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    if (project.summary.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        project.summary,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.7,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── 갤러리 ───────────────────────────────────────────
              if (project.imageUrls.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Stack(
                    children: [
                      project.isLandscape
                          ? LandscapeGallery(imageUrls: project.imageUrls)
                          : PortraitGallery(imageUrls: project.imageUrls),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: _ExpandButton(
                          onTap: () => showImageViewer(
                            context,
                            imageUrls: project.imageUrls,
                            initialIndex: 0,
                            title: project.eyebrow,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── 상세 정보 ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < rows.length; i++)
                      InfoRow(
                        label: rows[i].label,
                        value: rows[i].value,
                        url: rows[i].url,
                        showDivider: i < rows.length - 1,
                      ),
                  ],
                ),
              ),

              // ── 통계 ─────────────────────────────────────────────
              if (project.stats.isNotEmpty) ...[
                const Divider(color: AppColors.line, height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Wrap(
                    spacing: 32,
                    runSpacing: 16,
                    children:
                        project.stats.map((s) => StatItem(data: s)).toList(),
                  ),
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
                  color: AppColors.greenDeep,
                  label: '편집',
                  onTap: () => EditProjectDialog.show(
                    context,
                    project: project,
                    allProjects: ref.read(portfolioProvider).requireValue.projects,
                    onSaved: ref.read(portfolioProvider.notifier).reload,
                  ),
                ),
                const SizedBox(width: 6),
                _ActionButton(
                  icon: Icons.delete_rounded,
                  color: Colors.red,
                  label: '삭제',
                  onTap: () => _confirmDelete(context, ref),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final reload = ref.read(portfolioProvider.notifier).reload;
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

class _ExpandButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ExpandButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.add_rounded, size: 20, color: Colors.white),
        ),
      ),
    );
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
