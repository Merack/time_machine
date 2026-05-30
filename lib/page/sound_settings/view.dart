import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/storage_keys.dart';
import '../setting/widgets/setting_section.dart';
import '../setting/widgets/setting_tile.dart';
import '../setting/widgets/setting_divider.dart';
import 'controller.dart';
import 'widgets/sound_picker_dialog.dart';

class SoundSettingsPage extends StatelessWidget {
  const SoundSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<SoundSettingsController>()
        ? Get.find<SoundSettingsController>()
        : Get.put(SoundSettingsController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '提示音设置',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          children: [
            SettingSection(
              title: '事件提示音',
              children: [
                for (int i = 0; i < StorageKeys.soundEventIds.length; i++) ...[
                  _buildEventTile(controller, StorageKeys.soundEventIds[i]),
                  if (i != StorageKeys.soundEventIds.length - 1) const SettingDivider(),
                ],
              ],
            ),
            const SizedBox(height: 24),
            SettingSection(
              title: '说明',
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    '• 内置音效: 应用自带的几个提示音\n'
                    '• 系统铃声: 从系统铃声/通知音中选择\n'
                    '• 自定义: 通过文件管理器选择本机音频文件',
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
        ),
      ),
    );
  }

  Widget _buildEventTile(SoundSettingsController controller, String eventId) {
    return Obx(() {
      final config = controller.state.configs[eventId];
      final displayName = config?.displayName ?? '默认';
      return SettingTile(
        title: StorageKeys.eventDisplayNames[eventId] ?? eventId,
        subtitle: '当前: $displayName',
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _openPicker(controller, eventId),
      );
    });
  }

  Future<void> _openPicker(SoundSettingsController controller, String eventId) async {
    await Get.dialog(
      SoundPickerDialog(controller: controller, eventId: eventId),
      barrierDismissible: true,
    );
    // dialog 以任意方式关闭(按钮/遮罩/返回手势)后停止所有试听
    await controller.stopAllPreview();
  }
}
