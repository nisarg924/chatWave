// lib/feature/user/home_screen.dart
import 'package:chatwave/core/constants/app_color.dart';
import 'package:chatwave/core/constants/app_image.dart';
import 'package:chatwave/core/constants/app_string.dart';
import 'package:chatwave/core/constants/const.dart';
import 'package:chatwave/core/constants/dimensions.dart';
import 'package:chatwave/core/utils/navigation_manager.dart';
import 'package:chatwave/core/utils/style.dart';
import 'package:chatwave/feature/home/user_cubit.dart';
import 'package:chatwave/feature/user/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usersCubit = UsersCubit()..loadLoggedInUsers();
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Stream of this user’s Firestore document (for top-right avatar)
    Stream<DocumentSnapshot<Map<String, dynamic>>> userDocStream() {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots();
    }

    // (Placeholder: your Realtime DB ref for chat if needed)
    final chatDbRef =
    FirebaseDatabase.instance.ref().child('chat_rooms');

    return BlocProvider<UsersCubit>.value(
      value: usersCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppString.appName,
            style: fontStyleBold20.copyWith(color: theme.primaryColor),
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Image.asset(AppImage.icAppLogo),
          ),
          leadingWidth: Dimensions.w60,
          actions: [
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: userDocStream(),
              builder: (context, snapshot) {
                String? imageUrl;
                if (snapshot.hasData) {
                  imageUrl = snapshot.data!.data()?['imageUrl'] as String?;
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: InkWell(
                    onTap: () {
                      navigateToPage(context, const ProfileScreen());
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      height: Dimensions.h36,
                      width: Dimensions.w36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accent,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: Dimensions.r18,
                        backgroundColor: theme.colorScheme.onSurface
                            .withOpacity(0.2),
                        backgroundImage: (imageUrl == null || imageUrl.isEmpty)
                            ? const AssetImage(AppImage.icAppLogo)
                        as ImageProvider
                            : NetworkImage(imageUrl),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<UsersCubit, UsersState>(
                  builder: (context, state) {
                    if (state is UsersLoading) {
                      return const Center(
                          child: CircularProgressIndicator());
                    } else if (state is UsersLoaded) {
                      // Exclude current user
                      final allUsers = state.users;
                      final otherUsers = allUsers
                          .where((u) => u['uid'] != userId)
                          .toList();

                      if (otherUsers.isEmpty) {
                        return const Center(
                            child: Text('No other users online.'));
                      }

                      return ListView.builder(
                        itemCount: otherUsers.length,
                        itemBuilder: (ctx, index) {
                          final u = otherUsers[index];
                          final name = u['name'] as String? ?? 'No Name';
                          final phone =
                              u['phoneNumber'] as String? ?? '';
                          final imageUrl = u['imageUrl'] as String? ?? '';
                          final lastLoginTimestamp =
                          u['lastLogin'] as Timestamp?;
                          final lastLoginStr = lastLoginTimestamp != null
                              ? lastLoginTimestamp
                              .toDate()
                              .toLocal()
                              .toString()
                              : 'N/A';

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                              theme.colorScheme.onSurface,
                              backgroundImage:
                              (imageUrl.isNotEmpty)
                                  ? NetworkImage(imageUrl)
                                  : const AssetImage(
                                  AppImage.icProfileImage)
                              as ImageProvider,
                            ),
                            title: Text(
                              capitalize(name),
                              style: fontStyleMedium16.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              phone,
                              style: fontStyleRegular14.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state is UsersError) {
                      return Center(child: Text(state.error));
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
