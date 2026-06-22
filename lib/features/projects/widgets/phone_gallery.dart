import 'package:flutter/material.dart';
import '../../hero/widgets/phone_mockup.dart';

class PortraitGallery extends StatefulWidget {
  final List<String> imageUrls;

  const PortraitGallery({super.key, required this.imageUrls});

  @override
  State<PortraitGallery> createState() => _PortraitGalleryState();
}

class _PortraitGalleryState extends State<PortraitGallery>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const double _itemWidth = 156.0; // PhoneMockup 140 + padding 16
  static const double _pixelsPerSecond = 60.0;

  // repeat() 호출 여부를 별도 추적해 LayoutBuilder 판단 후에만 시작
  bool _loopActive = false;

  @override
  void initState() {
    super.initState();
    final halfWidth = _itemWidth * widget.imageUrls.length;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (halfWidth / _pixelsPerSecond * 1000).round(),
      ),
    );
  }

  @override
  void didUpdateWidget(PortraitGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrls.length != widget.imageUrls.length) {
      final halfWidth = _itemWidth * widget.imageUrls.length;
      _controller.duration = Duration(
        milliseconds: (halfWidth / _pixelsPerSecond * 1000).round(),
      );
      if (_loopActive) {
        _controller.stop();
        _loopActive = false;
        // 다음 build의 addPostFrameCallback에서 재시작
      }
    }
  }

  @override
  void deactivate() {
    // 위젯이 트리에서 제거되기 전에 애니메이션을 멈춰
    // EngineFlutterView가 dispose된 뒤 프레임이 도착하는 것을 방지
    _controller.stop();
    _loopActive = false;
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateLoop(bool needsLoop) {
    if (needsLoop && !_loopActive) {
      _controller.repeat();
      _loopActive = true;
    } else if (!needsLoop && _loopActive) {
      _controller.stop();
      _loopActive = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 280,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = _itemWidth * widget.imageUrls.length;
          final needsLoop =
              widget.imageUrls.length > 1 && totalWidth > constraints.maxWidth;

          // 빌드 단계에서 직접 repeat() 호출 금지 → 프레임 후에 처리
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _updateLoop(needsLoop);
          });

          if (!needsLoop) {
            return SizedBox(
              width: constraints.maxWidth,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.imageUrls
                      .asMap()
                      .entries
                      .map(
                        (e) => Padding(
                          padding: EdgeInsets.only(
                            right: e.key < widget.imageUrls.length - 1 ? 16 : 0,
                          ),
                          child: PhoneMockup(imageUrl: e.value),
                        ),
                      )
                      .toList(),
                ),
              ),
            );
          }

          final looped = [...widget.imageUrls, ...widget.imageUrls];
          final halfWidth = totalWidth;

          return ClipRect(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.translate(
                offset: Offset(-_controller.value * halfWidth, 0),
                child: child,
              ),
              child: OverflowBox(
                maxWidth: double.infinity,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: looped
                      .map(
                        (url) => Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: PhoneMockup(imageUrl: url),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
