import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:time_machine/page/home/view.dart';
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
  print('starting services ...');
  // 异步初始化并注入 MMKVService
  await Get.putAsync(()=>AppStorageService().init());
  print('All services started...');
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

