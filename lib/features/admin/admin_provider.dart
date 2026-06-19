import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/portfolio_provider.dart';
import '../../data/repository/portfolio_repository.dart';

part 'admin_provider.g.dart';

class AdminUiState {
  final bool isAdmin;
  final List<String>? pendingOrderIds;

  const AdminUiState({this.isAdmin = false, this.pendingOrderIds});

  AdminUiState copyWith({bool? isAdmin, List<String>? pendingOrderIds}) =>
      AdminUiState(
        isAdmin: isAdmin ?? this.isAdmin,
        pendingOrderIds: pendingOrderIds ?? this.pendingOrderIds,
      );
}

@Riverpod(keepAlive: true)
class Admin extends _$Admin {
  @override
  AdminUiState build() => const AdminUiState();

  void enter() => state = const AdminUiState(isAdmin: true);

  /// 드래그로 변경된 순서가 있으면 Firestore에 저장 후 reload, 없으면 admin 모드만 종료.
  Future<void> exit() async {
    final pending = state.pendingOrderIds;
    if (pending != null && pending.isNotEmpty) {
      final projects = ref.read(portfolioProvider).value?.projects ?? const [];
      final idToProject = {for (final p in projects) p.id: p};
      final reordered = pending.asMap().entries
          .where((e) => idToProject.containsKey(e.value))
          .map((e) => idToProject[e.value]!.copyWith(order: e.key))
          .toList();
      try {
        await PortfolioRepository.saveProjects(reordered);
        await ref.read(portfolioProvider.notifier).reload();
      } catch (e) {
        debugPrint('order save failed: $e');
      }
    }
    state = const AdminUiState();
  }

  /// 드래그 순서 변경 시 메모리에 저장 + 리빌드 트리거 (실시간 반영)
  void updateOrder(List<String> ids) =>
      state = state.copyWith(pendingOrderIds: ids);
}
