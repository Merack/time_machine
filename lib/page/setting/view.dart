import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';
import 'widgets/widgets.dart';
import 'widgets/theme_selector.dart';
import 'test_data_controller.dart';
import '../../service/database_service.dart';

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
                    title: '主题模式',
                    subtitle: '选择应用的外观主题',
                    trailing: const ThemeSelector(),
                  ),
                  const SettingDivider(),
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

              const SizedBox(height: 24),

              // 开发者选项（仅调试模式显示）
              if (Get.isLogEnable) ...[
                SettingSection(
                  title: '开发者选项',
                  children: [
                    SettingTile(
                      title: '生成测试数据',
                      subtitle: '生成30天的模拟专注数据',
                      trailing: ElevatedButton(
                        onPressed: () async {
                          final testDataController = Get.put(TestDataController());
                          await testDataController.generateTestData();
                          Get.snackbar('成功', '测试数据已生成', duration: Duration(seconds: 1));
                        },
                        child: const Text('生成'),
                      ),
                    ),
                    const SettingDivider(),
                    SettingTile(
                      title: '数据库状态',
                      subtitle: '查看SQLite数据库信息',
                      trailing: ElevatedButton(
                        onPressed: () async {
                          final databaseService = Get.find<DatabaseService>();
                          final status = await databaseService.getDatabaseStatus();

                          Get.dialog(
                            AlertDialog(
                              title: const Text('数据库状态'),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('初始化状态: ${status['initialized'] ? '已初始化' : '未初始化'}'),
                                    if (status['version'] != null)
                                      Text('数据库版本: ${status['version']}'),
                                    if (status['path'] != null)
                                      Text('数据库路径: ${status['path']}'),
                                    if (status['tables'] != null)
                                      Text('数据表数量: ${(status['tables'] as List).length}'),
                                    if (status['error'] != null)
                                      Text('错误信息: ${status['error']}'),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('关闭'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('查看'),
                      ),
                    ),
                    const SettingDivider(),
                    SettingTile(
                      title: '重置数据库',
                      subtitle: '删除并重新创建数据库',
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                        ),
                        onPressed: () async {
                          final confirmed = await Get.dialog<bool>(
                            AlertDialog(
                              title: const Text('确认重置'),
                              content: const Text('此操作将删除所有专注记录, 确定要继续吗?'),
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

                          if (confirmed == true) {
                            final databaseService = Get.find<DatabaseService>();
                            await databaseService.resetDatabase();
                            Get.snackbar('成功', '数据库已重置', duration: Duration(seconds: 1));
                          }
                        },
                        child: const Text('重置'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

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
