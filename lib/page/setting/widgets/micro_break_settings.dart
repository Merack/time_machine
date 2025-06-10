import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:time_machine/page/setting/widgets/setting_tile.dart';
import 'package:time_machine/page/setting/widgets/time_input.dart';
import '../controller.dart';
import 'setting_switch.dart';
import 'setting_divider.dart';

/// 微休息设置组件
class MicroBreakSettings extends StatelessWidget {
  const MicroBreakSettings({
    super.key,
    required this.controller,
  });

  final SettingController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    
    return Obx(() {
      final isEnabled = state.microBreakEnabled.value;
      
      return Column(
        children: [
          SettingTile(
            title: '启用微休息',
            subtitle: '在专注时间内定期提醒休息',
            trailing: SettingSwitch(
              value: isEnabled,
              onChanged: controller.toggleMicroBreakEnabled,
            ),
          ),
          if (isEnabled) ...[
            const SettingDivider(),
            SettingTile(
              title: '微休息时长',
              subtitle: '每次微休息的持续时间',
              trailing: TimeInput(
                controller: state.microBreakTimeController,
                unit: '秒',
                onChanged: controller.updateMicroBreakTime,
                errorObs: state.microBreakTimeError,
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    controller.state.validateAll();
                  }
                },
                enabled: isEnabled,
              ),
            ),
            const SettingDivider(),
            SettingTile(
              title: '最小间隔',
              subtitle: '两次微休息之间的最短时间间隔',
              trailing: TimeInput(
                controller: state.microBreakIntervalMinController,
                unit: '分钟',
                onChanged: controller.updateMicroBreakIntervalMin,
                errorObs: state.microBreakIntervalMinError,
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    controller.state.validateAll();
                  }
                },
                enabled: isEnabled,
              ),
            ),
            const SettingDivider(),
            SettingTile(
              title: '最大间隔',
              subtitle: '两次微休息之间的最长时间间隔',
              trailing: TimeInput(
                controller: state.microBreakIntervalMaxController,
                unit: '分钟',
                onChanged: controller.updateMicroBreakIntervalMax,
                errorObs: state.microBreakIntervalMaxError,
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    controller.state.validateAll();
                  }
                },
                enabled: isEnabled,
              ),
            ),
          ],
        ],
      );
    });
  }
}
