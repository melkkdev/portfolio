import 'package:flutter/material.dart';
import '../../hero/widgets/phone_mockup.dart';

class PhoneGallery extends StatefulWidget {
  final List<String> imageUrls;

  const PhoneGallery({super.key, required this.imageUrls});

  @override
  State<PhoneGallery> createState() => _PhoneGalleryState();
}

class _PhoneGalleryState extends State<PhoneGallery>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const double _itemWidth = 156.0; // PhoneMockup 140 + padding 16
  static const double _pixelsPerSecond = 60.0;

  @override
  void initState() {
    super.initState();
    final halfWidth = _itemWidth * widget.imageUrls.length;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (halfWidth / _pixelsPerSecond * 1000).round(),
      ),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

          if (!needsLoop) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: widget.imageUrls
                    .map(
                      (url) => Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: PhoneMockup(imageUrl: url),
                      ),
                    )
                    .toList(),
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
