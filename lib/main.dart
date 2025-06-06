import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:time_machine/route/route_name.dart';
import 'package:time_machine/route/route_page.dart';
import 'package:time_machine/service/app_storage_service.dart';

void main() async{
  // 确保 Flutter 环境已准备好
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(const MyApp());
}

Future<void> initServices() async {
  Get.log('starting services ...');
  // 异步初始化并注入 MMKVService
  await Get.putAsync(()=>AppStorageService().init());
  Get.log('All services started...');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: AppRoutes.INITIAL,
      getPages: AppPages.routes,
    );
  }
}

