import 'package:flutter/material.dart';

import '../home/view.dart';
import '../setting/view.dart';

class MainState{
  var currentIndex = 0;

  final List<Widget> pages = [
    HomePage(),
    SettingPage(),
  ];
}