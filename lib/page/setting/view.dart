import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'controller.dart';
import '../../route/route_name.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用Get.find避免重复创建，如果不存在则创建
    final controller = Get.isRegistered<SettingController>()
        ? Get.find<SettingController>()
        : Get.put(SettingController());
    final state = controller.state;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: TextButton(
          onPressed: () {
            Get.toNamed(AppRoutes.ABOUT);
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          child: const Text('关于'),
        ),
        title: const Text(
          '设置',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600,),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: controller.resetToDefaults,
            child: const Text('重置'),
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
            padding: const EdgeInsets.all(16.0),
            children: [
            // 专注设置组
            _buildSettingGroup(
              title: '专注设置',
              icon: Icons.timer,
              children: [
                _buildTimeInputField(
                  label: '专注时间',
                  unit: '分钟',
                  textController: state.focusTimeController,
                  errorObs: state.focusTimeError,
                  onChanged: controller.updateFocusTime,
                  controller: controller,
                ),
                const SizedBox(height: 16),
                _buildTimeInputField(
                  label: '休息时间',
                  unit: '分钟',
                  textController: state.bigBreakTimeController,
                  errorObs: state.bigBreakTimeError,
                  onChanged: controller.updateBigBreakTime,
                  controller: controller,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 微休息设置组
            _buildSettingGroup(
              title: '微休息设置',
              icon: Icons.coffee,
              children: [
                // 微休息开关
                _buildSwitchTile(
                  title: '启用微休息',
                  subtitle: '在专注时间内定期提醒休息',
                  valueObs: state.microBreakEnabled,
                  onChanged: controller.toggleMicroBreakEnabled,
                ),
                const SizedBox(height: 16),
                Obx(() => _buildTimeInputField(
                  label: '微休息时长',
                  unit: '秒',
                  textController: state.microBreakTimeController,
                  errorObs: state.microBreakTimeError,
                  onChanged: controller.updateMicroBreakTime,
                  controller: controller,
                  enabled: state.microBreakEnabled.value,
                )),
                const SizedBox(height: 16),
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: _buildTimeInputField(
                        label: '间隔最小值',
                        unit: '分钟',
                        textController: state.microBreakIntervalMinController,
                        errorObs: state.microBreakIntervalMinError,
                        onChanged: controller.updateMicroBreakIntervalMin,
                        controller: controller,
                        enabled: state.microBreakEnabled.value,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimeInputField(
                        label: '间隔最大值',
                        unit: '分钟',
                        textController: state.microBreakIntervalMaxController,
                        errorObs: state.microBreakIntervalMaxError,
                        onChanged: controller.updateMicroBreakIntervalMax,
                        controller: controller,
                        enabled: state.microBreakEnabled.value,
                      ),
                    ),
                  ],
                )),
              ],
            ),

            const SizedBox(height: 20),

            // 行为控制设置组
            _buildSettingGroup(
              title: '行为控制',
              icon: Icons.settings,
              children: [
                _buildSwitchTile(
                  title: '正向计时',
                  subtitle: '计时从0开始递增',
                  valueObs: state.isCountingUp,
                  onChanged: controller.toggleCountingDirection,
                ),
                const SizedBox(height: 8),
                _buildSwitchTile(
                  title: '进度条正向填充',
                  subtitle: '圆形进度条从0开始填充',
                  valueObs: state.isProgressForward,
                  onChanged: controller.toggleProgressDirection,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 保存按钮
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  '保存设置',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
        ),
      ),
    );
  }

  /// 构建设置组
  Widget _buildSettingGroup({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF007AFF), size: 24,),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  /// 构建时间输入字段
  Widget _buildTimeInputField({
    required String label,
    required String unit,
    required TextEditingController textController,
    required RxString errorObs,
    required Function(String) onChanged,
    required SettingController controller,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    // 当输入框失去焦点时进行验证
                    controller.state.validateAll();
                  }
                },
                child: TextFormField(
                  controller: textController,
                  enabled: enabled,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly,],
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: enabled ? '请输入$label' : '已禁用',
                    suffixText: unit,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF007AFF)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    fillColor: enabled ? null : Colors.grey[100],
                    filled: !enabled,
                  ),
                  style: TextStyle(
                    color: enabled ? Colors.black87 : Colors.grey[500],
                  ),
                ),
              ),
            ),
          ],
        ),
        Obx(() {
          if (errorObs.value.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                errorObs.value,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
      ],
    );
  }

  /// 构建开关切换项
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required RxBool valueObs,
    required Function(bool) onChanged,
  }) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
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
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600],),
                  ),
                ],
              ),
            ),
            Switch(
              value: valueObs.value,
              onChanged: onChanged,
              activeColor: const Color(0xFF007AFF),
            ),
          ],
        ),
      ),
    );
  }
}
