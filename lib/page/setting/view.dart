import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';
import 'state.dart';

class SettingPage extends StatelessWidget {
  SettingPage({Key? key}) : super(key: key);

  final SettingController controller = Get.put(SettingController());
  final SettingState state = Get.find<SettingController>().state;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
