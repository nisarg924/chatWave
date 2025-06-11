import 'package:chatwave/core/constants/app_color.dart';
import 'package:chatwave/core/constants/dimensions.dart';
import 'package:chatwave/core/utils/style.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType? inputType;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.hintText, this.controller, this.inputType, this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.r10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.r10),
        ),
        filled: true,
        fillColor: Theme.of(context).brightness==Brightness.dark?Theme.of(context).colorScheme.onSurface:AppColors.backgroundLight,
        hintText: hintText,
        hintStyle:
        fontStyleLight15.apply(color: Theme.of(context).brightness==Brightness.dark?Theme.of(context).colorScheme.surface:AppColors.textSecondary),
      ),
      controller: controller,
      keyboardType: inputType,
      cursorColor: AppColors.blackColor,
      focusNode: focusNode,
      style: fontStyleMedium16.copyWith(color: Theme.of(context).brightness==Brightness.dark?Theme.of(context).colorScheme.surface:Colors.black),
    );
  }
}
