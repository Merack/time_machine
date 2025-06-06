import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home/view.dart';
import '../setting/view.dart';

class MainState{
  var currentIndex = 0.obs;

  final List<Widget> pages = [
    HomePage(),
    SettingPage(),
  ];
}