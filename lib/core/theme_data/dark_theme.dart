import 'package:chatwave/core/constants/const.dart';
import 'package:flutter/material.dart';
import '../constants/app_color.dart';

final ThemeData darkTheme = ThemeData(
  fontFamily: FontAsset.mulish,
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
);
