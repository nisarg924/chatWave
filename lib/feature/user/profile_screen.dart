// lib/feature/user/profile_screen.dart

import 'dart:io';

import 'package:chatwave/core/constants/app_color.dart';
import 'package:chatwave/core/constants/app_image.dart';
import 'package:chatwave/core/constants/const.dart';
import 'package:chatwave/core/constants/dimensions.dart';
import 'package:chatwave/core/utils/navigation_manager.dart';
import 'package:chatwave/core/utils/router.dart';
import 'package:chatwave/core/utils/style.dart';
import 'package:chatwave/feature/home/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  String? _name;
  String? _phoneNumber;
  String? _profileImageUrl;
  String? _status;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _name = data['name'] as String? ?? 'No Name';
        _phoneNumber = data['phoneNumber'] as String? ?? '';
        _profileImageUrl = data['imageUrl'] as String?;
        _status = data['status'] as String? ?? 'Available';
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ],
      ),
    );

    if (source != null) {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        await _uploadProfileImage(file);
      }
    }
  }

  Future<void> _uploadProfileImage(File file) async {
    setState(() => _uploading = true);
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$userId.jpg');

      final uploadTask = ref.putFile(file);
      await uploadTask;

      final downloadUrl = await ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'imageUrl': downloadUrl});

      setState(() => _profileImageUrl = downloadUrl);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: $e')),
      );
    } finally {
      setState(() => _uploading = false);
    }
  }

  Future<void> _updateUsername() async {
    final newNameController = TextEditingController(text: _name);
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Username'),
        content: TextField(
          controller: newNameController,
          decoration: const InputDecoration(hintText: 'Enter new name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, newNameController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && result != _name) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'name': result});
      setState(() => _name = result);
    }
  }

  Future<void> _updateStatus() async {
    final statusController = TextEditingController(text: _status);
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Status'),
        content: TextField(
          controller: statusController,
          decoration: const InputDecoration(hintText: 'Enter your status'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, statusController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && result != _status) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'status': result});
      setState(() => _status = result);
    }
  }

  Future<void> _logout() async {
    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(userId)
    //     .update({'isLoggedIn': false});
    await FirebaseAuth.instance.signOut();
    await navigateToPageAndRemoveAllPage(context, LOGIN_ROUTE);

  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:  Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title:  Text(
          'Profile',
          style: TextStyle(
              color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: (_name == null)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.COMMON_PADDING_FOR_SCREEN,
            vertical: Dimensions.h20,
          ),
          child: Column(
            children: [
              // Avatar with camera overlay
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: Dimensions.w120,
                    height: Dimensions.w120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.accent,
                        width: 4,
                      ),
                    ),
                    child: ClipOval(
                      child: (_profileImageUrl == null ||
                          _profileImageUrl!.isEmpty)
                          ? Image.asset(
                        AppImage.icAppLogo,
                        fit: BoxFit.cover,
                      )
                          : Image.network(
                        _profileImageUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (_uploading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: const CircularProgressIndicator(),
                ),

              verticalHeight(Dimensions.h16),

              // Name
              Text(
                capitalize(_name!),
                style: fontStyleBold22.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              verticalHeight(Dimensions.h8),

              // Name
              Text(
                _phoneNumber!,
                style: fontStyleRegular16.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),


              verticalHeight(Dimensions.h8),

              // Edit Username link
              GestureDetector(
                onTap: _updateUsername,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit,
                      color: AppColors.accent,
                      size: 18,
                    ),
                    horizontalWidth(6),
                    Text(
                      'Edit Username',
                      style: fontStyleMedium16.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),

              verticalHeight(Dimensions.h24),

              // Status label + field
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Status',
                  style: fontStyleMedium16.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
              verticalHeight(Dimensions.h8),
              GestureDetector(
                onTap: _updateStatus,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.h16,
                    vertical: Dimensions.h12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _status == 'Available'
                              ? Colors.green
                              : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      horizontalWidth(8),
                      Expanded(
                        child: Text(
                          _status ?? 'Available',
                          style: fontStyleRegular14.copyWith(
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.9),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),

              verticalHeight(Dimensions.h30),

              // Change Password tile (optional)
              GestureDetector(
                onTap: () {
                  // TODO: navigate to change password screen
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: Dimensions.h16),
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.h16,
                    vertical: Dimensions.h12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.onSurface,
                        blurRadius: 2,
                        offset: const Offset(1, 1,),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      horizontalWidth(12),
                      Expanded(
                        child: Text(
                          'Change Password',
                          style: fontStyleMedium16.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),

              // Sign Out tile
              GestureDetector(
                onTap: _logout,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.h16,
                    vertical: Dimensions.h12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.onSurface,
                        blurRadius: 2,
                        offset: const Offset(1, 1,),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.exit_to_app,
                          color: Colors.red,
                          size: 22,
                        ),
                      ),
                      horizontalWidth(12),
                      Expanded(
                        child: Text(
                          'Sign Out',
                          style: fontStyleMedium16.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


