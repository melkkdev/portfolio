import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 전체화면이 아닌 모달(이미지 뷰어 등)에서 공통으로 쓰는 padding/텍스트 스타일.
class ModalStyles {
  static const double radius = 16.0;
  static const double imageRadius = 12.0;

  static const EdgeInsets headerPadding = EdgeInsets.fromLTRB(24, 18, 12, 18);
  static const EdgeInsets contentPadding = EdgeInsets.all(24);
  static const EdgeInsets footerPadding = EdgeInsets.symmetric(vertical: 12);

  static const TextStyle headerTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );

  static const TextStyle caption = TextStyle(
    color: AppColors.muted,
    fontSize: 13,
  );
}
