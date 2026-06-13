import 'package:flutter/material.dart';

typedef AdminExitCallback = Future<void> Function(List<String>? pendingOrderIds);

class AdminNotifier extends ChangeNotifier {
  final AdminExitCallback _onExit;

  AdminNotifier(this._onExit);

  bool _isAdmin = false;
  List<String>? _pendingOrderIds;

  bool get isAdmin => _isAdmin;
  List<String>? get pendingOrderIds => _pendingOrderIds;

  void enter() {
    _isAdmin = true;
    _pendingOrderIds = null;
    notifyListeners();
  }

  Future<void> exit() async {
    await _onExit(_pendingOrderIds);
    _isAdmin = false;
    _pendingOrderIds = null;
    notifyListeners();
  }

  /// 드래그 순서 변경 시 메모리에 저장 + 리빌드 트리거 (실시간 반영)
  void updateOrder(List<String> ids) {
    _pendingOrderIds = ids;
    notifyListeners();
  }
}

class AdminScope extends InheritedNotifier<AdminNotifier> {
  const AdminScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AdminNotifier of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AdminScope>()!.notifier!;

  static bool isAdmin(BuildContext context) => of(context).isAdmin;
}
