import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/common/spacing.dart';
import '../../../core/design/shared/reveal.dart';
import '../../../core/design/shared/section_band.dart';
import '../../../core/design/shared/section_header.dart';
import '../../../data/portfolio_provider.dart';
import '../../admin/admin_provider.dart';
import '../../admin/widgets/edit_project_dialog.dart';
import 'project_card.dart';

class ProjectsSection extends ConsumerWidget {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreProjects = ref.watch(portfolioProvider).requireValue.projects;
    final adminState = ref.watch(adminProvider);
    final isAdmin = adminState.isAdmin;
    final pendingIds = isAdmin ? adminState.pendingOrderIds : null;

    // 드래그 순서 변경이 있으면 그 순서로 표시 (Firestore 저장 전에도 즉시 반영)
    final displayProjects = pendingIds != null
        ? [
            ...pendingIds
                .where((id) => firestoreProjects.any((p) => p.id == id))
                .map((id) => firestoreProjects.firstWhere((p) => p.id == id)),
            // pendingIds에 없는 프로젝트(새로 추가된 경우)는 끝에 추가
            ...firestoreProjects.where((p) => !pendingIds.contains(p.id)),
          ]
        : firestoreProjects;

    return SectionBand(
      tinted: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Reveal(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                    child: SectionHeader(num: '04', title: '프로젝트')),
                if (isAdmin)
                  AdminTextButton(
                    label: '프로젝트 추가',
                    icon: Icons.add_rounded,
                    onPressed: () => EditProjectDialog.show(
                      context,
                      allProjects: firestoreProjects,
                      onSaved: ref.read(portfolioProvider.notifier).reload,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),
          for (final p in displayProjects)
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Reveal(
                key: ValueKey(p.id),
                child: ProjectCard(project: p),
              ),
            ),
        ],
      ),
    );
  }
}
