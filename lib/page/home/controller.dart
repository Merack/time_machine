import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';

import 'state.dart';

class HomeController extends GetxController {
  final HomeState state = HomeState();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  Timer? _microBreakTimer;

  @override
  void onClose() {
    _timer?.cancel();
    _microBreakTimer?.cancel();
    _audioPlayer.dispose();
    super.onClose();
  }

  /// 开始/暂停计时器
  void toggleTimer() {
    if (state.isRunning.value) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  /// 重置计时器
  void resetTimer() {
    _timer?.cancel();
    _microBreakTimer?.cancel();

    state.timerStatus.value = TimerStatus.stopped;
    state.remainingTime.value = HomeState.focusTimeSeconds;
    state.totalTime.value = HomeState.focusTimeSeconds;
    state.isRunning.value = false;
    state.generateNextMicroBreakInterval();
  }

  /// 开始计时器
  void _startTimer() {
    if (state.timerStatus.value == TimerStatus.stopped) {
      // 首次启动，进入专注状态
      _startFocusSession();
    } else {
      // 从暂停状态恢复
      state.timerStatus.value = state.timerStatus.value == TimerStatus.paused
          ? TimerStatus.focus
          : state.timerStatus.value;
      state.isRunning.value = true;
      _startCountdown();
    }
  }

  /// 暂停计时器
  void _pauseTimer() {
    _timer?.cancel();
    _microBreakTimer?.cancel();
    state.timerStatus.value = TimerStatus.paused;
    state.isRunning.value = false;
  }

  /// 开始专注会话
  void _startFocusSession() {
    state.timerStatus.value = TimerStatus.focus;
    state.remainingTime.value = HomeState.focusTimeSeconds;
    state.totalTime.value = HomeState.focusTimeSeconds;
    state.isRunning.value = true;
    state.generateNextMicroBreakInterval();

    _startCountdown();
    _startMicroBreakCountdown();
  }

  /// 开始倒计时
  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingTime.value > 0) {
        state.remainingTime.value--;
      } else {
        _handleTimerComplete();
      }
    });
  }

  /// 开始微休息倒计时
  void _startMicroBreakCountdown() {
    if (state.timerStatus.value != TimerStatus.focus) return;

    _microBreakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timerStatus.value == TimerStatus.focus && state.isRunning.value) {
        if (state.nextMicroBreakTime.value > 0) {
          state.nextMicroBreakTime.value--;
        } else {
          _triggerMicroBreak();
        }
      }
    });
  }

  /// 触发微休息
  void _triggerMicroBreak() {
    _microBreakTimer?.cancel();
    _timer?.cancel();

    // 播放微休息开始音效
    _playAudio('lib/assets/audio/drop.mp3');

    // 进入微休息状态
    state.timerStatus.value = TimerStatus.microBreak;
    state.remainingTime.value = HomeState.microBreakTimeSeconds;
    state.totalTime.value = HomeState.microBreakTimeSeconds;

    // 开始微休息倒计时
    _startCountdown();
  }

  /// 处理计时器完成
  void _handleTimerComplete() {
    _timer?.cancel();

    switch (state.timerStatus.value) {
      case TimerStatus.focus:
        _completeFocusSession();
        break;
      case TimerStatus.microBreak:
        _completeMicroBreak();
        break;
      case TimerStatus.bigBreak:
        _completeBigBreak();
        break;
      default:
        break;
    }
  }

  /// 完成专注会话
  void _completeFocusSession() {
    _microBreakTimer?.cancel();

    // 播放专注完成音效
    _playAudio('lib/assets/audio/wakeup.mp3');

    // 增加完成周期数
    state.completedCycles.value++;

    // 进入大休息状态
    state.timerStatus.value = TimerStatus.bigBreak;
    state.remainingTime.value = HomeState.bigBreakTimeSeconds;
    state.totalTime.value = HomeState.bigBreakTimeSeconds;

    // 开始大休息倒计时
    _startCountdown();
  }

  /// 完成微休息
  void _completeMicroBreak() {
    // 播放微休息结束音效
    _playAudio('lib/assets/audio/ding.mp3');

    // 回到专注状态，恢复之前的剩余时间
    state.timerStatus.value = TimerStatus.focus;
    state.totalTime.value = HomeState.focusTimeSeconds;

    // 生成下一次微休息间隔
    state.generateNextMicroBreakInterval();

    // 继续专注倒计时和微休息倒计时
    _startCountdown();
    _startMicroBreakCountdown();
  }

  /// 完成大休息
  void _completeBigBreak() {
    // 播放大休息结束音效
    _playAudio('lib/assets/audio/alarm-wood.mp3');

    // 开始新的专注会话
    _startFocusSession();
  }

  /// 播放音频
  void _playAudio(String assetPath) async {
    try {
      await _audioPlayer.play(AssetSource(assetPath.replaceFirst('lib/assets/', '')));
    } catch (e) {
      print('播放音频失败: $e');
    }
  }
}
