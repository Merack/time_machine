import 'package:get/get.dart';

/// 计时器状态枚举
enum TimerStatus {
  focus,      // 专注状态（90分钟）
  microBreak, // 微休息状态（10秒）
  bigBreak,   // 大休息状态（20分钟）
  paused,     // 暂停状态
  stopped     // 停止状态
}

class HomeState {
  // 当前计时器状态
  var timerStatus = TimerStatus.stopped.obs;

  // 当前倒计时剩余时间（秒）
  var remainingTime = 0.obs;

  // 当前阶段的总时间（秒）
  var totalTime = 0.obs;

  // 已完成的专注周期数量
  var completedCycles = 0.obs;

  // 是否正在运行
  var isRunning = false.obs;

  // 下一次微休息的倒计时（秒）
  var nextMicroBreakTime = 0.obs;

  // 微休息间隔时间（3-5分钟的随机值，单位：秒）
  var microBreakInterval = 0.obs;

  // 专注时间常量（90分钟 = 5400秒）
  static const int focusTimeSeconds = 90 * 60;

  // 微休息时间常量（10秒）
  static const int microBreakTimeSeconds = 10;

  // 大休息时间常量（20分钟 = 1200秒）
  static const int bigBreakTimeSeconds = 20 * 60;

  // 微休息间隔范围（3-5分钟）
  static const int minMicroBreakInterval = 3 * 60; // 3分钟
  static const int maxMicroBreakInterval = 5 * 60; // 5分钟

  HomeState() {
    ///Initialize variables
    _resetToInitialState();
  }

  /// 重置到初始状态
  void _resetToInitialState() {
    timerStatus.value = TimerStatus.stopped;
    remainingTime.value = focusTimeSeconds;
    totalTime.value = focusTimeSeconds;
    isRunning.value = false;
    generateNextMicroBreakInterval();
  }

  /// 生成下一次微休息的随机间隔时间
  void generateNextMicroBreakInterval() {
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    microBreakInterval.value = minMicroBreakInterval +
        (random % (maxMicroBreakInterval - minMicroBreakInterval));
    nextMicroBreakTime.value = microBreakInterval.value;
  }

  /// 获取格式化的时间字符串 (MM:SS)
  String get formattedTime {
    final minutes = remainingTime.value ~/ 60;
    final seconds = remainingTime.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 获取进度百分比 (0.0 - 1.0)
  double get progress {
    if (totalTime.value == 0) return 0.0;
    return (totalTime.value - remainingTime.value) / totalTime.value;
  }

  /// 获取当前状态的描述文本
  String get statusText {
    switch (timerStatus.value) {
      case TimerStatus.focus:
        return '专注时间';
      case TimerStatus.microBreak:
        return '微休息';
      case TimerStatus.bigBreak:
        return '大休息';
      case TimerStatus.paused:
        return '已暂停';
      case TimerStatus.stopped:
        return '准备开始';
    }
  }
}
