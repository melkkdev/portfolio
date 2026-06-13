import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../hero/widgets/phone_mockup.dart';

class PhoneGallery extends StatefulWidget {
  final List<String> images;

  const PhoneGallery({super.key, required this.images});

  @override
  State<PhoneGallery> createState() => _PhoneGalleryState();
}

class _PhoneGalleryState extends State<PhoneGallery>
    with SingleTickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();
  late final Ticker _ticker;

  static const double _pixelsPerSecond = 60.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    final half = max / 2;
    if (half <= 0) return;
    final offset = (elapsed.inMilliseconds / 1000.0 * _pixelsPerSecond) % half;
    _scroll.jumpTo(offset);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    final looped = widget.images.length > 1
        ? [...widget.images, ...widget.images]
        : widget.images;

    return SizedBox(
      height: 280,
      child: SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: looped
              .map(
                (img) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: PhoneMockup(imagePath: img),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
