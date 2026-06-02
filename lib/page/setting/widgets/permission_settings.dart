import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:time_machine/utils/toast_util.dart';

import '../../../service/permission_service.dart';
import 'setting_tile.dart';
import 'setting_divider.dart';

/// 权限管理分组
class PermissionSettings extends StatelessWidget {
  const PermissionSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final perm = Get.find<PermissionService>();

    return Column(
      children: [
        Obx(() => _PermissionRow(
              title: '通知权限',
              subtitle: '用于专注完成、休息开始等通知栏提醒',
              status: perm.notificationStatus.value,
              describe: perm.describeStatus(perm.notificationStatus.value),
              onAction: () => _handleNotificationAction(perm),
            )),
        const SettingDivider(),
        Obx(() => _PermissionRow(
              title: '存储权限',
              subtitle: '用于备份恢复数据到 Download 目录,以及读取自定义提示音',
              status: perm.storageStatus.value,
              describe: perm.describeStatus(perm.storageStatus.value),
              onAction: () => _handleStorageAction(perm),
            )),
        const SettingDivider(),
        Obx(() => _PermissionRow(
              title: '电池优化白名单',
              subtitle: '将本应用加入白名单, 确保后台计时不被系统终止. '
                  '本应用后台仅运行计时器, 耗电极低',
              status: perm.batteryStatus.value,
              describe: perm.describeStatus(perm.batteryStatus.value),
              onAction: () => _handleBatteryAction(perm),
            )),
      ],
    );
  }

  Future<void> _handleNotificationAction(PermissionService perm) async {
    final s = perm.notificationStatus.value;
    if (s.isPermanentlyDenied) {
      _showOpenSettingsHint();
      await perm.openSettings();
      return;
    }
    await perm.requestNotification();
  }

  Future<void> _handleStorageAction(PermissionService perm) async {
    final s = perm.storageStatus.value;
    if (s.isPermanentlyDenied) {
      _showOpenSettingsHint();
      await perm.openSettings();
      return;
    }
    await perm.requestStorage();
  }

  Future<void> _handleBatteryAction(PermissionService perm) async {
    final s = perm.batteryStatus.value;
    if (s.isPermanentlyDenied) {
      _showOpenSettingsHint();
      await perm.openSettings();
      return;
    }
    await perm.requestBatteryWhitelist();
  }

  void _showOpenSettingsHint() {
    ToastUtil.show('需要在系统设置中手动开启', '权限已被永久拒绝, 即将跳转到应用设置');
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.describe,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final PermissionStatus status;
  final String describe;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final granted = status.isGranted;

    return SettingTile(
      title: title,
      subtitle: subtitle,
      trailing: granted
          ? _StatusBadge(text: describe, color: Colors.green.shade600)
          : ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: status.isPermanentlyDenied
                    ? theme.colorScheme.error
                    : null,
                foregroundColor: status.isPermanentlyDenied
                    ? theme.colorScheme.onError
                    : null,
              ),
              child: Text(status.isPermanentlyDenied ? '去设置' : '去授权'),
            ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
