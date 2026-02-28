import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller.dart';
import 'setting_tile.dart';
import 'time_input.dart';
import 'setting_divider.dart';

/// 番茄时钟设置组件
class PomodoroSettings extends StatelessWidget {
  const PomodoroSettings({
    super.key,
    required this.controller,
  });

  final SettingController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;

    return Column(
      children: [
        SettingTile(
          title: '专注时长',
          subtitle: '每个番茄的专注时间',
          trailing: TimeInput(
            controller: state.pomodoroFocusController,
            unit: '分钟',
            onChanged: controller.updatePomodoroFocusTime,
            errorObs: state.pomodoroFocusError,
            onFocusChange: (hasFocus) {
              if (!hasFocus) controller.state.validateAll();
            },
          ),
        ),
        const SettingDivider(),
        SettingTile(
          title: '短休息时长',
          subtitle: '每个番茄后的短休息时间',
          trailing: TimeInput(
            controller: state.pomodoroShortBreakController,
            unit: '分钟',
            onChanged: controller.updatePomodoroShortBreak,
            errorObs: state.pomodoroShortBreakError,
            onFocusChange: (hasFocus) {
              if (!hasFocus) controller.state.validateAll();
            },
          ),
        ),
        const SettingDivider(),
        SettingTile(
          title: '长休息时长',
          subtitle: '每隔N个番茄后的长休息时间',
          trailing: TimeInput(
            controller: state.pomodoroLongBreakController,
            unit: '分钟',
            onChanged: controller.updatePomodoroLongBreak,
            errorObs: state.pomodoroLongBreakError,
            onFocusChange: (hasFocus) {
              if (!hasFocus) controller.state.validateAll();
            },
          ),
        ),
        const SettingDivider(),
        SettingTile(
          title: '长休息间隔',
          subtitle: '每隔几个番茄触发一次长休息',
          trailing: Obx(() => TimeInput(
            controller: state.pomodoroIntervalController,
            unit: '个',
            onChanged: controller.updatePomodoroInterval,
            errorObs: state.pomodoroIntervalError,
            onFocusChange: (hasFocus) {
              if (!hasFocus) controller.state.validateAll();
            },
          )),
        ),
      ],
    );
  }
}
