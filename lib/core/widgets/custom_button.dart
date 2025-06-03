import 'package:chatwave/core/constants/app_color.dart';
import 'package:chatwave/core/constants/dimensions.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.miniWidth,
    this.height,
    this.elevation,
    this.btnBgColor,
    this.textStyle,
  });

  final String text;
  final VoidCallback? onPressed;
  final double? miniWidth;
  final double? height;
  final TextStyle? textStyle;
  final double? elevation;
  final Color? btnBgColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: elevation ?? 0,
        backgroundColor: btnBgColor ?? Theme.of(context).colorScheme.primary,
        fixedSize: Size(miniWidth ?? double.infinity, height ?? Dimensions.h50),
        minimumSize: Size(miniWidth ?? double.infinity, height ?? Dimensions.h50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.r10),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }
}
