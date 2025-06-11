import 'package:chatwave/core/constants/const.dart';
import 'package:chatwave/feature/call/call_cubit.dart';
import 'package:chatwave/feature/call/call_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chatwave/core/constants/app_color.dart';
import 'package:chatwave/core/constants/app_image.dart';
import 'package:chatwave/core/constants/dimensions.dart';
import 'package:chatwave/core/utils/style.dart';
import 'package:chatwave/core/widgets/custom_circle_avtar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  ProfileScreen({ super.key, required this.userId });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // void _startCall({required bool video}) {
  //   _callCubit.joinCall(
  //     callID: widget.chatId,
  //     userID: currentUserId,
  //     userName: FirebaseAuth.instance.currentUser!.displayName ?? 'Me',
  //     video: video,
  //   );
  // }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 1,
        leading: BackButton(color: theme.colorScheme.onSurface),
        title: Text('Profile', style: fontStyleMedium18.copyWith(color: theme.colorScheme.onSurface)),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snap.hasData || !snap.data!.exists)
            return const Center(child: Text('User not found'));
          final data = snap.data!.data()!;
          final name = data['name'] as String? ?? 'Unknown';
          final avatar = data['imageUrl'] as String? ?? '';
          final phone = data['phoneNumber'] as String? ?? '';
          final bio = data['bio'] as String? ?? '';

          return Padding(
            padding: EdgeInsets.all(Dimensions.w16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Center(
                  child: CustomCircleAvtar(
                    radius: Dimensions.r60,
                    backgroundImage: avatar.isNotEmpty
                        ? NetworkImage(avatar)
                        : const AssetImage(AppImage.icProfileImage)
                    as ImageProvider,
                  ),
                ),
                verticalHeight(Dimensions.h16),
                // Name
                Text(name,
                    style: fontStyleBold22.copyWith(color: theme.colorScheme.onSurface)),
                verticalHeight(Dimensions.h8),
                // Phone
                Text(phone,
                    style: fontStyleRegular16.copyWith(color: AppColors.textSecondary)),
                verticalHeight(Dimensions.h16),
                // Bio / About
                if (bio.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('About',
                        style: fontStyleMedium16.copyWith(color: theme.colorScheme.onSurface)),
                  ),
                  verticalHeight(Dimensions.h8),
                  Text(bio,
                      style: fontStyleRegular14.copyWith(color: theme.colorScheme.onSurface)),
                ],
                Spacer(),
                // Example action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(
                      icon: Icons.call,
                      label: 'Voice Call',
                      onTap: (){},
                    ),
                    _ActionButton(
                      icon: Icons.videocam,
                      label: 'Video Call',
                      onTap: (){},
                    ),
                  ],
                ),
                verticalHeight(Dimensions.h24),
              ],
            ),
          );
        },
      ),
    );
  }
}


class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: AppColors.accent,
          shape: const CircleBorder(),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: onTap,
          ),
        ),
        verticalHeight(Dimensions.h4),
        Text(label, style: fontStyleRegular12.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

}
