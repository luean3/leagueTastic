import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Application theme used when the device or user selects light mode.
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,

  scaffoldBackgroundColor: AppColors.lightBackground,

  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.primary,
    surface: AppColors.lightSurface,
  ),

  cardColor: AppColors.lightSurface,

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
  ),

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.textLight),
    bodyMedium: TextStyle(color: Colors.black87),
  ),
);
