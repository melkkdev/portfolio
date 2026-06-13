import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/design/cards/surface_card.dart';
import '../../../core/design/shared/info_row.dart';
import '../../../data/portfolio_data.dart';
import 'desktop_gallery.dart';
import 'phone_gallery.dart';
import 'stat_item.dart';

bool _isDesktop(List<String> images) =>
    images.isNotEmpty && images.first.contains('_desktop_');

class ProjectCard extends StatelessWidget {
  final ProjectData project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
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
          if (project.images.isNotEmpty) ...[
            const SizedBox(height: 24),
            _isDesktop(project.images)
                ? DesktopGallery(images: project.images)
                : PhoneGallery(images: project.images),
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
              children: project.stats.map((s) => StatItem(data: s)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
