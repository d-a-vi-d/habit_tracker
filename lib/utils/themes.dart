import 'package:flutter/material.dart';
import 'app_colors.dart';

class Themes {
  static ThemeData get light => ThemeData(
    appBarTheme: const AppBarTheme(centerTitle: true),
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,

      primary: AppColors.primary600,
      onPrimary: AppColors.neutralDark,

      secondary: AppColors.secondary600,
      onSecondary: AppColors.neutralDark,

      error: AppColors.accent600,
      onError: AppColors.neutralDark,

      surface: AppColors.primary100,
      onSurface: AppColors.neutralDark,
    ),
  );
}
