import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// 검은 베젤을 두른 폰 모양 이미지 프레임
class PhoneMockup extends StatelessWidget {
  final String imageUrl;
  final double rotateDeg;
  final double width;
  final double height;

  const PhoneMockup({
    super.key,
    required this.imageUrl,
    this.rotateDeg = 0,
    this.width = 140,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    final outerRadius = width * 0.17;
    const bezel = 5.0;

    return Transform.rotate(
      angle: rotateDeg * math.pi / 180,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(bezel),
        decoration: BoxDecoration(
          color: AppColors.dark,
          borderRadius: BorderRadius.circular(outerRadius),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8A4B2A).withValues(alpha: 0.28),
              blurRadius: 36,
              offset: const Offset(0, 18),
              spreadRadius: -10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(outerRadius - bezel),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorWidget: (_, _, _) => Container(
              color: AppColors.accentSoft,
              child: const Center(
                child: Icon(Icons.phone_android,
                    color: AppColors.accent, size: 40),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
