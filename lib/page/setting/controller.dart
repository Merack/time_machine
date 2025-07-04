import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mmkv/mmkv.dart';
import 'package:time_machine/route/route_name.dart';

import '../../service/app_storage_service.dart';
import '../../database/backup_restore_db_service.dart';
import '../../config/storage_keys.dart';
import '../home/controller.dart';
import 'state.dart';

class SettingController extends GetxController {
  final SettingState state = SettingState();
  late final MMKV _storage;

  @override
  void onInit() {
    // Get.log("setting controller onInit");
    super.onInit();
    _storage = Get.find<AppStorageService>().mmkv;
    _loadSettings();
  }

  @override
  void onClose() {
    state.dispose();
    super.onClose();
  }

  /// 从存储中加载设置
  void _loadSettings() {
    // Get.log("setting controller _loadSettings");
    state.focusTimeMinutes.value = _storage.decodeInt(
      StorageKeys.focusTimeMinutes,
      defaultValue: StorageKeys.defaultFocusTimeMinutes,
    );

    state.bigBreakTimeMinutes.value = _storage.decodeInt(
      StorageKeys.bigBreakTimeMinutes,
      defaultValue: StorageKeys.defaultBigBreakTimeMinutes,
    );

    state.microBreakEnabled.value = _storage.decodeBool(
      StorageKeys.microBreakEnabled,
      defaultValue: StorageKeys.defaultMicroBreakEnabled,
    );

    state.microBreakTimeSeconds.value = _storage.decodeInt(
      StorageKeys.microBreakTimeSeconds,
      defaultValue: StorageKeys.defaultMicroBreakTimeSeconds,
    );

    state.microBreakIntervalMinMinutes.value = _storage.decodeInt(
      StorageKeys.microBreakIntervalMinMinutes,
      defaultValue: StorageKeys.defaultMicroBreakIntervalMinMinutes,
    );

    state.microBreakIntervalMaxMinutes.value = _storage.decodeInt(
      StorageKeys.microBreakIntervalMaxMinutes,
      defaultValue: StorageKeys.defaultMicroBreakIntervalMaxMinutes,
    );

    state.isCountingUp.value = _storage.decodeBool(
      StorageKeys.isCountingUp,
      defaultValue: StorageKeys.defaultIsCountingUp,
    );

    state.isProgressForward.value = _storage.decodeBool(
      StorageKeys.isProgressForward,
      defaultValue: StorageKeys.defaultIsProgressForward,
    );

    state.autoStartNextFocus.value = _storage.decodeBool(
      StorageKeys.autoStartNextFocus,
      defaultValue: StorageKeys.defaultAutoStartNextFocus,
    );

    // 更新控制器文本
    state.updateControllers();
  }

  void toAboutPage() {
    Get.toNamed(AppRoutes.ABOUT);
  }

  /// 保存设置到存储
  void saveSettings() {
    if (!state.validateAll()) {
      Get.snackbar(
        '验证失败',
        '请检查输入的设置值',
        snackPosition: SnackPosition.TOP,
        barBlur: 100,
        duration: Duration(seconds: 2)
      );
      return;
    }

    _storage.encodeInt(StorageKeys.focusTimeMinutes, state.focusTimeMinutes.value);
    _storage.encodeInt(StorageKeys.bigBreakTimeMinutes, state.bigBreakTimeMinutes.value);
    _storage.encodeBool(StorageKeys.microBreakEnabled, state.microBreakEnabled.value);
    _storage.encodeInt(StorageKeys.microBreakTimeSeconds, state.microBreakTimeSeconds.value);
    _storage.encodeInt(StorageKeys.microBreakIntervalMinMinutes, state.microBreakIntervalMinMinutes.value);
    _storage.encodeInt(StorageKeys.microBreakIntervalMaxMinutes, state.microBreakIntervalMaxMinutes.value);
    _storage.encodeBool(StorageKeys.isCountingUp, state.isCountingUp.value);
    _storage.encodeBool(StorageKeys.isProgressForward, state.isProgressForward.value);
    _storage.encodeBool(StorageKeys.autoStartNextFocus, state.autoStartNextFocus.value);

    Get.snackbar(
      '设置已保存',
      '所有设置已成功保存',
      snackPosition: SnackPosition.TOP,
      barBlur: 100.0,
      duration: Duration(seconds: 1),
    );

    // 通知 HomeController 重新加载设置
    try {
      final homeController = Get.find<HomeController>();
      homeController.reloadSettings();
    } catch (e) {
      // HomeController 可能还没有初始化, 忽略错误
    }
  }

