import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartupService {
  static Future<SharedPreferences> get _instance async =>
      _prefsInstance ??= await SharedPreferences.getInstance();
  static SharedPreferences? _prefsInstance;

  static Future<SharedPreferences> init() async {
    _prefsInstance = await _instance;
    return _prefsInstance!;
  }

  static bool getFirstPermissionLocation() {
    return _prefsInstance?.getBool("FirstPermissionLocation") ?? false;
  }

  static Future<bool> setFirstPermissionLocation(bool value) async {
    var prefs = await _instance;
    return prefs.setBool("FirstPermissionLocation", value);
  }

  static bool getFirstPermissionCamera() {
    return _prefsInstance?.getBool("FirstPermissionCamera") ?? false;
  }

  static Future<bool> setFirstPermissionCamera(bool value) async {
    var prefs = await _instance;
    return prefs.setBool("FirstPermissionCamera", value);
  }

  static bool getFirstPermissionContact() {
    return _prefsInstance?.getBool("FirstPermissionContact") ?? false;
  }

  static Future<bool> setFirstPermissionContact(bool value) async {
    var prefs = await _instance;
    return prefs.setBool("FirstPermissionContact", value);
  }

  static bool getFirstPermissionPhoto() {
    return _prefsInstance?.getBool("FirstPermissionPhoto") ?? false;
  }

  static Future<bool> setFirstPermissionPhoto(bool value) async {
    var prefs = await _instance;
    return prefs.setBool("FirstPermissionPhoto", value);
  }

  static bool getFirstPermissionMicroPhone() {
    return _prefsInstance?.getBool("FirstPermissionMicroPhone") ?? false;
  }

  static Future<bool> setFirstPermissionMicroPhone(bool value) async {
    var prefs = await _instance;
    return prefs.setBool("FirstPermissionMicroPhone", value);
  }

  static bool getFirstPermissionStorage() {
    return _prefsInstance?.getBool("FirstPermissionStorage") ?? false;
  }

  static Future<bool> setFirstPermissionStorage(bool value) async {
    var prefs = await _instance;
    return prefs.setBool("FirstPermissionStorage", value);
  }

  static bool isUserLoggedIn() {
    return _prefsInstance?.getBool("IsUserLoggedIn") ?? false;
  }

  static Future<bool> setIsUserLoggedIn(bool value) async {
    var prefs = await _instance;
    return prefs.setBool("IsUserLoggedIn", value);
  }

  static String getFcmToken() {
    return _prefsInstance?.getString("FcmToken") ?? "";
  }

  static Future<bool> setFcmToken(String value) async {
    var prefs = await _instance;
    return prefs.setString("FcmToken", value);
  }

  static String getDeviceModel() {
    return _prefsInstance?.getString("DeviceModel") ?? "";
  }

  static Future<bool> setDeviceModel(String value) async {
    var prefs = await _instance;
    return prefs.setString("DeviceModel", value);
  }

  static String getDeviceManufacture() {
    return _prefsInstance?.getString("DeviceManufacture") ?? "";
  }

  static Future<bool> setDeviceManufacture(String value) async {
    var prefs = await _instance;
    return prefs.setString("DeviceManufacture", value);
  }

  static String getDeviceOSVersion() {
    return _prefsInstance?.getString("OSVersion") ?? "";
  }

  static Future<bool> setDeviceOSVersion(String value) async {
    var prefs = await _instance;
    return prefs.setString("OSVersion", value);
  }

  static String getAppVersion() {
    return _prefsInstance?.getString("AppVersion") ?? "1.0";
  }

  static Future<bool> setAppVersion(String value) async {
    var prefs = await _instance;
    return prefs.setString("AppVersion", value);
  }

  static String getPlatformName() {
    return Platform.isAndroid ? "android" : "iOS";
  }

  static String getToken() {
    return _prefsInstance?.getString("token") ?? "";
  }

  static Future<bool> setToken(String value) async {
    var prefs = await _instance;
    return prefs.setString("token", value);
  }

  static String getUserId() {
    return _prefsInstance?.getString("UserId") ?? "";
  }

  static Future<bool> setUserId(String value) async {
    var prefs = await _instance;
    return prefs.setString("UserId", value);
  }

  static String getMobileNo() {
    return _prefsInstance?.getString("MobileNo") ?? "";
  }

  static Future<bool> setMobileNo(String value) async {
    var prefs = await _instance;
    return prefs.setString("MobileNo", value);
  }

  static String getCountryCode() {
    return _prefsInstance?.getString("CountryCode") ?? "";
  }

  static Future<bool> setCountryCode(String value) async {
    var prefs = await _instance;
    return prefs.setString("CountryCode", value);
  }

  static String getIsdCode() {
    return _prefsInstance?.getString("IsdCode") ?? "";
  }

  static Future<bool> setIsdCode(String value) async {
    var prefs = await _instance;
    return prefs.setString("IsdCode", value);
  }

  static String getUserName() {
    return _prefsInstance?.getString("UserName") ?? "";
  }

  static Future<bool> setUserName(String value) async {
    var prefs = await _instance;
    return prefs.setString("UserName", value);
  }

  static String getUserImage() {
    return _prefsInstance?.getString("UserImage") ?? "";
  }

  static Future<bool> setUserImage(String value) async {
    var prefs = await _instance;
    return prefs.setString("UserImage", value);
  }

  static String getMobileWithCountry() {
    return _prefsInstance?.getString("MobileWithCountry") ?? "";
  }

  static Future<bool> setMobileWithCountryo(String value) async {
    var prefs = await _instance;
    return prefs.setString("MobileWithCountry", value);
  }

  static bool getFirstTime() {
    return _prefsInstance?.getBool("FirstTime") ?? true;
  }

  static Future<bool> setFirstTime(bool value) async {
    var prefs = await _instance;
    return prefs.setBool("FirstTime", value);
  }

  static bool getFirstTimeIntro() {
    return _prefsInstance?.getBool("FirstTimeIntro") ?? true;
  }

  static Future<bool> setFirstTimeIntro(bool value) async {
    var prefs = await _instance;
    return prefs.setBool("FirstTimeIntro", value);
  }

  static bool ableToFetchCurrentLocation() {
    return _prefsInstance?.getBool("AbleToFetchCurrentLocation") ?? true;
  }

  static Future<bool> setAbleToFetchCurrentLocation(bool value) async {
    var prefs = await _instance;
    return prefs.setBool("AbleToFetchCurrentLocation", value);
  }

  static double getCurrentLatitude() {
    return _prefsInstance?.getDouble("CurrentLatitude") ?? 23.596802;
  }

  static double getCurrentLongitude() {
    return _prefsInstance?.getDouble("CurrentLongitude") ?? 58.4342;
  }

  static String getCurrentPlace() {
    return _prefsInstance?.getString("CurrentPlace") ?? "Al Khuwair";
  }

  static Future<bool> setCurrentLatitude(double value) async {
    var prefs = await _instance;
    return prefs.setDouble("CurrentLatitude", value);
  }

  static Future<bool> setCurrentLongitude(double value) async {
    var prefs = await _instance;
    return prefs.setDouble("CurrentLongitude", value);
  }

  static Future<bool> setCurrentPlace(String value) async {
    var prefs = await _instance;
    return prefs.setString("CurrentPlace", value);
  }

  static Future<void> remove() async {
    String fcmT = getFcmToken();
    SharedPreferences.getInstance().then((SharedPreferences pref) {
      pref.clear();
    });
    saveAppVersion();
    saveDeviceModel();
    StartupService.setFcmToken(fcmT);
    StartupService.setFirstTimeIntro(false);
  }

  static saveDeviceModel() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      StartupService.setDeviceManufacture(androidInfo.manufacturer ?? "-");
      StartupService.setDeviceModel(androidInfo.model??"-");
      StartupService.setDeviceOSVersion(androidInfo.version.release??"-");
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      StartupService.setDeviceManufacture("iOS");
      StartupService.setDeviceModel(iosInfo.utsname.machine??"-");
      StartupService.setDeviceOSVersion(iosInfo.systemVersion??"-");
    }
  }

  static saveAppVersion() async {
    PackageInfo _packageInfo = PackageInfo(
      appName: 'Unknown',
      packageName: 'Unknown',
      version: 'Unknown',
      buildNumber: 'Unknown',
      buildSignature: 'Unknown',
    );
    var appVersion = "1.0";
    _packageInfo = await PackageInfo.fromPlatform();
    appVersion = await _packageInfo.version;
    StartupService.setAppVersion(appVersion);
  }

// static getCurrentTime() {
//   var time = DateTime.now();
//   if (time.hour > 0 && time.hour < 12) {
//     StartupService.setGreeting("Good morning,");
//   } else if (time.hour >= 12 && time.hour < 18) {
//     StartupService.setGreeting("Good afternoon,");
//   } else {
//     StartupService.setGreeting("Good evening,");
//   }
// }
}
