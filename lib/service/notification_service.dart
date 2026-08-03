import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mmkv/mmkv.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/storage_keys.dart';
import 'app_storage_service.dart';

/// 计时事件提醒通知服务
///
/// 只负责"事件提醒"这一类通知(专注完成、休息结束等), 走独立的高优先级渠道.
/// 后台服务的前台常驻通知由 BackgroundTimerService 自己管理, 两者互不干扰:
/// - 常驻通知渠道 time_machine_timer: Importance.low, 静音, 不振动
/// - 事件提醒渠道 time_machine_events: Importance.high, 默认声音 + 振动
class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  late final MMKV _storage;

  /// 插件是否初始化成功, 失败时所有发送请求静默跳过
  bool _initialized = false;

  Future<NotificationService> init() async {
    _storage = Get.find<AppStorageService>().mmkv;

    try {
      // 复用 launcher 图标, 项目暂未提供专用的通知小图标
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );
      await _plugin.initialize(settings: settings);

      await _createEventsChannel();
      _initialized = true;
      Get.log('NotificationService initialized');
    } catch (e) {
      Get.log('NotificationService 初始化失败: $e');
    }

    return this;
  }

  /// 创建事件提醒渠道
  ///
  /// 渠道属性创建后不可由代码修改, 详见 StorageKeys.notificationChannelEvents 注释.
  /// 这里显式写出 playSound/enableVibration, 避免后续读代码时需要去查插件默认值.
  Future<void> _createEventsChannel() async {
    if (!Platform.isAndroid) return;

    const channel = AndroidNotificationChannel(
      StorageKeys.notificationChannelEvents,
      StorageKeys.notificationChannelEventsName,
      description: StorageKeys.notificationChannelEventsDesc,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// 读取某事件的通知开关
  bool isEventEnabled(String eventId) {
    return _storage.decodeBool(
      StorageKeys.notificationEnabledKey(eventId),
      defaultValue: StorageKeys.defaultNotificationEnabled,
    );
  }

  /// 写入某事件的通知开关
  void setEventEnabled(String eventId, bool enabled) {
    _storage.encodeBool(StorageKeys.notificationEnabledKey(eventId), enabled);
  }

  /// 发送计时事件提醒通知
  ///
  /// [eventId] 取自 StorageKeys.soundEventIds.
  /// 开关关闭、权限未授予或插件初始化失败时静默跳过, 不打扰计时主流程.
  Future<void> showEventNotification(String eventId) async {
    if (!_initialized || !Platform.isAndroid) return;
    if (!isEventEnabled(eventId)) return;

    // 用户可能在设置里开了开关但系统层面没给权限, 这里兜一层
    if (!await Permission.notification.isGranted) {
      Get.log('通知权限未授予, 跳过事件通知: $eventId');
      return;
    }

    final id = StorageKeys.notificationIds[eventId];
    if (id == null) {
      Get.log('未知的通知事件: $eventId');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      StorageKeys.notificationChannelEvents,
      StorageKeys.notificationChannelEventsName,
      channelDescription: StorageKeys.notificationChannelEventsDesc,
      importance: Importance.high,
      priority: Priority.high,
      // 点击后自动消失, 用户不需要手动清
      autoCancel: true,
    );

    try {
      await _plugin.show(
        id: id,
        title: StorageKeys.notificationTitles[eventId] ??
            StorageKeys.eventDisplayNames[eventId] ??
            'Time Machine',
        body: StorageKeys.notificationBodies[eventId],
        notificationDetails:
            const NotificationDetails(android: androidDetails),
      );
    } catch (e) {
      Get.log('发送事件通知失败($eventId): $e');
    }
  }
}
