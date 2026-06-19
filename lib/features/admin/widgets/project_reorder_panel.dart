import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/project_model.dart';
import '../../../data/portfolio_provider.dart';
import '../admin_provider.dart';

class ProjectReorderPanel extends ConsumerStatefulWidget {
  const ProjectReorderPanel({super.key});

  @override
  ConsumerState<ProjectReorderPanel> createState() =>
      _ProjectReorderPanelState();
}

class _ProjectReorderPanelState extends ConsumerState<ProjectReorderPanel> {
  List<_Item>? _items;

  /// 기존 _syncFromScope()와 동일한 동기화 로직: 사용자 정의 순서는 유지하고
  /// 제목 업데이트 + 삭제된 항목 제거 + 새 항목은 끝에 추가.
  void _syncFromProjects(List<ProjectModel> projects) {
    final current = _items;

    if (current == null) {
      setState(() {
        _items = projects.map((p) => _Item(p.id, p.title)).toList();
      });
      return;
    }

    final newIds = (projects.map((p) => p.id).toList()..sort());
    final currentIds = (current.map((i) => i.id).toList()..sort());
    if (listEquals(newIds, currentIds)) return;

    final newMap = {for (final p in projects) p.id: p.title};
    final existingIds = current.map((i) => i.id).toSet();

    final synced = current
        .where((i) => newMap.containsKey(i.id))
        .map((i) => _Item(i.id, newMap[i.id]!))
        .toList();

    for (final p in projects) {
      if (!existingIds.contains(p.id)) {
        synced.add(_Item(p.id, p.title));
      }
    }

    setState(() => _items = synced);
    ref.read(adminProvider.notifier).updateOrder(synced.map((i) => i.id).toList());
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(adminProvider.select((s) => s.isAdmin));

    // admin 진입/이탈 시 동기화 상태 초기화
    ref.listen(adminProvider.select((s) => s.isAdmin), (prev, next) {
      if (next) {
        _syncFromProjects(ref.read(portfolioProvider).requireValue.projects);
      } else {
        setState(() => _items = null);
      }
    });

    // admin 모드 중 프로젝트 목록(추가/삭제)이 바뀌면 재동기화
    ref.listen(portfolioProvider, (prev, next) {
      final projects = next.value;
      if (projects != null && ref.read(adminProvider).isAdmin) {
        _syncFromProjects(projects.projects);
      }
    });

    if (!isAdmin) return const SizedBox.shrink();

    final items = _items ?? [];

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          left: BorderSide(color: AppColors.line),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: const [
                Icon(Icons.reorder_rounded,
                    size: 15, color: AppColors.muted),
                SizedBox(width: 6),
                Text(
                  '프로젝트 순서',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.line),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
            child: Text(
              '드래그해서 순서 변경\n종료 시 저장됩니다.',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.muted.withAlpha(180),
                height: 1.5,
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView(
              padding: const EdgeInsets.symmetric(vertical: 4),
              buildDefaultDragHandles: false,
              onReorderItem: (oldIndex, newIndex) {
                setState(() {
                  final item = _items!.removeAt(oldIndex);
                  _items!.insert(newIndex, item);
                });
                ref.read(adminProvider.notifier).updateOrder(
                  _items!.map((e) => e.id).toList(),
                );
              },
              children: items.asMap().entries.map((e) {
                final idx = e.key;
                final item = e.value;
                return ListTile(
                  key: ValueKey(item.id),
                  dense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10),
                  leading: SizedBox(
                    width: 18,
                    child: Text(
                      '${idx + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.ink,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: ReorderableDragStartListener(
                    index: idx,
                    child: const Icon(
                      Icons.drag_handle_rounded,
                      color: AppColors.muted,
                      size: 20,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Item {
  final String id;
  final String title;
  _Item(this.id, this.title);
}
