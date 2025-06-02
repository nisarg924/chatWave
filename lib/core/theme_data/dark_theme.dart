import 'package:flutter/material.dart';
import '../constants/app_color.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.backgroundDark,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    error: AppColors.notificationRed,
    background: AppColors.backgroundDark,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: AppColors.textSecondary),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.primary),
    ),
  ),
);
