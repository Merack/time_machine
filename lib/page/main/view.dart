import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';
import 'state.dart';

/// 主页面，包含底部导航栏
class MainPage extends StatelessWidget {
  MainPage({super.key});

  final MainController controller = Get.put(MainController());
  final MainState state = Get.find<MainController>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: state.currentIndex.value,
        children: state.pages,
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: state.currentIndex.value,
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
      )),
    );
  }
}

