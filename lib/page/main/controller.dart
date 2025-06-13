import 'package:flutter/material.dart';
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
}