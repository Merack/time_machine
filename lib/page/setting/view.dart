import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../route/route_name.dart';
import 'controller.dart';
import 'widgets/widgets.dart';
import 'widgets/theme_selector.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<SettingController>()
        ? Get.find<SettingController>()
        : Get.put(SettingController());
    final state = Get.find<SettingController>().state;
    // Get.log("setting view build");
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // 左侧重置按钮, 替换默认返回按钮
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
            // onPressed: controller.resetToDefaults,
            onPressed: () async {
              final confirmed = await Get.dialog<bool>(
                AlertDialog(
                  title: const Text('确认重置'),
                  content: const Text('此操作将重置设置为默认值, 确定要继续吗?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () => Get.back(result: true),
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );

              // 对话框关闭后,主动清除焦点
              // FocusManager.instance.primaryFocus?.unfocus();

              if (confirmed == true) {
                controller.resetToDefaults();
              }
            },
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
            // FocusScope.of(context).unfocus();

            // fix bug: 如果用FocusScope.of的方式, 那么在dialog出现前如果执行以下操作:
            // 点击文本框->失去焦点->打开dialog
            // 此时无论dialog是取消还是确定都会重新聚焦到文本框并弹出键盘
            // 原因是FocusScope会记住之前的焦点并在路由恢复时恢复这个焦点, 即使已经使用了unfocus(), 有点小坑
            // FocusManager.instance的方式虽然不优雅但是管用
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            children: [
              // 番茄时钟设置组（始终显示，供用户预先配置）
              SettingSection(
                title: '番茄时钟设置',
                children: [PomodoroSettings(controller: controller)],
              ),

              const SizedBox(height: 24),

              // 随机提示音设置组
              SettingSection(
                title: '随机提示音设置',
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
                  MicroBreakSettings(controller: controller),
                ],
              ),

              const SizedBox(height: 24),

              // 提示音与通知入口(进入二级页面)
              SettingSection(
                title: '提示音与通知',
                children: [
                  SettingTile(
                    title: '提示音设置',
                    subtitle: '为各计时事件单独选择提示音',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Get.toNamed(AppRoutes.SOUND_SETTINGS),
                  ),
                  const SettingDivider(),
                  SettingTile(
                    title: '通知设置',
                    subtitle: '通知权限, 以及各计时事件的通知栏提醒开关',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Get.toNamed(AppRoutes.NOTIFICATION_SETTINGS),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 显示设置组
              SettingSection(
                title: '显示与行为',
                children: [
                  SettingTile(
                    title: '自动开始下一个',
                    subtitle: '休息结束后自动开始下一个专注',
                    trailing: Obx(
                      () => SettingSwitch(
                        value: state.autoStartNextFocus.value,
                        onChanged: controller.toggleAutoStartNextFocus,
                      ),
                    ),
                  ),
                  const SettingDivider(),
                  SettingTile(
                    title: '正向计时',
                    subtitle: '计时从0开始递增显示',
                    trailing: Obx(
                      () => SettingSwitch(
                        value: state.isCountingUp.value,
                        onChanged: controller.toggleCountingDirection,
                      ),
                    ),
                  ),
                  const SettingDivider(),
                  SettingTile(
                    title: '进度条正向填充',
                    subtitle: '圆形进度条从0开始填充',
                    trailing: Obx(
                      () => SettingSwitch(
                        value: state.isProgressForward.value,
                        onChanged: controller.toggleProgressDirection,
                      ),
                    ),
                  ),
                  const SettingDivider(),
                  SettingTile(
                    title: '主题模式',
                    subtitle: '选择应用的外观主题',
                    trailing: const ThemeSelector(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              if (Platform.isAndroid) ...[
                SettingSection(
                  title: '实验性功能',
                  children: [
                    SettingTile(
                      title: '增强后台保留',
                      subtitle: '计时器运行期间循环播放静音音频',
                      trailing: Obx(
                        () => SettingSwitch(
                          value: state.backgroundRetentionEnabled.value,
                          onChanged: controller.toggleBackgroundRetention,
                        ),
                      ),
                    ),
                    const SettingDivider(),
                    SettingTile(
                      title: '与其他媒体同时播放',
                      subtitle: '开启后不主动请求音频焦点',
                      trailing: Obx(
                        () => SettingSwitch(
                          value: state.backgroundRetentionMixWithOthers.value,
                          onChanged:
                              controller.toggleBackgroundRetentionMixWithOthers,
                        ),
                      ),
                    ),
                    const SettingDivider(),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        '计时器运行时启动前台媒体服务，并循环播放本地静音音频，让系统按媒体播放场景保留应用。'
                        '该方式只能提高后台运行概率，不能绕过系统或厂商的电池限制，并可能增加耗电。'
                        '开启与其他媒体同时播放后通常不会打断网课或音乐，但不同系统和播放器仍可能发生冲突。',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // 权限管理分组
              SettingSection(
                title: '权限管理',
                children: const [PermissionSettings()],
              ),

              const SizedBox(height: 24),

              // 数据设置组
              SettingSection(
                title: '数据设置',
                children: [DataSettings(controller: controller)],
              ),

              const SizedBox(height: 24),

              // 开发者选项（仅调试模式显示）
              if (Get.isLogEnable) ...[
                DeveloperSettings(),
                const SizedBox(height: 24),
              ],

              // 保存按钮
              SaveButton(onPressed: controller.saveSettings),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
