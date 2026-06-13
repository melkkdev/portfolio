import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFFEEF0EE);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF232826);
  static const inkSoft = Color(0xFF3A423D);
  static const muted = Color(0xFF6B746E);
  static const green = Color(0xFF006E51);
  static const greenDeep = Color(0xFF00543D);
  static const greenLight = Color(0xFFE2EFE9);
  static const line = Color(0xFFE3E7E3);
  static const lineSoft = Color(0xFFECEEEC);
}

class AppTheme {
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
          primary: AppColors.green,
          surface: AppColors.surface,
        ),
        textTheme: GoogleFonts.notoSansKrTextTheme().apply(
          bodyColor: AppColors.ink,
          displayColor: AppColors.ink,
        ),
      );
}
