import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'controller.dart';

class SettingPage extends StatelessWidget {
  SettingPage({super.key});

  // 使用Get.find避免重复创建，如果不存在则创建
  final controller = Get.isRegistered<SettingController>()
      ? Get.find<SettingController>()
      : Get.put(SettingController());
  final state = Get.find<SettingController>().state;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          '设置',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        // backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: controller.resetToDefaults,
            icon: const Icon(
              Icons.refresh_rounded,
              // color: Color(0xFF007AFF),
            ),
            tooltip: '重置为默认设置',
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            children: [
              // 专注设置组
              _buildSettingSection(
                title: '专注设置',
                children: [
                  _buildSettingTile(
                    title: '专注时间',
                    subtitle: '单次专注的持续时间',
                    trailing: _buildTimeInput(
                      controller: state.focusTimeController,
                      unit: '分钟',
                      onChanged: controller.updateFocusTime,
                      errorObs: state.focusTimeError,
                      settingController: controller,
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingTile(
                    title: '休息时间',
                    subtitle: '专注结束后的休息时间',
                    trailing: _buildTimeInput(
                      controller: state.bigBreakTimeController,
                      unit: '分钟',
                      onChanged: controller.updateBigBreakTime,
                      errorObs: state.bigBreakTimeError,
                      settingController: controller,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 微休息设置组
              _buildSettingSection(
                title: '微休息设置',
                children: [
                  _buildSettingTile(
                    title: '启用微休息',
                    subtitle: '在专注时间内定期提醒休息',
                    trailing: Obx(() => Switch(
                      value: state.microBreakEnabled.value,
                      onChanged: controller.toggleMicroBreakEnabled,
                      // activeColor: const Color(0xFF007AFF),
                    )),
                  ),
                  Obx(() => state.microBreakEnabled.value ? _buildDivider() : const SizedBox.shrink()),
                  Obx(() => state.microBreakEnabled.value ? _buildSettingTile(
                    title: '微休息时长',
                    subtitle: '每次微休息的持续时间',
                    trailing: _buildTimeInput(
                      controller: state.microBreakTimeController,
                      unit: '秒',
                      onChanged: controller.updateMicroBreakTime,
                      errorObs: state.microBreakTimeError,
                      settingController: controller,
                      enabled: state.microBreakEnabled.value,
                    ),
                  ) : const SizedBox.shrink()),
                  Obx(() => state.microBreakEnabled.value ? _buildDivider() : const SizedBox.shrink()),
                  Obx(() => state.microBreakEnabled.value ? _buildSettingTile(
                    title: '最小间隔',
                    subtitle: '两次微休息之间的最短时间间隔',
                    trailing: _buildTimeInput(
                      controller: state.microBreakIntervalMinController,
                      unit: '分钟',
                      onChanged: controller.updateMicroBreakIntervalMin,
                      errorObs: state.microBreakIntervalMinError,
                      settingController: controller,
                      enabled: state.microBreakEnabled.value,
                    ),
                  ) : const SizedBox.shrink()),
                  Obx(() => state.microBreakEnabled.value ? _buildDivider() : const SizedBox.shrink()),
                  Obx(() => state.microBreakEnabled.value ? _buildSettingTile(
                    title: '最大间隔',
                    subtitle: '两次微休息之间的最长时间间隔',
                    trailing: _buildTimeInput(
                      controller: state.microBreakIntervalMaxController,
                      unit: '分钟',
                      onChanged: controller.updateMicroBreakIntervalMax,
                      errorObs: state.microBreakIntervalMaxError,
                      settingController: controller,
                      enabled: state.microBreakEnabled.value,
                    ),
                  ) : const SizedBox.shrink()),
                ],
              ),

              const SizedBox(height: 24),

              // 显示设置组
              _buildSettingSection(
                title: '显示设置',
                children: [
                  _buildSettingTile(
                    title: '正向计时',
                    subtitle: '计时从0开始递增显示',
                    trailing: Obx(() => Switch(
                      value: state.isCountingUp.value,
                      onChanged: controller.toggleCountingDirection,
                      // activeColor: const Color(0xFF007AFF),
                    )),
                  ),
                  _buildDivider(),
                  _buildSettingTile(
                    title: '进度条正向填充',
                    subtitle: '圆形进度条从0开始填充',
                    trailing: Obx(() => Switch(
                      value: state.isProgressForward.value,
                      onChanged: controller.toggleProgressDirection,
                      // activeColor: const Color(0xFF007AFF),
                    )),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 保存按钮
              _buildSaveButton(controller),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建设置分组 - LocalSend风格
  Widget _buildSettingSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 分组标题
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8E8E93),
              letterSpacing: 0.5,
            ),
          ),
        ),
        // 设置卡片
        Card(
          margin: EdgeInsets.zero,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  /// 构建设置项
  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 标题和副标题
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 右侧控件
          trailing,
        ],
      ),
    );
  }

  /// 构建分割线
  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      height: 1,
      color: Colors.grey[200],
    );
  }

  /// 构建时间输入框 - LocalSend风格
  Widget _buildTimeInput({
    required TextEditingController controller,
    required String unit,
    required Function(String) onChanged,
    required RxString errorObs,
    required SettingController settingController,
    bool enabled = true,
  }) {
    return SizedBox(
      width: 80,
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            settingController.state.validateAll();
          }
        },
        child: TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: enabled ? Colors.black : Colors.grey[500],
          ),
          decoration: InputDecoration(
            suffixText: unit,
            suffixStyle: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              // borderSide: const BorderSide(color: Color(0xFF007AFF)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            fillColor: enabled ? null : Colors.grey[50],
            filled: !enabled,
          ),
        ),
      ),
    );
  }

  /// 构建保存按钮
  Widget _buildSaveButton(SettingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: controller.saveSettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE2E0F8),
            // foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: const Text(
            '保存设置',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
