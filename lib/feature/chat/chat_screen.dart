import 'dart:async';
import 'package:chatwave/core/constants/app_color.dart';
import 'package:chatwave/core/constants/app_image.dart';
import 'package:chatwave/core/constants/app_string.dart';
import 'package:chatwave/core/constants/const.dart';
import 'package:chatwave/core/constants/dimensions.dart';
import 'package:chatwave/core/models/message_model.dart';
import 'package:chatwave/core/utils/navigation_manager.dart';
import 'package:chatwave/core/utils/style.dart';
import 'package:chatwave/core/widgets/custom_circle_avtar.dart';
import 'package:chatwave/core/widgets/custom_list_tile.dart';
import 'package:chatwave/core/widgets/typing_indicator_widget.dart';
import 'package:chatwave/feature/call/call_ui.dart';
import 'package:chatwave/feature/chat/cubit/chat_cubit.dart';
import 'package:chatwave/feature/chat/other_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:chatwave/core/widgets/custom_avtar.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUid;
  final String otherName;
  final String otherAvatar;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUid,
    required this.otherName,
    required this.otherAvatar,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatCubit _chatCubit = ChatCubit();
  bool _showEmojiPicker = false;
  bool _isTyping = false;
  Timer? _typingTimer;
  String? _name;
  String? _phoneNumber;
  String? _profileImageUrl;
  String? _status;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _chatCubit = ChatCubit()..loadMessages(widget.chatId);
    _chatCubit.markMessagesAsRead(widget.chatId, currentUserId);
    // Once we have loaded messages, start listening to the other user's typing node.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatCubit.listenTyping(widget.chatId, widget.otherUid);
    });
    // _loadUserInfo();
  }

  @override
  void dispose() {
    _chatCubit.close();
    _textController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  // Future<void> _loadUserInfo() async {
  //   final doc = await FirebaseFirestore.instance.collection(AppString.users).doc(currentUserId).get();
  //   final data = doc.data();
  //   if (data != null) {
  //     setState(() {
  //       _name = data[AppString.name] as String? ?? AppString.noName;
  //       _phoneNumber = data[AppString.phoneNumber] as String? ?? AppString.emptyString;
  //       _profileImageUrl = data[AppString.imageUrl] as String?;
  //       _status = data[AppString.status] as String? ?? AppString.available;
  //     });
  //   }
  //   // _initializeZegoUIKit();
  // }

  // void _initializeZegoUIKit() {
  //   if (FirebaseAuth.instance.currentUser != null && _name != null) {
  //     ZegoUIKitPrebuiltCallInvitationService().init(
  //       appID: 1049202539,
  //       appSign: "13787b67728a5984f5bfdbfc37084480f7350fe7fc5d4c86c15521b835620c5b",
  //       userID: currentUserId,
  //       userName: _name!,
  //       plugins: [ZegoUIKitSignalingPlugin()],
  //       notificationConfig: ZegoCallInvitationNotificationConfig(
  //           androidNotificationConfig: ZegoCallAndroidNotificationConfig(
  //             showFullScreen: true,
  //             fullScreenBackgroundAssetURL: AppImage.icAppLogo,
  //             callChannel: ZegoCallAndroidNotificationChannelConfig(
  //               channelID: "ZegoUIKit",
  //               channelName: "Call Notifications",
  //               sound: "call",
  //               icon: "call",
  //             ),
  //             missedCallChannel: ZegoCallAndroidNotificationChannelConfig(
  //               channelID: "MissedCall",
  //               channelName: "Missed Call",
  //               sound: "missed_call",
  //               icon: "missed_call",
  //               vibrate: false,
  //             ),
  //           ),
  //         iOSNotificationConfig: ZegoCallIOSNotificationConfig(
  //           systemCallingIconName: 'CallKitIcon',
  //         ),
  //       ),
  //       requireConfig: (ZegoCallInvitationData data) {
  //         final config = (data.invitees.length > 1)
  //             ? ZegoCallInvitationType.videoCall == data.type
  //                 ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
  //                 : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
  //             : ZegoCallInvitationType.videoCall == data.type
  //                 ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
  //                 : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();
  //
  //         /// custom avatar
  //         config.avatarBuilder = customAvatarBuilder;
  //
  //         /// support minimizing, show minimizing button
  //         config.topMenuBar.isVisible = true;
  //         config.topMenuBar.buttons.insert(0, ZegoCallMenuBarButtonName.minimizingButton);
  //         config.topMenuBar.buttons.insert(1, ZegoCallMenuBarButtonName.soundEffectButton);
  //
  //         return config;
  //       },
  //     );
  //   }
  // }

  void _onTextChanged(String text) {
    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      _chatCubit.setTyping(widget.chatId, currentUserId, true);
    }
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 1), () {
      _isTyping = false;
      _chatCubit.setTyping(widget.chatId, currentUserId, false);
    });
  }

  /// Opens the emoji picker
  void _toggleEmojiPicker() {
    FocusScope.of(context).unfocus();
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
  }

  /// Pick an image from camera or gallery, then upload & send
  Future<void> _onAttachPressed() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CameraListTile(),
          GalleyListTile(),
        ],
      ),
    );

    if (source != null) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 75,
      );
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        await _chatCubit.sendImageMessage(widget.chatId, file);
        // Auto‐scroll to bottom after image message is sent
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  /// Send a plain text message
  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final msg = MessageModel(
      messageId: AppString.emptyString,
      senderId: currentUserId,
      text: text,
      isImage: false,
      imageUrl: null,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    _chatCubit.sendMessage(widget.chatId, msg);
    _textController.clear();
    _chatCubit.setTyping(widget.chatId, currentUserId, false);
    _isTyping = false;

    // Scroll to bottom after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Helper to build each message bubble
  Widget _buildMessageBubble(MessageModel m) {
    final theme = Theme.of(context);
    final isMe = m.senderId == currentUserId;
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bgColor = isMe
        ? AppColors.messageBgColor
        : theme.brightness == Brightness.dark
            ? AppColors.messageBgColorDark
            : theme.colorScheme.surface;
    final textColor = isMe
        ? AppColors.blackColor
        : theme.brightness == Brightness.dark
            ? AppColors.whiteColor
            : theme.colorScheme.onSurface;
    final radius = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    final timeString = DateFormat('HH:mm').format(
      DateTime.fromMillisecondsSinceEpoch(m.timestamp),
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Dimensions.h4,
        horizontal: Dimensions.w12,
      ),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: radius,
              boxShadow: theme.brightness == Brightness.dark
                  ? [
                      BoxShadow(color: Colors.grey.shade700, blurRadius: 2, offset: Offset(1, 1)),
                    ]
                  : [
                      BoxShadow(color: Colors.grey.withAlpha(150), spreadRadius: 1, blurRadius: 2, offset: Offset(1, 1)),
                      BoxShadow(color: Colors.grey.withAlpha(150), spreadRadius: 1, blurRadius: 2, offset: Offset(2, 2)),
                    ],
            ),
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.w12,
              vertical: Dimensions.h8,
            ),
            child: m.isImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      m.imageUrl!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  )
                : Text(
                    capitalize(m.text),
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
          ),
          verticalHeight(Dimensions.h4),
          Text(
            timeString,
            style: fontStyleRegular12.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: _chatCubit,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          scrolledUnderElevation: 0,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300, // thin bottom line color
              height: 1.0,
            ),
          ),
          leadingWidth: Dimensions.w24,
          leading: iconButton(
              icon: Icons.arrow_back,
              color: theme.colorScheme.onSurface,
              onTap: () {
                _chatCubit.setTyping(widget.chatId, currentUserId, false);
                Navigator.pop(context);
              }),
          title: GestureDetector(
            onTap: () {
              // navigate to a ProfileScreen for widget.otherUid
              navigateToPage(
                context,
                ProfileScreen(userId: widget.otherUid),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomCircleAvtar(
                  radius: Dimensions.r20,
                  backgroundImage: (widget.otherAvatar.isNotEmpty) ? NetworkImage(widget.otherAvatar) : const AssetImage(AppImage.icProfileImage) as ImageProvider,
                ),
                horizontalWidth(Dimensions.w8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        capitalize(widget.otherName),
                        overflow: TextOverflow.ellipsis,
                        style: fontStyleMedium16.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        AppString.online,
                        style: fontStyleRegular12.copyWith(color: AppColors.accent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ZegoSendCallInvitationButton(
              invitees: [ZegoUIKitUser(id: widget.otherUid, name: widget.otherName)],
              isVideoCall: false,
              resourceID: 'zegouikit_call',
              iconSize: const Size(40, 40),
              buttonSize: const Size(50, 50),
              icon: ButtonIcon(icon: Icon(Icons.call), backgroundColor: theme.scaffoldBackgroundColor),
            ),
            ZegoSendCallInvitationButton(
              invitees: [ZegoUIKitUser(id: widget.otherUid, name: widget.otherName)],
              isVideoCall: true,
              resourceID: 'zegouikit_call',
              iconSize: const Size(40, 40),
              icon: ButtonIcon(icon: Icon(Icons.videocam), backgroundColor: theme.scaffoldBackgroundColor),
              buttonSize: const Size(50, 50),
            )
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // 1) Message List
              Expanded(
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ChatLoaded) {
                      final messages = state.messages;
                      // Always scroll to bottom when messages load
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                          );
                        }
                      });

                      // Build the ListView of messages
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length + 1,
                        itemBuilder: (ctx, idx) {
                          if (idx == messages.length) {
                            // Show “typing” if isOtherTyping is true
                            if (state.isOtherTyping) {
                              return const TypingIndicator();
                            }
                            return const SizedBox.shrink();
                          }
                          final m = messages[idx];
                          return _buildMessageBubble(m);
                        },
                      );
                    } else if (state is ChatError) {
                      return Center(child: Text('${AppString.error} ${state.error}'));
                    } else if (state is ChatUploadingImage) {
                      // Optionally, show a “Uploading…” indicator
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ChatImageUploaded) {
                      return const SizedBox.shrink();
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),

              // 2) Input area (Emoji / Attachment / Text / Mic / Send)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.w8,
                  vertical: Dimensions.h4,
                ),
                color: theme.colorScheme.surface,
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Emoji button
                        iconButton(icon: Icons.emoji_emotions_outlined, color: theme.colorScheme.onSurface, onTap: _toggleEmojiPicker),

                        // Attachment button
                        iconButton(icon: Icons.attach_file, color: theme.colorScheme.onSurface, onTap: _onAttachPressed),

                        // Text input
                        Expanded(
                          child: TextField(
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.newline,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            controller: _textController,
                            onChanged: _onTextChanged,
                            cursorColor: theme.colorScheme.onSurface,
                            cursorHeight: Dimensions.h18,
                            decoration: InputDecoration(
                              hintText: AppString.messageHint,
                              hintStyle: fontStyleRegular15.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        // Microphone and Send button
                        iconButton(icon: Icons.mic, color: AppColors.accent, onTap: () {}),
                        iconButton(icon: Icons.send, color: AppColors.accent, onTap: _sendMessage),
                      ],
                    ),

                    // 3) Emoji picker
                    if (_showEmojiPicker)
                      SizedBox(
                        height: 250,
                        child: EmojiPicker(
                          onEmojiSelected: (category, emoji) {
                            _textController.text += emoji.emoji;
                            _textController.selection = TextSelection.fromPosition(
                              TextPosition(offset: _textController.text.length),
                            );
                          },
                          config: Config(
                            height: 256,
                            viewOrderConfig: const ViewOrderConfig(
                              top: EmojiPickerItem.categoryBar,
                              middle: EmojiPickerItem.emojiView,
                              bottom: EmojiPickerItem.searchBar,
                            ),
                            skinToneConfig: const SkinToneConfig(),
                            categoryViewConfig: const CategoryViewConfig(),
                            bottomActionBarConfig: const BottomActionBarConfig(),
                            searchViewConfig: const SearchViewConfig(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconButton iconButton({IconData? icon, Color? color, VoidCallback? onTap}) {
    return IconButton(
      icon: Icon(
        icon ?? Icons.send,
        color: color ?? AppColors.accent,
      ),
      onPressed: onTap ??
          () {
            Fluttertoast.showToast(msg: "No Functions");
          },
    );
  }
}
