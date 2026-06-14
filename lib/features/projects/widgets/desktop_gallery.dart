import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class LandscapeGallery extends StatefulWidget {
  final List<String> imageUrls;

  const LandscapeGallery({super.key, required this.imageUrls});

  @override
  State<LandscapeGallery> createState() => _LandscapeGalleryState();
}

class _LandscapeGalleryState extends State<LandscapeGallery>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const double _itemWidth = 514.0; // 이미지 498 + 간격 16
  static const double _pixelsPerSecond = 60.0;
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
  void didUpdateWidget(LandscapeGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrls.length != widget.imageUrls.length) {
      final halfWidth = _itemWidth * widget.imageUrls.length;
      _controller.duration = Duration(
        milliseconds: (halfWidth / _pixelsPerSecond * 1000).round(),
      );
      if (_loopActive) {
        _controller.stop();
        _loopActive = false;
      }
    }
  }

  @override
  void deactivate() {
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

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _updateLoop(needsLoop);
          });

          if (!needsLoop) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: widget.imageUrls
                    .map((url) => _ImageItem(url: url))
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
                      .map((url) => _ImageItem(url: url))
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

class _ImageItem extends StatelessWidget {
  final String url;

  const _ImageItem({required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 498,
          height: 280,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(10),
          ),
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(
              color: AppColors.lineSoft,
              child: const Center(
                child: Icon(Icons.image_rounded, color: AppColors.muted, size: 32),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
