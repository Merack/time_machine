import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';
import 'state.dart';

class StatisticsPage extends StatelessWidget {
  StatisticsPage({Key? key}) : super(key: key);

  final StatisticsController controller = Get.put(StatisticsController());
  final StatisticsState state = Get.find<StatisticsController>().state;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
