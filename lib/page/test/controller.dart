import 'package:get/get.dart';
import 'package:mmkv/mmkv.dart';

import '../../service/app_storage_service.dart';
import 'state.dart';

class TestController extends GetxController {
  final TestState state = TestState();
  @override
  void onInit() {
    super.onInit();
    MMKV storage = Get.find<AppStorageService>().mmkv;
    storage.encodeString("msg", "mmkv message");
  }
  void increment() {
    state.count.value++;
  }
}