  /// 重置为默认设置
  void resetToDefaults() {
    state.focusTimeMinutes.value = StorageKeys.defaultFocusTimeMinutes;
    state.bigBreakTimeMinutes.value = StorageKeys.defaultBigBreakTimeMinutes;
    state.microBreakEnabled.value = StorageKeys.defaultMicroBreakEnabled;
    state.microBreakTimeSeconds.value = StorageKeys.defaultMicroBreakTimeSeconds;
    state.microBreakIntervalMinMinutes.value = StorageKeys.defaultMicroBreakIntervalMinMinutes;
    state.microBreakIntervalMaxMinutes.value = StorageKeys.defaultMicroBreakIntervalMaxMinutes;
    state.isCountingUp.value = StorageKeys.defaultIsCountingUp;
    state.isProgressForward.value = StorageKeys.defaultIsProgressForward;
    state.autoStartNextFocus.value = StorageKeys.defaultAutoStartNextFocus;

    state.updateControllers();
    state.clearErrors();

    Get.snackbar(
      '已重置',
      '所有设置已重置为默认值',
      snackPosition: SnackPosition.TOP,
      barBlur: 100.0,
      duration: Duration(seconds: 1),
    );
  }

  /// 更新专注时间
  void updateFocusTime(String value) {
    final intValue = int.tryParse(value);
    if (intValue != null) {
      state.focusTimeMinutes.value = intValue;
    }
  }

  /// 更新大休息时间
  void updateBigBreakTime(String value) {
    final intValue = int.tryParse(value);
    if (intValue != null) {
      state.bigBreakTimeMinutes.value = intValue;
    }
  }

  /// 更新微休息时长
  void updateMicroBreakTime(String value) {
    final intValue = int.tryParse(value);
    if (intValue != null) {
      state.microBreakTimeSeconds.value = intValue;
    }
  }

  /// 更新微休息间隔最小值
  void updateMicroBreakIntervalMin(String value) {
    final intValue = int.tryParse(value);
    if (intValue != null) {
      state.microBreakIntervalMinMinutes.value = intValue;
    }
  }

  /// 更新微休息间隔最大值
  void updateMicroBreakIntervalMax(String value) {
    final intValue = int.tryParse(value);
    if (intValue != null) {
      state.microBreakIntervalMaxMinutes.value = intValue;
    }
  }

  /// 切换计时方向
  void toggleCountingDirection(bool value) {
    state.isCountingUp.value = value;
  }

  /// 切换进度条方向
  void toggleProgressDirection(bool value) {
    state.isProgressForward.value = value;
  }

  /// 切换微休息启用状态
  void toggleMicroBreakEnabled(bool value) {
    state.microBreakEnabled.value = value;
    Get.log("当前microBreakEnabled: ${state.microBreakEnabled.value}");
  }

  /// 切换自动开始下一个专注状态
  void toggleAutoStartNextFocus(bool value) {
    state.autoStartNextFocus.value = value;
  }

  /// 执行数据备份
  Future<void> performBackup() async {
    if (state.isBackupInProgress.value) return;
    BackupRestoreDBService backupRestoreDBService = Get.isRegistered<BackupRestoreDBService>()
        ? Get.find<BackupRestoreDBService>()
        : Get.put(BackupRestoreDBService());

    state.isBackupInProgress.value = true;

    try {
      final backupPath = await backupRestoreDBService.backupData();

      if (backupPath != null) {
        Get.snackbar(
          '备份成功',
          '数据已备份到: $backupPath',
          snackPosition: SnackPosition.TOP,
          barBlur: 100.0,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          '备份失败',
          '无法创建备份文件, 请检查存储权限',
          snackPosition: SnackPosition.TOP,
          barBlur: 100.0,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.log('备份过程中发生错误: $e');
      Get.snackbar(
        '备份失败',
        '备份过程中发生错误: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        barBlur: 100.0,
        duration: const Duration(seconds: 3),
      );
    } finally {
      state.isBackupInProgress.value = false;
    }
  }

  /// 执行数据恢复
  Future<void> performRestore() async {
    if (state.isRestoreInProgress.value) return;

    // 先显示确认对话框
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认恢复'),
        content: const Text('此操作将覆盖当前的所有数据, 确定要继续吗?'),
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

    if (confirmed != true) return;

    state.isRestoreInProgress.value = true;

    try {
      BackupRestoreDBService backupRestoreDBService = Get.isRegistered<BackupRestoreDBService>()
          ? Get.find<BackupRestoreDBService>()
          : Get.put(BackupRestoreDBService());
      final success = await backupRestoreDBService.restoreData();

      if (success) {
        Get.snackbar(
          '恢复成功',
          '数据已成功恢复, 请重启应用以生效',
          snackPosition: SnackPosition.TOP,
          barBlur: 100.0,
          duration: const Duration(seconds: 3),
        );

        // 重新加载设置
        _loadSettings();

        // 通知 HomeController 重新加载设置
        try {
          final homeController = Get.find<HomeController>();
          homeController.reloadSettings();
        } catch (e) {
          // HomeController 可能还没有初始化, 忽略错误
        }
      } else {
        Get.snackbar(
          '恢复失败',
          '无法恢复数据, 请检查备份文件是否有效',
          snackPosition: SnackPosition.TOP,
          barBlur: 100.0,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.log('恢复过程中发生错误: $e');
      Get.snackbar(
        '恢复失败',
        '恢复过程中发生错误: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        barBlur: 100.0,
        duration: const Duration(seconds: 3),
      );
    } finally {
      state.isRestoreInProgress.value = false;
    }
  }
}
