import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';

import '../page/home/state.dart';

class TimerBackgroundServiceHandler {
  final ServiceInstance _service;

  // 专注计时器
  Timer? _timer;
  // 微休息计时器
  Timer? _microBreakTimer;

  TimerBackgroundServiceHandler(this._service);

  // 开始专注和大休息计时
  void startFocusCountdown(int remainingFocusTime) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingFocusTime > 0) {
        remainingFocusTime--;
        _service.invoke("timer_update", {"remainingSeconds": remainingFocusTime});
      } else {
        timer.cancel();
        _service.invoke("FocusTimerComplete");
      }
    });
  }

  // 微休息计时
  void startMicroBreakCountdown(int microBreakCountDownTime, TimerStatus timerStatus) {
    _microBreakTimer?.cancel();
    // 处理微休息到来时间倒计时
    if (timerStatus == TimerStatus.focus) {
      _microBreakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (microBreakCountDownTime > 0) {
          microBreakCountDownTime--;
        } else {
          _microBreakTimer?.cancel();
          _service.invoke("microBreakStart");
        }
      });
    }
    // 处理微休息期间倒计时
    if (timerStatus == TimerStatus.microBreak) {
      _microBreakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (microBreakCountDownTime > 0) {
          microBreakCountDownTime--;
        } else {
          _microBreakTimer?.cancel();
          _service.invoke("microBreakComplete");
        }
      });
    }
  }

  void init() {
    _registerService();
  }

  void close() {
    _timer?.cancel();
    _microBreakTimer?.cancel();
  }

  // 注册服务, 监听来自主isolate发过来的事件
  void _registerService() {
    // 停止微休息计时
    _service.on("stop_micro_break_timer").listen((event) {
      _microBreakTimer?.cancel();
    });

    // 停止专注计时和微休息计时
    _service.on("stop_timer").listen((event) {
      _timer?.cancel();
      _microBreakTimer?.cancel();
    });

    // 开始专注计时器
    _service.on("start_focus_countdown").listen((event) {
      startFocusCountdown(event?['remainingFocusTime'] ?? 5400);
    });

    // 开始微休息倒计时
    _service.on("start_micro_break_countdown").listen((event) {
      // 烦人的枚举类型转化
      String timerStatusString = event?['timerStatus'];
      TimerStatus timerStatus = TimerStatus.values.firstWhere(
          (e) => e.name == timerStatusString,
          orElse: () => TimerStatus.focus
      );
      startMicroBreakCountdown(event?['microBreakCountDownTime'] ?? 180, timerStatus);
    });

    // 停止服务
    _service.on("stop_service").listen((event) {
      close();
      _service.stopSelf();
    });
  }
}