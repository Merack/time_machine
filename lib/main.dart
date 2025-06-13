import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:time_machine/route/route_name.dart';
import 'package:time_machine/route/route_page.dart';
import 'package:time_machine/service/app_storage_service.dart';
import 'package:time_machine/service/database_service.dart';
import 'package:time_machine/theme/theme_controller.dart';
import 'package:time_machine/theme/app_themes.dart';

void main() async{
  // 确保 Flutter 环境已准备好
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(const MyApp());
}

Future<void> initServices() async {
  Get.log('starting services ...');

  // 异步初始化并注入 MMKV 存储服务
  await Get.putAsync(() => AppStorageService().init());

  // 异步初始化数据库服务
  await Get.putAsync(() => DatabaseService().init());


  // 初始化主题控制器
  Get.put(ThemeController());

  Get.log('All services started...');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      initialRoute: AppRoutes.INITIAL,
      getPages: AppPages.routes,
      // 主题配置
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeController.themeMode,
      // 调试配置
      debugShowCheckedModeBanner: false,
    );
  }
}

