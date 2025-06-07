import 'package:flutter/material.dart';

import '../home/view.dart';
import '../setting/view.dart';

class MainState{
  var currentIndex = 0;

  // 使用懒加载和const构造函数优化页面创建
  static final List<Widget> _pages = [
    const HomePage(),
    const SettingPage(),
  ];

  List<Widget> get pages => _pages;
}