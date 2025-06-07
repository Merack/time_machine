import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

/// 主页面，包含底部导航栏
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<MainController>(
        init: MainController(),
        builder: (controller) {
          return IndexedStack(
            index: controller.state.currentIndex,
            children: controller.state.pages,
          );
        },
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          // 1. 设置高亮色为透明
          highlightColor: Colors.transparent,
          // 2. 提供一个“无效果”的水波纹工厂
          splashFactory: NoSplash.splashFactory,
        ),
        child: GetBuilder<MainController>(
          builder: (controller) {
            return BottomNavigationBar(
              currentIndex: controller.state.currentIndex,
              onTap: (index) {
                controller.updateIndex(index);
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF007AFF),
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
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.timer),
                  activeIcon: Icon(Icons.timer),
                  label: '时钟',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  activeIcon: Icon(Icons.settings),
                  label: '设置',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
