import 'package:flutter/material.dart';

class AppColors {
  // Brand & Accents
  static const Color primaryBlue = Color(0xFF1D61E7);
  static const Color primaryBlueHover = Color(0xFF1850BE);
  static const Color primaryBlueLight = Color(0xFFEFF6FF);

  static const Color verifyGreen = Color(0xFF00A651);
  static const Color verifyGreenHover = Color(0xFF008E44);
  static const Color verifyGreenLight = Color(0xFFDCFCE7);

  // Backgrounds
  static const Color background = Color(0xFFF6F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF9FAFB);

  // Borders & Dividers
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderSubtle = Color(0xFFF1F5F9);
  static const Color borderFocus = Color(0xFF3B82F6);

  // Typography
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  // Status Badges
  static const Color statusPendingBg = Color(0xFFF3F4F6);
  static const Color statusPendingText = Color(0xFF4B5563);

  static const Color statusInProgressBg = Color(0xFFDBEAFE);
  static const Color statusInProgressText = Color(0xFF1D4ED8);

  static const Color statusCompletedBg = Color(0xFFDCFCE7);
  static const Color statusCompletedText = Color(0xFF15803D);

  static const Color statusVerifiedBg = Color(0xFFD1FAE5);
  static const Color statusVerifiedText = Color(0xFF047857);

  // Priority Badges
  static const Color priorityUrgentBg = Color(0xFFFEE2E2);
  static const Color priorityUrgentText = Color(0xFFDC2626);

  static const Color priorityHighBg = Color(0xFFFFEDD5);
  static const Color priorityHighText = Color(0xFFC2410C);

  static const Color priorityMediumBg = Color(0xFFFEF3C7);
  static const Color priorityMediumText = Color(0xFFB45309);

  static const Color priorityLowBg = Color(0xFFF3F4F6);
  static const Color priorityLowText = Color(0xFF4B5563);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Segoe UI',
      dividerColor: AppColors.border,
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
          color: AppColors.textLight,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderFocus, width: 1.5),
        ),
      ),
    );
  }
}
