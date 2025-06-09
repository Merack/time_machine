import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

/// 主页面，包含底部导航栏
class MainPage extends StatelessWidget {
  MainPage({super.key});

  // 使用Get.find避免重复创建，如果不存在则创建
  final controller = Get.isRegistered<MainController>()
      ? Get.find<MainController>()
      : Get.put(MainController(), permanent: true);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        onPageChanged: controller.onPageChanged,
        physics: const NeverScrollableScrollPhysics(), // 禁止滑动
        children: controller.state.pages,
      ),
      bottomNavigationBar: GetBuilder<MainController>(
        builder: (_) => BottomNavigationBar(
          currentIndex: controller.state.currentIndex,
          onTap: controller.onNavigationTap,
          type: BottomNavigationBarType.fixed,
          // backgroundColor: Colors.white,
          // selectedItemColor: const Color(0xFF007AFF),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          elevation: 8,
          items: controller.state.navigationItems.map((item) => BottomNavigationBarItem(
            icon: Icon(item.icon),
            activeIcon: Icon(item.activeIcon),
            label: item.label,
          )).toList(),
        ),
      ),
    );
  }
}