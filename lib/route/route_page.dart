import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:time_machine/route/route_name.dart';

import '../page/test/view.dart';
import '../page/main/view.dart';
import '../page/home/view.dart';
import '../page/setting/view.dart';
import '../page/about/view.dart';

class AppPages {
  // 私有化构造函数
  AppPages._();

  static final routes = [
    GetPage(name: AppRoutes.MAIN, page: () => const MainPage()),
    GetPage(name: AppRoutes.TEST, page: () => TestPage()),
    GetPage(name: AppRoutes.HOME, page: () => HomePage()),
    GetPage(name: AppRoutes.SETTING, page: () => SettingPage()),
    GetPage(name: AppRoutes.OTHER, page: () => Other()),
    GetPage(name: AppRoutes.ABOUT, page: () => const AboutPage()),
  ];
}