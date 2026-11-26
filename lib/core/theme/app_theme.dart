import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 크림 배경 + 코랄 포인트 + 세이지 보조색 팔레트 (2026-11 리디자인)
class AppColors {
  // 배경
  static const bg = Color(0xFFFDF9F2); // 크림
  static const band = Color(0xFFFCF1E2); // 섹션 띠(피치 크림)
  static const surface = Color(0xFFFFFCF7); // 카드
  static const dark = Color(0xFF241B16); // 푸터·GitHub 버튼

  // 글자
  static const ink = Color(0xFF2B211C);
  static const inkSoft = Color(0xFF4F433C);
  static const muted = Color(0xFF8C7E74);

  // 포인트
  static const accent = Color(0xFFE8664B); // 코랄
  static const accentDeep = Color(0xFFC94F36);
  static const accentSoft = Color(0xFFFCE3DA);
  static const peach = Color(0xFFFDEAD3);
  static const sage = Color(0xFF4F9B7E);
  static const sageSoft = Color(0xFFDDF1E6);

  // 선
  static const line = Color(0xFFF1E4D6);
  static const lineSoft = Color(0xFFF7EEE4);
}

class AppRadius {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double band = 48;
  static const double pill = 999;
}

class AppTheme {
  /// 둥근 제목 폰트 (Jua)
  static TextStyle display({
    double fontSize = 32,
    Color color = AppColors.ink,
    double height = 1.25,
  }) =>
      GoogleFonts.jua(
        fontSize: fontSize,
        color: color,
        height: height,
        letterSpacing: -0.3,
      );

  /// 태그·기간 같은 짧은 라벨용 고정폭 폰트
  static TextStyle mono({
    double fontSize = 13,
    Color color = AppColors.muted,
    FontWeight fontWeight = FontWeight.w500,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      );

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.light(
          primary: AppColors.accent,
          secondary: AppColors.sage,
          surface: AppColors.surface,
        ),
        textTheme: GoogleFonts.gowunDodumTextTheme().apply(
          bodyColor: AppColors.ink,
          displayColor: AppColors.ink,
        ),
        dividerColor: AppColors.line,
      );
}
