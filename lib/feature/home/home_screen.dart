import 'package:chatwave/core/constants/app_color.dart';
import 'package:chatwave/core/constants/app_image.dart';
import 'package:chatwave/core/constants/app_string.dart';
import 'package:chatwave/core/constants/const.dart';
import 'package:chatwave/core/constants/dimensions.dart';
import 'package:chatwave/core/utils/navigation_manager.dart';
import 'package:chatwave/core/utils/style.dart';
import 'package:chatwave/core/widgets/custom_button.dart';
import 'package:chatwave/core/widgets/custom_circle_avtar.dart';
import 'package:chatwave/feature/chat/chat_screen.dart';
import 'package:chatwave/feature/home/user_cubit.dart';
import 'package:chatwave/feature/user/login_screen.dart';
import 'package:chatwave/feature/user/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Stream<DocumentSnapshot<Map<String, dynamic>>> chatStream(String currentUid, String otherUid) {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUid)
        .snapshots()
        .map((snapshot) {
      for (var doc in snapshot.docs) {
        final participants = List<String>.from(doc['participants'] ?? []);
        if (participants.contains(otherUid)) return doc;
      }
      return null;
    }).where((doc) => doc != null).cast<DocumentSnapshot<Map<String, dynamic>>>();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Column(
          children: [
            Center(child: Text(AppString.loginToYourAccount)),
            CustomButton(text: AppString.login, onPressed: ()=>goToLogin(context))
          ],
        ),
      );
    }

    final currentUserId = user.uid;

    // Initialize the UsersCubit to load all users
    final usersCubit = UsersCubit()..loadUsers();

    // Optional: Stream your own user doc to show avatar in top‐right (as before)
    Stream<DocumentSnapshot<Map<String, dynamic>>> userDocStream() {
      return FirebaseFirestore.instance
          .collection(AppString.users)
          .doc(currentUserId)
          .snapshots();
    }

    return BlocProvider<UsersCubit>.value(
      value: usersCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppString.appName,style:fontStyleBold22.copyWith(color: theme.primaryColor)),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          leading: Image.asset(AppImage.icAppLogo),
          leadingWidth: Dimensions.w60,
          actions: [
            profileStream(userDocStream()),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.w8),
          child: Column(
            children: [
              // 1) Search / Filter Bar (optional: not functional in this snippet)
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Dimensions.h10,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: AppString.searchUsers,
                    prefixIcon: const Icon(Icons.search),
                    focusColor: theme.primaryColor,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.r24),
                      borderSide: BorderSide(color: theme.hintColor, width:Dimensions.w1), // Example: A different color
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.r24),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              // 2) List of All Users (excluding “myself”)
              Expanded(
                child: BlocBuilder<UsersCubit, UsersState>(
                  builder: (context, state) {
                    if (state is UsersLoading) {
                      return Center(child: loader());
                    } else if (state is UsersLoaded) {
                      final allUsers = state.users;
                      // Filter out current user
                      final otherUsers = allUsers
                          .where((u) => u[AppString.uid] != currentUserId)
                          .toList();

                      if (otherUsers.isEmpty) {
                        return Center(
                            child: Text(AppString.noOtherUsers));
                      }

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: otherUsers.length,
                        itemBuilder: (ctx, index) {
                          final u = otherUsers[index];
                          final otherUid = u[AppString.uid] as String;
                          final otherName = u[AppString.name] as String? ?? AppString.noName;
                          final otherAvatar =
                              u[AppString.imageUrl] as String? ?? AppString.emptyString;
                          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
                            stream: chatStream(currentUserId, otherUid),
                            builder: (context, snapshot) {
                              String lastMsg = '';
                              int unread = 0;


                              if (snapshot.hasData && snapshot.data!.exists) {
                                final chatData = snapshot.data!.data()!;
                                lastMsg = chatData['lastMessage'] ?? '';
                                unread = chatData['unreadCount']?[currentUserId] ?? 0;
                              }
                              return ListTile(
                                leading: CustomCircleAvtar(
                                  radius: Dimensions.r20,
                                  backgroundImage: (otherAvatar.isNotEmpty)
                                      ? NetworkImage(otherAvatar)
                                      : const AssetImage(AppImage.icProfileImage)
                                  as ImageProvider,),
                                title: Text(
                                  capitalize(otherName),
                                  style: fontStyleMedium16.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                  subtitle: Text(
                                    lastMsg.isNotEmpty ? lastMsg : u['phoneNumber'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: fontStyleRegular14.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                trailing: unread > 0
                                    ? CircleAvatar(
                                  radius: 12,
                                  backgroundColor: AppColors.primary,
                                  child: Text(
                                    unread.toString(),
                                    style: fontStyleRegular12.copyWith(color: Colors.white),
                                  ),
                                )
                                    : null,
                                onTap: () =>goToChatScreen(context, currentUserId: currentUserId, otherUid: otherUid, otherName: otherName, otherAvatar: otherAvatar),
                              );
                            }
                          );
                        },
                      );
                    } else if (state is UsersError) {
                      return Center(child: Text('${AppString.error}${state.error}'));
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
  void goToProfileScreen(BuildContext context) {
    navigateToPage(context, const ProfileScreen());
  }
  void goToLogin(BuildContext context){
    navigateToPage(context, LoginScreen());
  }

  StreamBuilder profileStream(Stream<DocumentSnapshot<Map<String, dynamic>>> userDocStream){
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userDocStream,
      builder: (context, snapshot) {
        String? avatarUrl;
        if (snapshot.hasData) {
          avatarUrl = snapshot.data!.data()?['imageUrl'] as String?;
        }
        return Padding(
          padding: EdgeInsets.only(right: Dimensions.w10),
          child: InkWell(
            onTap: ()=>goToProfileScreen(context),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accent,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: Dimensions.r18,
                backgroundImage: (avatarUrl == null || avatarUrl.isEmpty)
                    ? const AssetImage(AppImage.icAppLogo)
                as ImageProvider
                    : NetworkImage(avatarUrl),
              ),
            ),
          ),
        );
      },
    );
  }

  void goToChatScreen(BuildContext context,{required String currentUserId,required String otherUid,
  required String otherName,
  required String otherAvatar,}) async {
    // When tapping a user, either get an existing chatID or create a new one:
    final chatId = await _createOrGetChatId(
      currentUserId,
      otherUid,
      otherName,
      otherAvatar,
    );

    // Then navigate to ChatScreen:
    navigateToPage(
      context,
      ChatScreen(
        chatId: chatId,
        otherUid: otherUid,
        otherName: otherName,
        otherAvatar: otherAvatar,
      ),
    );
  }

  /// Attempts to find an existing “chats” document where both userIds appear in the participants array.
  /// If none is found, creates a brand‐new chat document and returns its new ID.
  Future<String> _createOrGetChatId(
      String currentUserId,
      String otherUid,
      String otherName,
      String otherAvatar,
      ) async {
    final collection = FirebaseFirestore.instance.collection('chats');

    // 1) Try to find an existing chat where participants == [currentUserId, otherUid] (in any order).
    final query = await collection
        .where('participants', arrayContains: currentUserId)
        .get();
    for (var doc in query.docs) {
      final data = doc.data();
      final participants = List<String>.from(data['participants'] ?? []);
      // Check if otherUid is also in that participants list
      if (participants.contains(otherUid)) {
        return doc.id; // existing chat found
      }
    }

    // 2) If no existing chat found, create a new one:
    final newDocRef = collection.doc();
    final now = FieldValue.serverTimestamp();

    // Fetch your own user data to store in participantData (optional, but recommended)
    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();
    final currentData = currentUserDoc.data()!;

    // Build participantData map
    final participantData = {
      currentUserId: {
        'name': currentData['name'] as String? ?? '',
        'avatar': currentData['imageUrl'] as String? ?? '',
      },
      otherUid: {
        'name': otherName,
        'avatar': otherAvatar,
      },
    };

    await newDocRef.set({
      'participants': [currentUserId, otherUid],
      'participantData': participantData,
      'lastMessage': '',
      'lastTimestamp': now,
      'unreadCount': {
        currentUserId: 0,
        otherUid: 0,
      },
    });

    return newDocRef.id;
  }
}


