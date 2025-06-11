import 'package:chatwave/chat_wave.dart';
import 'package:chatwave/core/constants/app_color.dart';
import 'package:chatwave/core/constants/app_image.dart';
import 'package:chatwave/core/constants/app_string.dart';
import 'package:chatwave/core/services/navigation_service.dart';
import 'package:chatwave/core/services/push_notifications.dart';
import 'package:chatwave/core/widgets/custom_avtar.dart';
import 'package:chatwave/feature/call/call_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zego_uikit/zego_uikit.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await PushNotifications.instance.init(_handleMessageClick);

  //newly added................
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({'fcmToken': newToken});
    }
  });
  configLoading();
  orientations();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  // 1.1: give it your navigatorKey
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
  if (FirebaseAuth.instance.currentUser != null) {
    await initializeCallService();
  }
  ZegoUIKit().initLog().then((value) {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI([ZegoUIKitSignalingPlugin()]);
    runApp(ChatWave(navigatorKey: navigatorKey));
  });
}

void _handleMessageClick(RemoteMessage message) {
  final data = message.data;
  final chatId = data['chatId'] as String? ?? "";
  final senderId = data['senderId'] as String? ?? "";
  final senderName = data['senderName'] as String? ?? "";
  final senderAvatar = data['senderAvatar'] as String? ?? "";

  // We need to navigate to ChatScreen. However, we can't call Navigator directly from here
  // because context isn't available. Instead, store these details in a global "pendingNotification"
  // or use a NavigationService. For simplicity, assume you have a NavigationService:

  NavigationService.instance.pushNamed(
    '/chat',
    arguments: {
      'chatId': chatId,
      'otherUid': senderId,
      'otherName': senderName,
      'otherAvatar': senderAvatar,
    },
  );
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..textColor = Colors.black
    ..radius = 20
    ..backgroundColor = Colors.transparent
    ..maskColor = Colors.white
    ..indicatorColor = AppColors.textPrimary
    ..userInteractions = false
    ..dismissOnTap = false
    ..boxShadow = <BoxShadow>[]
    // ..customAnimation = CustomAnimation()
    ..indicatorType = EasyLoadingIndicatorType.dualRing;
}

void orientations() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
}

Future<void> showLocalNotification({
  required String title,
  required String body,
}) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'chat_messages_channel', // channel ID
    'Chat Messages', // channel name
    channelDescription: 'Notifications for new chat messages',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0, // notification id (can be incremented for multiple notifications)
    title,
    body,
    platformChannelSpecifics,
  );
}

// Add this to your main.dart or authentication wrapper
Future<void> initializeCallService() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  final doc = await FirebaseFirestore.instance
      .collection(AppString.users)
      .doc(currentUser.uid)
      .get();

  final name = doc.get(AppString.name) ?? 'No Name';

  ZegoUIKitPrebuiltCallInvitationService().init(
    appID: 1049202539,
    appSign: "13787b67728a5984f5bfdbfc37084480f7350fe7fc5d4c86c15521b835620c5b",
    userID: currentUser.uid,
    userName: name,
    plugins: [ZegoUIKitSignalingPlugin()],
    notificationConfig: ZegoCallInvitationNotificationConfig(
      androidNotificationConfig: ZegoCallAndroidNotificationConfig(
        showFullScreen: true,
        fullScreenBackgroundAssetURL: AppImage.icAppLogo,
        callChannel: ZegoCallAndroidNotificationChannelConfig(
          channelID: "ZegoUIKit",
          channelName: "Call Notifications",
          sound: "call",
          icon: "call",
        ),
        missedCallChannel: ZegoCallAndroidNotificationChannelConfig(
          channelID: "MissedCall",
          channelName: "Missed Call",
          sound: "missed_call",
          icon: "missed_call",
          vibrate: false,
        ),
      ),
      iOSNotificationConfig: ZegoCallIOSNotificationConfig(
        systemCallingIconName: 'CallKitIcon',
      ),
    ),
    requireConfig: (ZegoCallInvitationData data) {
      final config = (data.invitees.length > 1)
          ? ZegoCallInvitationType.videoCall == data.type
          ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
          : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
          : ZegoCallInvitationType.videoCall == data.type
          ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
          : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

      config.avatarBuilder = customAvatarBuilder;
      config.topMenuBar.isVisible = true;
      config.topMenuBar.buttons.insert(0, ZegoCallMenuBarButtonName.minimizingButton);
      config.topMenuBar.buttons.insert(1, ZegoCallMenuBarButtonName.soundEffectButton);

      return config;
    },
  );
}
