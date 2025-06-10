import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';
import 'widgets/widgets.dart';

class SettingPage extends StatelessWidget {
  SettingPage({super.key});

  final controller = Get.isRegistered<SettingController>()
      ? Get.find<SettingController>()
      : Get.put(SettingController());
  final state = Get.find<SettingController>().state;

  @override
  Widget build(BuildContext context) {
    // Get.log("setting view build");
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // 左侧重置按钮，替换默认返回按钮
        leading: IconButton(
          onPressed: controller.toAboutPage,
          icon: const Icon(Icons.info_outline),
          tooltip: '关于',
        ),
        title: Text(
          '设置',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        // 右侧按钮
        actions: [
          IconButton(
            onPressed: controller.resetToDefaults,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: '重置为默认设置',
          ),
          IconButton(
            onPressed: controller.saveSettings,
            icon: const Icon(Icons.check_rounded),
            tooltip: '保存设置',
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            // 点击页面任何地方都会触发当前聚焦输入框失去焦点
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            children: [
              // 专注设置组
              SettingSection(
                title: '专注设置',
                children: [
                  SettingTile(
                    title: '专注时间',
                    subtitle: '单次专注的持续时间',
                    trailing: TimeInput(
                      controller: state.focusTimeController,
                      unit: '分钟',
                      onChanged: controller.updateFocusTime,
                      errorObs: state.focusTimeError,
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) {
                          controller.state.validateAll();
                        }
                      },
                    ),
                  ),
                  const SettingDivider(),
                  SettingTile(
                    title: '休息时间',
                    subtitle: '专注结束后的休息时间',
                    trailing: TimeInput(
                      controller: state.bigBreakTimeController,
                      unit: '分钟',
                      onChanged: controller.updateBigBreakTime,
                      errorObs: state.bigBreakTimeError,
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) {
                          controller.state.validateAll();
                        }
                      },
                    ),
                  ),
                  const SettingDivider(),
                  SettingTile(
                    title: '自动开始下一个',
                    subtitle: '休息结束后自动开始下一个专注',
                    trailing: Obx(() => SettingSwitch(
                      value: state.autoStartNextFocus.value,
                      onChanged: controller.toggleAutoStartNextFocus,
                    )),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 微休息设置组
              SettingSection(
                title: '微休息设置',
                children: [
                  MicroBreakSettings(controller: controller),
                ],
              ),

              const SizedBox(height: 24),

              // 显示设置组
              SettingSection(
                title: '显示设置',
                children: [
                  SettingTile(
                    title: '正向计时',
                    subtitle: '计时从0开始递增显示',
                    trailing: Obx(() => SettingSwitch(
                      value: state.isCountingUp.value,
                      onChanged: controller.toggleCountingDirection,
                    )),
                  ),
                  const SettingDivider(),
                  SettingTile(
                    title: '进度条正向填充',
                    subtitle: '圆形进度条从0开始填充',
                    trailing: Obx(() => SettingSwitch(
                      value: state.isProgressForward.value,
                      onChanged: controller.toggleProgressDirection,
                    )),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 保存按钮
              SaveButton(
                onPressed: controller.saveSettings,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
