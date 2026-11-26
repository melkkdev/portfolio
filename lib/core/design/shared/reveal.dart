import 'package:flutter/material.dart';

/// 화면에 들어오면 한 번 서서히 떠오르는 효과.
/// 감싼 위젯이 뷰포트 아래 10% 지점보다 위로 올라오면 실행된다.
class Reveal extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const Reveal({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  late final Animation<double> _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  ScrollPosition? _position;
  bool _shown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (position != _position) {
      _position?.removeListener(_check);
      _position = position;
      _position?.addListener(_check);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (_shown || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return;
    final top = box.localToGlobal(Offset.zero).dy;
    final viewport = MediaQuery.sizeOf(context).height;
    if (top < viewport * 0.9) {
      _shown = true;
      _position?.removeListener(_check);
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_check);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(
          offset: Offset(0, 28 * (1 - _curve.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
