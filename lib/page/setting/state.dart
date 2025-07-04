import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/storage_keys.dart';

class SettingState {
  // 大休息设置组
  var focusTimeMinutes = StorageKeys.defaultFocusTimeMinutes.obs;
  var bigBreakTimeMinutes = StorageKeys.defaultBigBreakTimeMinutes.obs;

  // 微休息设置组
  var microBreakEnabled = StorageKeys.defaultMicroBreakEnabled.obs;
  var microBreakTimeSeconds = StorageKeys.defaultMicroBreakTimeSeconds.obs;
  var microBreakIntervalMinMinutes = StorageKeys.defaultMicroBreakIntervalMinMinutes.obs;
  var microBreakIntervalMaxMinutes = StorageKeys.defaultMicroBreakIntervalMaxMinutes.obs;

  // 行为控制设置组
  var isCountingUp = StorageKeys.defaultIsCountingUp.obs;
  var isProgressForward = StorageKeys.defaultIsProgressForward.obs;
  // 自动开始下一个专注
  var autoStartNextFocus = StorageKeys.defaultAutoStartNextFocus.obs;

  // 备份恢复状态
  var isBackupInProgress = false.obs;
  var isRestoreInProgress = false.obs;

  // 表单控制器
  final focusTimeController = TextEditingController();
  final bigBreakTimeController = TextEditingController();
  final microBreakTimeController = TextEditingController();
  final microBreakIntervalMinController = TextEditingController();
  final microBreakIntervalMaxController = TextEditingController();

  // 错误信息
  var focusTimeError = ''.obs;
  var bigBreakTimeError = ''.obs;
  var microBreakTimeError = ''.obs;
  var microBreakIntervalMinError = ''.obs;
  var microBreakIntervalMaxError = ''.obs;

  SettingState() {
    ///Initialize variables
    _initializeControllers();
  }

  /// 初始化文本控制器
  void _initializeControllers() {
    focusTimeController.text = focusTimeMinutes.value.toString();
    bigBreakTimeController.text = bigBreakTimeMinutes.value.toString();
    microBreakTimeController.text = microBreakTimeSeconds.value.toString();
    microBreakIntervalMinController.text = microBreakIntervalMinMinutes.value.toString();
    microBreakIntervalMaxController.text = microBreakIntervalMaxMinutes.value.toString();
  }

  /// 更新控制器文本
  void updateControllers() {
    focusTimeController.text = focusTimeMinutes.value.toString();
    bigBreakTimeController.text = bigBreakTimeMinutes.value.toString();
    microBreakTimeController.text = microBreakTimeSeconds.value.toString();
    microBreakIntervalMinController.text = microBreakIntervalMinMinutes.value.toString();
    microBreakIntervalMaxController.text = microBreakIntervalMaxMinutes.value.toString();
  }

  /// 清除所有错误信息
  void clearErrors() {
    focusTimeError.value = '';
    bigBreakTimeError.value = '';
    microBreakTimeError.value = '';
    microBreakIntervalMinError.value = '';
    microBreakIntervalMaxError.value = '';
  }

  /// 验证所有输入
  bool validateAll() {
    clearErrors();
    bool isValid = true;

    // 验证专注时间
    if (focusTimeMinutes.value <= 0) {
      focusTimeError.value = '专注时间必须大于0分钟';
      isValid = false;
    }

    // 验证大休息时间
    if (bigBreakTimeMinutes.value < 0) {
      bigBreakTimeError.value = '长休息时间必须大于或等于0分钟';
      isValid = false;
    }

    // 验证微休息时长
    if (microBreakEnabled.value) {
      if (microBreakTimeSeconds.value < 0) {
        microBreakTimeError.value = '微休息时长必须大于或等于0秒';
        isValid = false;
      } else if (bigBreakTimeMinutes.value != 0
          && (microBreakTimeSeconds.value > bigBreakTimeMinutes.value * 60)) {
        microBreakTimeError.value = '微休息时长不能大于长休息时间';
        isValid = false;
      }

      // 验证微休息间隔范围
      if (microBreakIntervalMinMinutes.value < 0) {
        microBreakIntervalMinError.value = '最小间隔必须大于或等于0分钟';
        isValid = false;
      }

      if (microBreakIntervalMaxMinutes.value <= 0) {
        microBreakIntervalMaxError.value = '最大间隔必须大于0分钟';
        isValid = false;
      }

      if (microBreakIntervalMinMinutes.value > microBreakIntervalMaxMinutes.value) {
        microBreakIntervalMinMinutes.value = microBreakIntervalMaxMinutes.value;
        microBreakIntervalMinController.text = microBreakIntervalMinMinutes.value.toString();
        Get.snackbar(
          '设置已调整',
          '最小间隔不能大于最大间隔,已调整为相同值',
          snackPosition: SnackPosition.TOP,
          barBlur: 100,
          duration: Duration(seconds: 2),
        );
      }
    }
    
    return isValid;
  }

  void dispose() {
    focusTimeController.dispose();
    bigBreakTimeController.dispose();
    microBreakTimeController.dispose();
    microBreakIntervalMinController.dispose();
    microBreakIntervalMaxController.dispose();
  }
}
