import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF650912);
  static const secondary = Color(0xFFFFAD59);
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF313A51);
  static const success = Color(0xFF00C853);
  static const outline = Color(0xFFE0E0E0);
  
  // Profile screen colors
  static const primaryContainer = Color(0xFFFF7E7B);
  static const onPrimaryContainer = Color(0xFF74161B);
  static const surfaceContainerHigh = Color(0xFFE1E7FF);
  static const onSurfaceVariant = Color(0xFF574240);
  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const neutralBorder = Color(0xFFE5E5E5);
  
  // Registration screen colors
  static const secondaryContainer = Color(0xFFFEAC59);
  static const surfaceVariant = Color(0xFFD9E2FF);
  static const outlineVariant = Color(0xFFDDC0BE);
}

class AppTextStyles {
  static const headlineLg = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
    fontFamily: 'Plus Jakarta Sans',
  );
  static const headlineMd = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    fontFamily: 'Plus Jakarta Sans',
  );
  static const headlineSm = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
    fontFamily: 'Plus Jakarta Sans',
  );
  static const bodyLg = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
    fontFamily: 'Plus Jakarta Sans',
  );
  static const bodyMd = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight(300),
    color: AppColors.onSurface,
    fontFamily: 'Plus Jakarta Sans',
  );
  static const labelLg = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurfaceVariant,
    fontFamily: 'Plus Jakarta Sans',
    letterSpacing: 0.14,
  );
  static const labelSm = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
    fontFamily: 'Plus Jakarta Sans',
  );
}

class AppTheme {
  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
    ),
    scaffoldBackgroundColor: AppColors.surface,
    fontFamily: 'Plus Jakarta Sans',
    textTheme: const TextTheme(
      headlineLarge: AppTextStyles.headlineLg,
      headlineMedium: AppTextStyles.headlineMd,
      bodyMedium: AppTextStyles.bodyMd,
      labelSmall: AppTextStyles.labelSm,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8F8FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: AppColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: AppColors.outline),
      ),
    ),
  );
}
