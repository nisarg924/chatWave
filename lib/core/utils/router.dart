import 'package:chatwave/feature/user/login_screen.dart';
import 'package:flutter/cupertino.dart';

class Routers{
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case LOGIN_ROUTE:
        return CupertinoPageRoute(builder: (_) => LoginScreen());
      default:
        return CupertinoPageRoute(builder: (_)=>LoginScreen());
    }
  }
}

const String LOGIN_ROUTE = '/LoginScreen';
