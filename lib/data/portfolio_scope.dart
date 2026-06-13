import 'package:flutter/material.dart';
import 'portfolio_state.dart';

class PortfolioScope extends InheritedWidget {
  final PortfolioState data;

  const PortfolioScope({
    super.key,
    required this.data,
    required super.child,
  });

  static PortfolioState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PortfolioScope>()!.data;

  @override
  bool updateShouldNotify(PortfolioScope old) => false;
}
