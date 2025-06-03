// lib/feature/user/home_screen.dart
import 'package:chatwave/core/constants/app_color.dart';
import 'package:chatwave/core/constants/app_image.dart';
import 'package:chatwave/core/constants/app_string.dart';
import 'package:chatwave/core/constants/const.dart';
import 'package:chatwave/core/constants/dimensions.dart';
import 'package:chatwave/core/utils/navigation_manager.dart';
import 'package:chatwave/core/utils/router.dart';
import 'package:chatwave/core/utils/style.dart';
import 'package:chatwave/feature/home/user_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Initialize Realtime Database reference for chat (stub):
    final chatDbRef = FirebaseDatabase.instance.ref().child('chat_rooms');
    // You can now use chatDbRef to listen/write chat messages later.

    return BlocProvider<UsersCubit>(
      create: (_) => UsersCubit()..loadLoggedInUsers(),
      child: Scaffold(
          appBar: AppBar(
            title: const Text(AppString.homeTitle),
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  // 1) Update SharedPreferences:
                  final prefs = await SharedPreferences.getInstance();

                  // 2) Navigate to LoginScreen:
                  navigateToPageAndRemoveAllPage(context, LOGIN_ROUTE);
                },
              )
            ],
          ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.w10),
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<UsersCubit, UsersState>(
                  builder: (context, state) {
                    if (state is UsersLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is UsersLoaded) {
                      final users = state.users;
                      if (users.isEmpty) {
                        return const Center(child: Text('No users online.'));
                      }
                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (ctx, index) {
                          final u = users[index];
                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.symmetric(
                              vertical: Dimensions.h8,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.onSurface,
                                child: Image.asset(AppImage.icAppLogo,fit: BoxFit.cover,),
                              ),
                              title: Text(
                                u['phoneNumber'],
                                style: fontStyleMedium16.copyWith(color: theme.colorScheme.onSurface),
                              ),
                              subtitle: Text(
                                'Last Login: ${u['lastLogin'] != null ? (u['lastLogin'] as Timestamp).toDate().toLocal().toString() : 'N/A'}',
                                style: fontStyleRegular14
                                    .copyWith(color: AppColors.textSecondary),
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
