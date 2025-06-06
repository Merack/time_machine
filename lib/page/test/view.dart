import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mmkv/mmkv.dart';

import '../../route/route_name.dart';
import '../../service/app_storage_service.dart';
import 'controller.dart';
import 'state.dart';

class TestPage extends StatelessWidget {
  TestPage({Key? key}) : super(key: key);

  final TestController controller = Get.put(TestController());
  final TestState state = Get.find<TestController>().state;
  final MMKV storage = Get.find<AppStorageService>().mmkv;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Obx(() => Text("click ${state.count}"),)),
      body: Center(child: ElevatedButton(onPressed: () => Get.toNamed(AppRoutes.HOME),
          child: Text(storage.decodeString("msg")?? "")),),
      floatingActionButton: FloatingActionButton(onPressed: controller.increment, child: Icon(Icons.add),),
    );
  }
}

class Other extends StatelessWidget {
   Other({super.key});

  final TestController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("${controller.state.count}"),),);
  }
}

