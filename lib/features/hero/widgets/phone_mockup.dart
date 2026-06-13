import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PhoneMockup extends StatelessWidget {
  final String imageUrl;
  final double rotateDeg;

  const PhoneMockup({super.key, required this.imageUrl, this.rotateDeg = 0});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotateDeg * 3.14159 / 180,
      child: Container(
        width: 140,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF234F34).withValues(alpha: 0.32),
              blurRadius: 40,
              offset: const Offset(0, 18),
              spreadRadius: -12,
            ),
            BoxShadow(
              color: AppColors.line.withValues(alpha: 0.8),
              blurRadius: 0,
              spreadRadius: 1.5,
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorWidget: (_, __, ___) => Container(
            color: AppColors.greenLight,
            child: const Center(
              child: Icon(Icons.phone_android, color: AppColors.green, size: 40),
            ),
          ),
        ),
      ),
    );
  }
}
