import 'package:flutter/material.dart';

import '../home/view.dart';
import '../statistics/view.dart';
import '../setting/view.dart';

/// 导航项数据模型
class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class MainState {
  var currentIndex = 0;

  // 使用懒加载和const构造函数优化页面创建
  static final List<Widget> _pages = [
    HomePage(),
    StatisticsPage(),
    SettingPage(),
  ];

  // 导航项配置
  static const List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.timer_outlined,
      activeIcon: Icons.timer,
      label: '时钟',
    ),
    NavigationItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: '统计',
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: '设置',
    ),
  ];

  List<Widget> get pages => _pages;
  List<NavigationItem> get navigationItems => _navigationItems;
}