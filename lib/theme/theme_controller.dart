import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mmkv/mmkv.dart';

import '../config/storage_keys.dart';
import '../service/app_storage_service.dart';
import 'app_themes.dart';

/// 主题控制器 - 管理应用主题状态
class ThemeController extends GetxController {
  late final MMKV _storage;
  
  // 当前主题模式
  final _themeMode = ThemeMode.system.obs;
  
  // 当前主题模式字符串
  final _themeModeString = StorageKeys.defaultThemeMode.obs;

  // 获取当前主题模式
  ThemeMode get themeMode => _themeMode.value;
  
  // 获取当前主题模式字符串
  String get themeModeString => _themeModeString.value;

  @override
  void onInit() {
    super.onInit();
    _storage = Get.find<AppStorageService>().mmkv;
    _loadThemeMode();
    // _listenToSystemThemeChanges();
  }

  /// 从存储中加载主题模式
  void _loadThemeMode() {
    final savedMode = _storage.decodeString(
      StorageKeys.themeMode,
    );
    
    _themeModeString.value = savedMode ?? StorageKeys.defaultThemeMode;
    _themeMode.value = AppThemes.getThemeModeFromString(_themeModeString.value);
    
    Get.log('主题模式已加载: ${_themeModeString.value}');
  }

  // 监听系统主题变化
  // void _listenToSystemThemeChanges() {
  //   // 当选择跟随系统时，监听系统主题变化
  //   ever(_themeMode, (ThemeMode mode) {
  //     if (mode == ThemeMode.system) {
  //       _updateSystemUI();
  //     }
  //   });
  // }

  // 动态调整系统状态栏和导航栏的样式, 比如改变电量图标的亮暗
  // 但是现在的操作系统都会自动处理了(至少在我用的vivo上是这样)
  // 所以还是先注释掉吧
  // void _updateSystemUI() {
  //   final brightness = Get.isDarkMode ? Brightness.light : Brightness.dark;
  //   SystemChrome.setSystemUIOverlayStyle(
  //     SystemUiOverlayStyle(
  //       statusBarBrightness: Get.isDarkMode ? Brightness.dark : Brightness.light,
  //       statusBarIconBrightness: brightness,
  //       systemNavigationBarIconBrightness: brightness,
  //     ),
  //   );
  // }

  void switchLightOrDark() {
    if (Get.isDarkMode) {
      Get.changeThemeMode(ThemeMode.light);
    } else {
      Get.changeThemeMode(ThemeMode.dark);
    }
  }

  // 切换主题模式
  void changeThemeMode(String mode) {
    if (_themeModeString.value == mode) return;
    
    _themeModeString.value = mode;
    _themeMode.value = AppThemes.getThemeModeFromString(mode);
    
    // 保存到存储
    _storage.encodeString(StorageKeys.themeMode, mode);
    
    // 应用主题变化
    Get.changeThemeMode(_themeMode.value);
    
    // 更新系统 UI
    // _updateSystemUI();
    
    Get.log('主题模式已切换到: $mode');
    
    // 显示切换提示
    // Get.snackbar(
    //   '主题已切换',
    //   '当前主题: ${AppThemes.getThemeModeDisplayName(mode)}',
    //   snackPosition: SnackPosition.TOP,
    //   duration: const Duration(seconds: 1),
    //   barBlur: 100.0,
    // );
  }

  /// 获取主题模式显示名称
  String getThemeModeDisplayName(String mode) {
    return AppThemes.getThemeModeDisplayName(mode);
  }

  /// 获取所有可用的主题模式
  List<String> get availableThemeModes => AppThemes.availableThemeModes;
}
