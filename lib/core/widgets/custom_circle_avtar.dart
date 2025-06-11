import 'package:chatwave/core/constants/app_image.dart';
import 'package:chatwave/core/constants/dimensions.dart';
import 'package:flutter/material.dart';

class CustomCircleAvtar extends StatelessWidget {
  const CustomCircleAvtar({super.key, this.radius, this.backgroundImage});
  final double? radius;
  final ImageProvider<Object>? backgroundImage;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius??Dimensions.r12,
      backgroundImage: backgroundImage??const AssetImage(AppImage.icProfileImage) as ImageProvider,
    );
  }
}
