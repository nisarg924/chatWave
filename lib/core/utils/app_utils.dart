import 'package:flutter/material.dart';

class AppUtils {
  double bottomPadding(BuildContext context) {
    return buttonHeight(context) + MediaQuery.of(context).padding.bottom;
  }

  double buttonHeight(BuildContext context) {
    return AppBar().preferredSize.height;
  }
}