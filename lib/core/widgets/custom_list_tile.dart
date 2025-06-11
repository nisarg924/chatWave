import 'package:chatwave/core/constants/app_string.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraListTile extends StatelessWidget {
  const CameraListTile({super.key});


  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.camera_alt),
      title:  Text(AppString.camera),
      onTap: () => Navigator.pop(context, ImageSource.camera),
    );
  }
}

class GalleyListTile extends StatelessWidget {
  const GalleyListTile({super.key});


  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.photo_library),
      title: Text(AppString.gallery),
      onTap: () => Navigator.pop(context, ImageSource.gallery),
    );
  }
}
