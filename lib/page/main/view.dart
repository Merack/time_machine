import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';
import '../home/controller.dart';

/// 主页面, 包含底部导航栏, 仅用来导航
class MainPage extends StatelessWidget {
  MainPage({super.key});

  final controller = Get.isRegistered<MainController>()
      ? Get.find<MainController>()
      : Get.put(MainController());
  final homeController = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(HomeController());

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Obx(() => Scaffold(
      // 用来解决禅模式下隐藏navigatorBar后mainPage Scaffold默认背景带来的颜色不一致问题
      // 因为navigatorBar设置为不可见后底部就露出来了, HomePage又因为navigatorBar还在文档流中占位置无法延伸到底部
      // 所以底部会有一块宽高和navigatorBar一样大小的区域, 颜色为Scaffold默认背景色
      // 来个五彩斑斓的黑吧~~
      backgroundColor: homeController.state.isZenMode.value ? Colors.black : theme.colorScheme.surface,
      body: PageView(
        controller: controller.pageController,
        onPageChanged: controller.onPageChanged,
        physics: const NeverScrollableScrollPhysics(), // 禁止滑动
        children: controller.state.pages,
      ),
      bottomNavigationBar: Obx(() {
        // 检查是否在首页且处于禅模式
        final isHomePage = controller.state.currentIndex.value == 0;
        final isZenMode = isHomePage && homeController.state.isZenMode.value;
        // 如果在首页且为禅模式, 隐藏底部导航栏但保持占位
        return Visibility(
          visible: !isZenMode,
          maintainSize: true,
          maintainState: true,
          maintainAnimation: true,
          child: BottomNavigationBar(
            currentIndex: controller.state.currentIndex.value,
            onTap: controller.onNavigationTap,
            type: BottomNavigationBarType.fixed,
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
        );
      }),
    ));
  }
}