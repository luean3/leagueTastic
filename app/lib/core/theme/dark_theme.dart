import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Application theme used when the device or user selects dark mode.
final darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,

  scaffoldBackgroundColor: AppColors.darkBackground,

  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.primary,
    surface: AppColors.darkSurface,
  ),

  cardColor: AppColors.darkSurface,

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkBackground,
    foregroundColor: Colors.white,
    elevation: 0,
  ),

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
);
