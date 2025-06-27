import 'package:package_info_plus/package_info_plus.dart';

class AppConfig {
  // static bool isDebug = false;
  static const String AUTHOR = "Merack";
  static const String GITHUB = "https://github.com/Merack/time_machine";
  static const String APPNAME = "Time Machine";
  static Future<String> get APPVERSION async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
  static const String ORGANIZATION = "Future Gadget Lab";
}