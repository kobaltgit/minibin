import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF07090E);
  static const Color surface = Color(0xFF0E131F);
  static const Color surfaceBorder = Color(0xFF1E293B);
  static const Color surfaceBorderHover = Color(0xFF38BDF8);

  static const Color card = Color(0xFF111827);
  static const Color cardLight = Color(0xFF1E293B);

  static const Color primary = Color(0xFF38BDF8); // Sky blue
  static const Color primaryDark = Color(0xFF0284C7);
  static const Color primaryGlow = Color(0x3338BDF8);

  static const Color secondary = Color(0xFF818CF8); // Indigo
  static const Color accentGreen = Color(0xFF34D399); // Emerald
  static const Color accentAmber = Color(0xFFFBBF24); // Amber
  static const Color accentRose = Color(0xFFF43F5E); // Rose

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF38BDF8), Color(0xFF818CF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient heroGlowGradient = RadialGradient(
    colors: [Color(0x2538BDF8), Color(0x10818CF8), Colors.transparent],
    stops: [0.0, 0.5, 1.0],
    radius: 0.85,
  );
}

ThemeData buildAppTheme() {
  final baseTheme = ThemeData.dark(useMaterial3: true);
  return baseTheme.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
    ),
    textTheme: baseTheme.textTheme.copyWith(
      displayLarge: const TextStyle(
        fontSize: 52,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        color: AppColors.textPrimary,
        height: 1.1,
        fontFamily: 'Segoe UI',
      ),
      displayMedium: const TextStyle(
        fontSize: 38,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        color: AppColors.textPrimary,
        height: 1.15,
        fontFamily: 'Segoe UI',
      ),
      titleLarge: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFamily: 'Segoe UI',
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.6,
        fontFamily: 'Segoe UI',
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
        fontFamily: 'Segoe UI',
      ),
    ),
  );
}
