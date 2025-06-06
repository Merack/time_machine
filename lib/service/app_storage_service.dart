import 'package:get/get.dart';
import 'package:mmkv/mmkv.dart';

class AppStorageService extends GetxService {
  late final MMKV _mmkv;
  MMKV get mmkv => _mmkv;

  Future<AppStorageService> init() async {
    final rootDir = await MMKV.initialize();
    Get.log('MMKV for flutter with rootDir = $rootDir');
    _mmkv = MMKV.defaultMMKV();
    return this;
  }
}