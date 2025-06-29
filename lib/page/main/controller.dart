import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:time_machine/page/main/state.dart';

class MainController extends GetxController {
  final MainState state = MainState();
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: state.currentIndex.value);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  /// 页面切换时调用
  void onPageChanged(int index) {
    state.currentIndex.value = index;
  }

  /// 点击导航栏时调用
  void onNavigationTap(int index) {
    if (state.currentIndex.value != index) {
      pageController.jumpToPage(index);
    }
  }

  /// 处理返回键按下事件
  bool handleBackPressed() {
    final now = DateTime.now();
    final timeDifference = now.difference(state.lastBackPressTime);

    // 如果距离上次按返回键超过2秒, 显示提示并开始计时
    if (timeDifference.inSeconds > 2) {
      state.lastBackPressTime = now;

      // 显示Toast提示
      Get.snackbar(
        '',
        '再按一次返回键退出应用',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        barBlur: 100,
      );

      return false; // 不退出应用
    } else {
      // 2秒内再次按返回键, 退出应用
      SystemNavigator.pop(); // 退出应用
      return true;
    }
  }
}