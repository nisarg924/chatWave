import 'package:flutter/material.dart';
import '../constants/app_color.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.backgroundLight,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    error: AppColors.notificationRed,
    background: AppColors.backgroundLight,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: AppColors.textPrimary),
    bodyMedium: TextStyle(color: AppColors.textSecondary),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.primary),
    ),
  ),
);
