import 'dart:math';

import 'package:get/get.dart';
import 'package:time_machine/config/app_config.dart';

/// 计时器状态枚举
enum TimerStatus {
  focus,      // 专注状态
  microBreak, // 微休息状态
  bigBreak,   // 大休息状态
  paused,     // 暂停状态
  stopped     // 停止状态
}

class HomeState {
  // 上一个计时器状态
  var previousStatus = TimerStatus.stopped.obs;

  // 当前计时器状态
  var timerStatus = TimerStatus.stopped.obs;

  // 当前专注倒计时剩余时间（秒）
  var remainingFocusTime = 0.obs;

  // 当前微休息倒计时剩余时间（秒）
  var remainingMicroBreakTime = 0.obs;

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

  // 设置默认值
  var focusTimeSeconds = (90 * 60).obs; // 默认90分钟
  var bigBreakTimeSeconds = (20 * 60).obs; // 默认20分钟
  var microBreakTimeSeconds = 10.obs; // 默认10秒
  var minMicroBreakInterval = (3 * 60).obs; // 默认3分钟
  var maxMicroBreakInterval = (5 * 60).obs; // 默认5分钟

  // 行为控制设置
  var isCountingUp = false.obs; // 默认逆向计时
  var isProgressForward = true.obs; // 默认正向填充

  HomeState() {
    ///Initialize variables
    _resetToInitialState();
  }

  /// 重置到初始状态
  void _resetToInitialState() {
    timerStatus.value = TimerStatus.stopped;
    remainingFocusTime.value = focusTimeSeconds.value;
    totalTime.value = focusTimeSeconds.value;
    isRunning.value = false;
    remainingMicroBreakTime.value = microBreakTimeSeconds.value;
    generateNextMicroBreakInterval();
  }

  /// 生成下一次微休息的随机间隔时间
  void generateNextMicroBreakInterval() {
    if (AppConfig.isDebug) {
      nextMicroBreakTime.value = 5;
      return;
    }

    nextMicroBreakTime.value = minMicroBreakInterval.value +
        Random().nextInt(maxMicroBreakInterval.value - minMicroBreakInterval.value + 1);
  }

  /// 获取格式化的时间字符串 (MM:SS)
  String get formattedTime {
    int displayTime;
    if (isCountingUp.value) {
      // 正向计时：显示已经过的时间
      displayTime = totalTime.value - remainingFocusTime.value;
    } else {
      // 逆向计时：显示剩余时间
      displayTime = remainingFocusTime.value;
    }

    final minutes = displayTime ~/ 60;
    final seconds = displayTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 获取进度百分比 (0.0 - 1.0)
  double get progress {
    if (totalTime.value == 0) return 0.0;

    double baseProgress = (totalTime.value - remainingFocusTime.value) / totalTime.value;

    if (isProgressForward.value) {
      // 正向填充
      return baseProgress;
    } else {
      // 逆向填充
      return 1.0 - baseProgress;
    }
  }

  /// 获取当前状态的描述文本
  String get statusText {
    switch (timerStatus.value) {
      case TimerStatus.focus:
        return '专注时间';
      case TimerStatus.microBreak:
        return '微休息';
      case TimerStatus.bigBreak:
        return '休息';
      case TimerStatus.paused:
        return '已暂停';
      case TimerStatus.stopped:
        return '准备开始';
    }
  }
}
