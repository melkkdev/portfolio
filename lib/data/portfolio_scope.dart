import 'package:flutter/material.dart';
import 'portfolio_state.dart';

class PortfolioScope extends InheritedWidget {
  final PortfolioState data;
  final Future<void> Function() onReload;

  const PortfolioScope({
    super.key,
    required this.data,
    required this.onReload,
    required super.child,
  });

  static PortfolioState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PortfolioScope>()!.data;

  static Future<void> Function() reloadOf(BuildContext context) =>
      context
          .getInheritedWidgetOfExactType<PortfolioScope>()!
          .onReload;

  @override
  bool updateShouldNotify(PortfolioScope old) => !identical(data, old.data);
}
