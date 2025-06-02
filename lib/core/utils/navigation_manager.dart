import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<dynamic> navigateToPageAndRemoveAllPage(
    BuildContext context, String routePage,
    {Widget? currentWidget}) {
  return Navigator.of(context)
      .pushNamedAndRemoveUntil(routePage, (route) => false);
}

Future<dynamic> navigateToPage(BuildContext context, Widget routePage,
    {Widget? currentWidget}) {
  try {
    FocusManager.instance.primaryFocus!.unfocus();
  } catch (e, s) {
    //todo sanjay comment
    // FirebaseCrashlytics.instance.recordError(e, s);
  }
  return Navigator.push(
    context,
    CupertinoPageRoute(builder: (context) => routePage),
  );
}


Future<dynamic> navigateToPageAndRemoveCurrentPage(
    BuildContext context, Widget routePage,
    {Widget? currentWidget}) {
  return Navigator.pushReplacement(
    context,
    CupertinoPageRoute(builder: (context) => routePage),
  );
}

class EnterExitRoute extends PageRouteBuilder {
  final Widget? enterPage;
  final Widget? exitPage;

  EnterExitRoute({this.exitPage, this.enterPage})
      : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    enterPage!,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
        Stack(
          children: <Widget>[
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.0),
                end: const Offset(-1.0, 0.0),
              ).animate(animation),
              child: exitPage,
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: enterPage,
            )
          ],
        ),
  );
}
