import 'package:chatwave/core/constants/app_string.dart';
import 'package:chatwave/core/constants/const.dart';
import 'package:chatwave/core/theme_data/dark_theme.dart';
import 'package:chatwave/core/theme_data/light_theme.dart';
import 'package:chatwave/feature/home/home_screen.dart';
import 'package:chatwave/feature/user/login_screen.dart';
import 'package:chatwave/main.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chatwave/core/utils/router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatWave extends StatefulWidget {
  const ChatWave({super.key, required this.navigatorKey});
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<ChatWave> createState() => _ChatWaveState();
}

class _ChatWaveState extends State<ChatWave> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print("${AppString.appState}$state");
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
        Theme.of(context).brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      child: ScreenUtilInit(
        builder: (_, __) => GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            supportedLocales: const [Locale("en")],
            localizationsDelegates: const [CountryLocalizations.delegate],
            title: AppString.appName,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.system,
            navigatorKey: widget.navigatorKey,
            onGenerateRoute: Routers.generateRoute,
            // 1️⃣ Decide screen based on auth status
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasData && snapshot.data != null) {
                  initializeCallService();
                  return const HomeScreen();
                } else {
                  return const LoginScreen();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
