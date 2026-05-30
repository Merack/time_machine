import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

/// 应用权限统一管理服务
///
/// 三类权限:
/// - 通知 (Permission.notification)
/// - 存储 (Android 13+ 走 manageExternalStorage,12 及以下走 storage)
/// - 电池优化白名单 (Permission.ignoreBatteryOptimizations)
class PermissionService extends GetxService {
  // 各权限当前状态(响应式)
  final Rx<PermissionStatus> notificationStatus = PermissionStatus.denied.obs;
  final Rx<PermissionStatus> storageStatus = PermissionStatus.denied.obs;
  final Rx<PermissionStatus> batteryStatus = PermissionStatus.denied.obs;

  int _androidSdkInt = 0;

  Future<PermissionService> init() async {
    if (Platform.isAndroid) {
      try {
        final info = await DeviceInfoPlugin().androidInfo;
        _androidSdkInt = info.version.sdkInt;
      } catch (e) {
        Get.log('读取 Android SDK 版本失败: $e');
      }
    }
    await refreshAll();
    return this;
  }

  /// 应用回前台时主动调用,刷新各权限状态
  Future<void> refreshAll() async {
    notificationStatus.value = await _resolveNotificationStatus();
    storageStatus.value = await _resolveStorageStatus();
    batteryStatus.value = await Permission.ignoreBatteryOptimizations.status;
  }

  Future<PermissionStatus> _resolveNotificationStatus() async {
    return Permission.notification.status;
  }

  Future<PermissionStatus> _resolveStorageStatus() async {
    if (Platform.isAndroid && _androidSdkInt >= 30) {
      // Android 11+ 用 MANAGE_EXTERNAL_STORAGE 才能写 Download 目录
      return Permission.manageExternalStorage.status;
    }
    return Permission.storage.status;
  }

  /// 请求通知权限
  Future<bool> requestNotification() async {
    final status = await Permission.notification.request();
    notificationStatus.value = status;
    return status.isGranted;
  }

  /// 请求存储权限(根据系统版本走不同分支)
  Future<bool> requestStorage() async {
    PermissionStatus status;
    if (Platform.isAndroid && _androidSdkInt >= 30) {
      status = await Permission.manageExternalStorage.request();
    } else {
      status = await Permission.storage.request();
    }
    storageStatus.value = status;
    return status.isGranted;
  }

  /// 请求电池优化白名单(实际是引导用户跳到系统对话框)
  Future<bool> requestBatteryWhitelist() async {
    final status = await Permission.ignoreBatteryOptimizations.request();
    batteryStatus.value = status;
    return status.isGranted;
  }

  /// 读取音频文件需要的权限(Android 13+ READ_MEDIA_AUDIO)
  Future<bool> requestAudioRead() async {
    if (!Platform.isAndroid) return true;
    if (_androidSdkInt >= 33) {
      final status = await Permission.audio.request();
      return status.isGranted;
    }
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  /// 状态文案
  String describeStatus(PermissionStatus status) {
    if (status.isGranted) return '已开启';
    if (status.isPermanentlyDenied) return '已拒绝, 请去系统设置';
    if (status.isRestricted) return '系统限制';
    return '未授权';
  }

  /// 跳转到应用设置页
  Future<void> openSettings() async {
    await openAppSettings();
  }
}
