import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:time_machine/service/timer_bg_service_handler.dart';

/// 后台计时器服务管理器
class BackgroundTimerService extends GetxService {
  static const String notificationChannelId = 'time_machine_timer';
  static const int notificationId = 1048596;

  final FlutterBackgroundService _backgroundService = FlutterBackgroundService();

  // @override
  // Future<void> onInit() async {
  //   super.onInit();
  //   // 初始化后台服务
  //   await _initializeBackgroundService();
  //   _backgroundService.startService();
  //
  //   Get.log('BackgroundTimerService initialized');
  // }

  @override
  void onClose() {
    _backgroundService.invoke("stop_service");
    super.onClose();
  }

  Future<BackgroundTimerService> init() async {
    await _initializeBackgroundService();
    _backgroundService.startService();

    Get.log('BackgroundTimerService initialized');
    return this;
  }
  /// 初始化后台服务
  Future<void> _initializeBackgroundService() async {
    // 创建通知渠道
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      'Time Machine 计时器',
      description: '专注计时器后台运行中',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 配置后台服务
    await _backgroundService.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onBackgroundStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: notificationChannelId,
        initialNotificationTitle: 'Time Machine',
        initialNotificationContent: 'Time Machine 计时服务已启动',
        foregroundServiceNotificationId: notificationId,
        foregroundServiceTypes: [AndroidForegroundType.mediaPlayback],
      ),
      // ios 的暂时用不到, 随便配置下
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onBackgroundStart,
        onBackground: onIosBackground,
      ),
    );
  }
}

/// iOS后台处理
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

/// 后台服务入口点
@pragma('vm:entry-point')
void onBackgroundStart(ServiceInstance service) async {
  // 确保插件已注册
  DartPluginRegistrant.ensureInitialized();
  Get.log('后台服务启动...');

  final handler = TimerBackgroundServiceHandler(service);
  handler.init();

}

