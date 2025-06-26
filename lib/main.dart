import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:time_machine/route/route_name.dart';
import 'package:time_machine/route/route_page.dart';
import 'package:time_machine/service/app_storage_service.dart';
import 'package:time_machine/service/database_service.dart';
import 'package:time_machine/service/background_timer_service.dart';
import 'package:time_machine/theme/theme_controller.dart';
import 'package:time_machine/theme/app_themes.dart';

void main() async {
  // 尝试找定位一下有时候冷启动闪退的原因, 希望有用吧
  // 全局错误捕获
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('Flutter错误: ${details.exception}');
    debugPrint('堆栈跟踪: ${details.stack}');
  };
  
  // 捕获未处理的异步错误
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('未捕获的平台错误: $error');
    debugPrint('堆栈跟踪: $stack');
    return true;
  };
  
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await initServices();
    runApp(const MyApp());
  } catch (e, stack) {
    debugPrint('应用启动错误: $e');
    debugPrint('堆栈跟踪: $stack');
    // 显示一个简单的错误界面
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('应用启动时发生错误, err: $e, stack: $stack'),
        ),
      ),
    ));
  }
  // 小白条沉浸
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 29) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      // statusBarColor: Colors.transparent,
    ));
  }
}

Future<void> initServices() async {
  Get.log('starting services ...');

  // 异步初始化并注入 MMKV 存储服务
  await Get.putAsync(() => AppStorageService().init());

  // 异步初始化数据库服务
  await Get.putAsync(() => DatabaseService().init());

  try {
    // 初始化后台计时器服务
    await Get.putAsync(() => BackgroundTimerService().init());
  } catch (e) {
    Get.log('BackgroundTimerService初始化失败: $e');
  }

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

