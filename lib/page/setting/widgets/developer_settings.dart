import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:time_machine/page/setting/widgets/setting_divider.dart';
import 'package:time_machine/page/setting/widgets/setting_section.dart';
import 'package:time_machine/page/setting/widgets/setting_tile.dart';

import '../../../service/database_service.dart';
import '../test_data_controller.dart';

class DeveloperSettings extends StatelessWidget {
  const DeveloperSettings({super.key});

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    return SettingSection(
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
        // SettingTile(
        //   title: '重置数据库',
        //   subtitle: '删除并重新创建数据库',
        //   trailing: ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: theme.colorScheme.error,
        //       foregroundColor: theme.colorScheme.onError,
        //     ),
        //     onPressed: () async {
        //       final confirmed = await Get.dialog<bool>(
        //         AlertDialog(
        //           title: const Text('确认重置'),
        //           content: const Text('此操作将删除所有专注记录, 确定要继续吗?'),
        //           actions: [
        //             TextButton(
        //               onPressed: () => Get.back(result: false),
        //               child: const Text('取消'),
        //             ),
        //             TextButton(
        //               onPressed: () => Get.back(result: true),
        //               child: const Text('确定'),
        //             ),
        //           ],
        //         ),
        //       );
        //
        //       if (confirmed == true) {
        //         final databaseService = Get.find<DatabaseService>();
        //         await databaseService.resetDatabase();
        //         Get.snackbar('成功', '数据库已重置', duration: Duration(seconds: 1));
        //       }
        //     },
        //     child: const Text('重置'),
        //   ),
        // ),
      ],
    );
  }
}
