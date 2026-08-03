import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/storage_keys.dart';
import '../setting/widgets/permission_row.dart';
import '../setting/widgets/setting_divider.dart';
import '../setting/widgets/setting_section.dart';
import '../setting/widgets/setting_switch.dart';
import '../setting/widgets/setting_tile.dart';
import 'controller.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<NotificationSettingsController>()
        ? Get.find<NotificationSettingsController>()
        : Get.put(NotificationSettingsController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '通知设置',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          children: [
            SettingSection(
              title: '权限',
              children: [
                Obx(() {
                  final perm = controller.permissionService;
                  return PermissionRow(
                    title: '通知权限',
                    subtitle: '用于专注完成、休息结束等通知栏提醒',
                    status: perm.notificationStatus.value,
                    describe: perm.describeStatus(perm.notificationStatus.value),
                    onAction: controller.handlePermissionAction,
                  );
                }),
              ],
            ),
            const SizedBox(height: 24),
            SettingSection(
              title: '事件提醒通知',
              children: [
                for (int i = 0; i < StorageKeys.soundEventIds.length; i++) ...[
                  _buildEventSwitch(controller, StorageKeys.soundEventIds[i]),
                  if (i != StorageKeys.soundEventIds.length - 1)
                    const SettingDivider(),
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
                    '• 通知会带系统提示音和振动, 与应用自身的提示音同时触发\n'
                    '• 微休息在随机提示音模式下每几分钟触发一次, 开启后通知会比较频繁\n'
                    '• 暂停和从暂停恢复不发送通知\n'
                    '• 开关改动立即生效, 无需点击保存',
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

  Widget _buildEventSwitch(
      NotificationSettingsController controller, String eventId) {
    return SettingTile(
      title: StorageKeys.eventDisplayNames[eventId] ?? eventId,
      subtitle: StorageKeys.notificationBodies[eventId] ?? '发送通知栏提醒',
      trailing: Obx(() => SettingSwitch(
            value: controller.state.enabled[eventId] ?? false,
            onChanged: (value) => controller.toggleEvent(eventId, value),
          )),
    );
  }
}
