import 'package:chatwave/core/constants/app_string.dart';
import 'package:chatwave/core/theme_data/dark_theme.dart';
import 'package:chatwave/core/theme_data/light_theme.dart';
import 'package:chatwave/feature/home/home_screen.dart';
import 'package:chatwave/feature/user/login_screen.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chatwave/core/navigation_key/global_key.dart';
import 'package:chatwave/core/utils/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatWave extends StatefulWidget {
  const ChatWave({super.key});

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
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        print("AppLifecycleState.resumed ===> InvoiceDetailsScreen");
        break;
      case AppLifecycleState.inactive:
        // await flutterLocalNotificationsPlugin.cancelAll();
        break;
      case AppLifecycleState.paused:
        print("AppLifecycleState.paused ===> InvoiceDetailsScreen");
        break;
      case AppLifecycleState.detached:
        print("AppLifecycleState.detached ===> InvoiceDetailsScreen");
        //await flutterLocalNotificationsPlugin.cancelAll();
        break;
      case AppLifecycleState.hidden:
        print("hidden");
    }
  }

  Future<bool> _checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.light ?Brightness.light  : Brightness.dark,
      ),
      child: ScreenUtilInit(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            supportedLocales: const [
              Locale("en"),

              /// THIS IS FOR COUNTRY CODE PICKER
            ],
            localizationsDelegates: [CountryLocalizations.delegate],
            title: AppString.appName,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.system,
            navigatorKey: GlobalVariable.navigatorKey,
            onGenerateRoute: Routers.generateRoute,
            routes: const <String, WidgetBuilder>{},
            home: FutureBuilder(
              future: _checkIfLoggedIn(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show a splash/loading indicator
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                final isLoggedIn = snapshot.data ?? false;
                return isLoggedIn ? const HomeScreen() : const LoginScreen();
              },
            ),
          ),
        ),
      ),
    );
  }
}
