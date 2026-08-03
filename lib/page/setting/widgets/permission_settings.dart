import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:time_machine/utils/toast_util.dart';

import '../../../service/permission_service.dart';
import 'permission_row.dart';
import 'setting_divider.dart';

/// 权限管理分组
///
/// 通知权限已移到通知设置二级页面(与各事件的通知开关放在一起),
/// 这里只保留存储和电池优化两项.
class PermissionSettings extends StatelessWidget {
  const PermissionSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final perm = Get.find<PermissionService>();

    return Column(
      children: [
        Obx(() => PermissionRow(
              title: '存储权限',
              subtitle: '用于备份恢复数据到 Download 目录,以及读取自定义提示音',
              status: perm.storageStatus.value,
              describe: perm.describeStatus(perm.storageStatus.value),
              onAction: () => _handleStorageAction(perm),
            )),
        const SettingDivider(),
        Obx(() => PermissionRow(
              title: '电池优化白名单',
              subtitle: '将本应用加入白名单, 确保后台计时不被系统终止',
              status: perm.batteryStatus.value,
              describe: perm.describeStatus(perm.batteryStatus.value),
              onAction: () => _handleBatteryAction(perm),
            )),
        _buildBatteryHint(context),
      ],
    );
  }

  /// 电池优化说明
  ///
  /// 各家 ROM 对 REQUEST_IGNORE_BATTERY_OPTIMIZATIONS 的处理差异很大,
  /// 系统对话框返回成功也不代表后台真的不会被杀, 所以这里明确引导用户手动设置.
  Widget _buildBatteryHint(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Text(
        '在此处请求的电池优化权限, 即使显示授权成功, 在某些系统上也可能并未真正生效. '
        '强烈建议手动在系统设置里搜索"电池优化", 将本应用加入白名单; '
        '同时在手机管家中把本应用的后台运行设为允许.\n'
        '本应用后台只维护必要的计时器, 耗电量极小.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.6,
        ),
      ),
    );
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
