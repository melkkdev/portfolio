import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/portfolio_scope.dart';
import '../admin_scope.dart';

class ProjectReorderPanel extends StatefulWidget {
  const ProjectReorderPanel({super.key});

  @override
  State<ProjectReorderPanel> createState() => _ProjectReorderPanelState();
}

class _ProjectReorderPanelState extends State<ProjectReorderPanel> {
  List<_Item>? _items;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!AdminScope.isAdmin(context)) {
      _items = null;
      return;
    }
    _syncFromScope();
  }

  void _syncFromScope() {
    final projects = PortfolioScope.of(context).projects;

    if (_items == null) {
      setState(() {
        _items = projects.map((p) => _Item(p.id, p.title)).toList();
      });
      return;
    }

    // 정렬된 ID 목록으로 추가/삭제 감지
    final newIds = (projects.map((p) => p.id).toList()..sort());
    final currentIds = (_items!.map((i) => i.id).toList()..sort());

    if (!listEquals(newIds, currentIds)) {
      final newMap = {for (final p in projects) p.id: p.title};
      final existingIds = _items!.map((i) => i.id).toSet();

      // 기존 사용자 정의 순서 유지, 제목 업데이트, 삭제된 항목 제거
      final synced = _items!
          .where((i) => newMap.containsKey(i.id))
          .map((i) => _Item(i.id, newMap[i.id]!))
          .toList();

      // 새로 추가된 프로젝트를 끝에 추가
      for (final p in projects) {
        if (!existingIds.contains(p.id)) {
          synced.add(_Item(p.id, p.title));
        }
      }

      setState(() => _items = synced);
      AdminScope.of(context).updateOrder(synced.map((i) => i.id).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AdminScope.isAdmin(context)) return const SizedBox.shrink();

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
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _items!.removeAt(oldIndex);
                  _items!.insert(newIndex, item);
                });
                AdminScope.of(context).updateOrder(
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
