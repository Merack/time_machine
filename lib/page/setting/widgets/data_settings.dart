import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../service/database_service.dart';
import '../controller.dart';
import 'setting_tile.dart';
import 'setting_divider.dart';

/// 数据设置组件
class DataSettings extends StatelessWidget {
  const DataSettings({
    super.key,
    required this.controller,
  });

  final SettingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // 数据备份
        SettingTile(
          title: '数据备份',
          subtitle: '备份专注统计和应用设置到Download目录',
          trailing: Obx(() => ElevatedButton(
            onPressed: controller.state.isBackupInProgress.value
                ? null
                : controller.performBackup,
            child: controller.state.isBackupInProgress.value
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary,
                      ),
                    ),
                  )
                : const Text('备份'),
          )),
        ),
        
        const SettingDivider(),
        
        // 数据恢复
        SettingTile(
          title: '数据恢复',
          subtitle: '从备份文件恢复专注统计和应用设置',
          trailing: Obx(() => ElevatedButton(
            onPressed: controller.state.isRestoreInProgress.value
                ? null
                : controller.performRestore,
            child: controller.state.isRestoreInProgress.value
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onSecondary,
                      ),
                    ),
                  )
                : const Text('选择文件'),
          )),
        ),

        const SettingDivider(),

        // 重置数据库
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
                Get.snackbar('成功', '数据库已重置', 
                duration: Duration(seconds: 1),
                barBlur: 100,
                );
              }
            },
            child: const Text('重置'),
          ),
        ),
      ],
    );
  }
}
