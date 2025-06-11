import 'package:chatwave/feature/chat/chat_screen.dart';
import 'package:chatwave/feature/home/home_screen.dart';
import 'package:chatwave/feature/user/login_screen.dart';
import 'package:flutter/cupertino.dart';

class Routers{
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case LOGIN_ROUTE:
        return CupertinoPageRoute(builder: (_) => LoginScreen());
      case HOME_ROUTE:
        return CupertinoPageRoute(builder: (_) => HomeScreen());
      case CHAT_ROUTE:
        final args = settings.arguments as Map<String, dynamic>;
        return CupertinoPageRoute(builder: (_) => ChatScreen(chatId: args['chatId'], otherUid: args['otherUid'], otherName: args['otherName'], otherAvatar: args['otherAvatar']));
      default:
        return CupertinoPageRoute(builder: (_)=>LoginScreen());
    }
  }
}

const String LOGIN_ROUTE = '/LoginScreen';
const String HOME_ROUTE = '/HomeScreen';
const String CHAT_ROUTE = '/ChatScreen';
