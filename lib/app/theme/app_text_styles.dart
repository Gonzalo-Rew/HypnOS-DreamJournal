import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  static const String _uiFont = 'Inter';
  static const String _dreamFont = 'Lora';

  static TextTheme textTheme = const TextTheme(
    displaySmall: TextStyle(
      fontFamily: _uiFont,
      fontSize: 28,
      height: 32 / 28,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: _uiFont,
      fontSize: 24,
      height: 30 / 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: _uiFont,
      fontSize: 20,
      height: 26 / 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: _uiFont,
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: _uiFont,
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    labelLarge: TextStyle(
      fontFamily: _uiFont,
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    labelSmall: TextStyle(
      fontFamily: _uiFont,
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
  );

  static const TextStyle dreamBody = TextStyle(
    fontFamily: _dreamFont,
    fontSize: 18,
    height: 29 / 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
}
