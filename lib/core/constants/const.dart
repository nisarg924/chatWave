import 'package:chatwave/core/constants/app_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

void snackBar(String text,BuildContext context){
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(text)));
}
CircularProgressIndicator loader(){
  return CircularProgressIndicator(
    color: AppColors.primary,
  );
}

Widget verticalHeight(double height) {
  return SizedBox(
    height: height,
  );
}

Widget horizontalWidth(double width) {
  return SizedBox(
    width: width,
  );
}

class Const {
  String emailPattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

  Pattern phonePattern = r'(^[0-9 ]*$)';

  String getUniqueName() {
    var uuid = const Uuid();
    return uuid.v4();
  }

  bool validateEmail(String email) {
    return RegExp(emailPattern).hasMatch(email);
  }

  String? toastSuccess(val) {
    if (kDebugMode) {
      Fluttertoast.showToast(
          msg: val,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppColors.backgroundDark.withOpacity(0.7),
          textColor: AppColors.textPrimary,
          fontSize: 16.0);
    }

    print(val);
  }

  String? toastFail(val) {
    Fluttertoast.showToast(
        msg: val,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.backgroundDark.withOpacity(0.7),
        textColor: AppColors.textPrimary,
        fontSize: 16.0);
  }
}
class FontAsset {
  static const String mulish = "Mulish";
  static const String sfPro = "SFProText";

  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;
}