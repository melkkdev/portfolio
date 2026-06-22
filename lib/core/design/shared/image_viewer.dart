import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../common/modal_styles.dart';
import '../../theme/app_theme.dart';

/// 이미지를 확대해서 보여주는 흰 배경 모달.
/// 핀치/드래그 줌, 좌우 슬라이드 버튼·스와이프 탐색을 지원한다.
Future<void> showImageViewer(
  BuildContext context, {
  required List<String> imageUrls,
  required int initialIndex,
  String? title,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => _ImageViewerDialog(
      imageUrls: imageUrls,
      initialIndex: initialIndex,
      title: title,
    ),
  );
}

class _ImageViewerDialog extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String? title;

  const _ImageViewerDialog({
    required this.imageUrls,
    required this.initialIndex,
    this.title,
  });

  @override
  State<_ImageViewerDialog> createState() => _ImageViewerDialogState();
}

class _ImageViewerDialogState extends State<_ImageViewerDialog> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width * 0.9 > 900 ? 900.0 : screenSize.width * 0.9;
    final dialogHeight = screenSize.height * 0.85 > 680 ? 680.0 : screenSize.height * 0.85;
    final hasMultiple = widget.imageUrls.length > 1;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ModalStyles.radius),
      ),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ModalStyles.radius),
                  topRight: Radius.circular(ModalStyles.radius),
                ),
              ),
              padding: ModalStyles.headerPadding,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title ?? '',
                      style: ModalStyles.headerTitle,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: ModalStyles.contentPadding,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        border: Border.all(color: AppColors.line),
                        borderRadius: BorderRadius.circular(ModalStyles.imageRadius),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: widget.imageUrls.length,
                        onPageChanged: (i) => setState(() => _index = i),
                        itemBuilder: (context, i) => InteractiveViewer(
                          minScale: 1,
                          maxScale: 4,
                          child: Center(
                            child: CachedNetworkImage(
                              imageUrl: widget.imageUrls[i],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (hasMultiple && _index > 0)
                      Positioned(
                        left: 4,
                        child: _SlideButton(
                          icon: Icons.chevron_left_rounded,
                          onTap: () => _goTo(_index - 1),
                        ),
                      ),
                    if (hasMultiple && _index < widget.imageUrls.length - 1)
                      Positioned(
                        right: 4,
                        child: _SlideButton(
                          icon: Icons.chevron_right_rounded,
                          onTap: () => _goTo(_index + 1),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (hasMultiple)
              Padding(
                padding: ModalStyles.footerPadding,
                child: Text(
                  '${_index + 1} / ${widget.imageUrls.length}',
                  style: ModalStyles.caption,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SlideButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SlideButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
