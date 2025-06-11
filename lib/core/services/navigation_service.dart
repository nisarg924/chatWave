// lib/core/utils/navigation_manager.dart

import 'package:flutter/material.dart';

class NavigationService {
  NavigationService._();
  static final NavigationService instance = NavigationService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic>? pushNamed(String routeName, { Object? arguments }) {
    return navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  void pop() {
    return navigatorKey.currentState?.pop();
  }
}
