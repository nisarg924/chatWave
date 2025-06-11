// call_screen.dart
import 'dart:math' as math;
import 'package:chatwave/core/constants/const.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

// alternative_call_screen.dart - Use this if the main version has issues

class CallScreen extends StatefulWidget {
  final String callID;
  final String userId;
  final String userName;
  final String userAvatar;
  final String targetUserId;
  final String targetUserName;
  final String targetUserAvatar;
  final bool isVideoCall;

  const CallScreen({
    Key? key,
    required this.callID,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.targetUserId,
    required this.targetUserName,
    required this.targetUserAvatar,
    this.isVideoCall = false,
  }) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: Const.appId, // Replace with your actual app ID
      appSign: Const.appSign, // Replace with your actual app sign
      userID: widget.userId,
      userName: widget.userName,
      callID: widget.callID,
      config: _buildCallConfig(),
    );
  }

  ZegoUIKitPrebuiltCallConfig _buildCallConfig() {

    // Get the base config
    ZegoUIKitPrebuiltCallConfig config;

    if (widget.isVideoCall) {
      config = ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall();
    } else {
      config = ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();
    }

    // Configure the hangup confirmation
    config.hangUpConfirmDialogInfo = ZegoCallHangUpConfirmDialogInfo(
      title: "Hang up",
      message: "Are you sure to hang up?",
    );

    // Configure top menu bar
    config.topMenuBarConfig = ZegoTopMenuBarConfig(
      buttons: [
        ZegoMenuBarButtonName.minimizingButton,
        ZegoMenuBarButtonName.hangUpButton,
      ],
    );

    // Configure bottom menu bar for video calls
    if (widget.isVideoCall) {
      config.bottomMenuBarConfig = ZegoBottomMenuBarConfig(
        buttons: [
          ZegoMenuBarButtonName.toggleCameraButton,
          ZegoMenuBarButtonName.switchCameraButton,
          ZegoMenuBarButtonName.hangUpButton,
          ZegoMenuBarButtonName.toggleMicrophoneButton,
        ],
      );
    } else {
      // For voice calls
      config.bottomMenuBarConfig = ZegoBottomMenuBarConfig(
        buttons: [
          ZegoMenuBarButtonName.toggleMicrophoneButton,
          ZegoMenuBarButtonName.hangUpButton,
          ZegoMenuBarButtonName.switchAudioOutputButton,
        ],
      );
    }

    // Configure layout
    config.layout = ZegoLayout.pictureInPicture(
      smallViewPosition: ZegoViewPosition.topRight,
      switchLargeOrSmallViewByClick: true,
    );

    return config;
  }
}

// call_service.dart

class CallService {
  static const int ZEGO_APP_ID = Const.appId; // Replace with your actual app ID
  static const String ZEGO_APP_SIGN = Const.appSign; // Replace with your actual app sign

  static Future<void> initializeZego({
    required String userId,
    required String userName,
  }) async {
    // Initialize signaling plugin
    ZegoUIKit().initLog().then((value) {
      ZegoUIKitPrebuiltCallInvitationService().init(
        appID: ZEGO_APP_ID,
        appSign: ZEGO_APP_SIGN,
        userID: userId,
        userName: userName,
        plugins: [ZegoUIKitSignalingPlugin()],
      );
    });
  }

  static void uninitializeZego() {
    ZegoUIKitPrebuiltCallInvitationService().uninit();
  }

  static String generateCallID() {
    return DateTime.now().millisecondsSinceEpoch.toString() + math.Random().nextInt(1000).toString();
  }

  static Future<void> startVoiceCall({
    required BuildContext context,
    required String currentUserId,
    required String currentUserName,
    required String currentUserAvatar,
    required String targetUserId,
    required String targetUserName,
    required String targetUserAvatar,
  }) async {
    final callID = generateCallID();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          callID: callID,
          userId: currentUserId,
          userName: currentUserName,
          userAvatar: currentUserAvatar,
          targetUserId: targetUserId,
          targetUserName: targetUserName,
          targetUserAvatar: targetUserAvatar,
          isVideoCall: false,
        ),
      ),
    );
  }

  static Future<void> startVideoCall({
    required BuildContext context,
    required String currentUserId,
    required String currentUserName,
    required String currentUserAvatar,
    required String targetUserId,
    required String targetUserName,
    required String targetUserAvatar,
  }) async {
    final callID = generateCallID();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          callID: callID,
          userId: currentUserId,
          userName: currentUserName,
          userAvatar: currentUserAvatar,
          targetUserId: targetUserId,
          targetUserName: targetUserName,
          targetUserAvatar: targetUserAvatar,
          isVideoCall: true,
        ),
      ),
    );
  }

  // Optional: Send call invitation to target user
  static Future<void> sendCallInvitation({
    required String targetUserId,
    required String targetUserName,
    required bool isVideoCall,
  }) async {
    final callID = generateCallID();

    await ZegoUIKitPrebuiltCallInvitationService().send(
      isVideoCall: isVideoCall,
      invitees: [
        ZegoCallUser(
          targetUserId,
          targetUserName,
        )
      ],
      callID: callID,
    );
  }
}
