import 'dart:async';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mmkv/mmkv.dart';

import '../../service/app_storage_service.dart';
import '../../config/storage_keys.dart';
import 'state.dart';

class HomeController extends GetxController {
  final HomeState state = HomeState();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  Timer? _microBreakTimer;
  late final MMKV _storage;

  @override
  void onInit() {
    super.onInit();
    _storage = Get.find<AppStorageService>().mmkv;
    _loadSettings();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _microBreakTimer?.cancel();
    _audioPlayer.dispose();
    super.onClose();
  }

  /// 从存储中加载设置
  void _loadSettings() {
    state.focusTimeSeconds.value = _storage.decodeInt(
      StorageKeys.focusTimeMinutes,
      defaultValue: StorageKeys.defaultFocusTimeMinutes,
    ) * 60; // 转换为秒

    state.bigBreakTimeSeconds.value = _storage.decodeInt(
      StorageKeys.bigBreakTimeMinutes,
      defaultValue: StorageKeys.defaultBigBreakTimeMinutes,
    ) * 60; // 转换为秒

    state.microBreakTimeSeconds.value = _storage.decodeInt(
      StorageKeys.microBreakTimeSeconds,
      defaultValue: StorageKeys.defaultMicroBreakTimeSeconds,
    );

    state.minMicroBreakInterval.value = _storage.decodeInt(
      StorageKeys.microBreakIntervalMinMinutes,
      defaultValue: StorageKeys.defaultMicroBreakIntervalMinMinutes,
    ) * 60; // 转换为秒

    state.maxMicroBreakInterval.value = _storage.decodeInt(
      StorageKeys.microBreakIntervalMaxMinutes,
      defaultValue: StorageKeys.defaultMicroBreakIntervalMaxMinutes,
    ) * 60; // 转换为秒

    // 是否正向计时
    state.isCountingUp.value = _storage.decodeBool(
      StorageKeys.isCountingUp,
      defaultValue: StorageKeys.defaultIsCountingUp,
    );

    // 是否正向填充进度条
    state.isProgressForward.value = _storage.decodeBool(
      StorageKeys.isProgressForward,
      defaultValue: StorageKeys.defaultIsProgressForward,
    );

    // 如果当前是停止状态, 更新初始时间
    if (state.timerStatus.value == TimerStatus.stopped) {
      state.remainingFocusTime.value = state.focusTimeSeconds.value;
      state.totalTime.value = state.focusTimeSeconds.value;
    }
  }

  /// 开始/暂停计时器
  void toggleTimer() {
    _playButtonSound();
    if (state.isRunning.value) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  /// 重置计时器
  void resetTimer() {
    _playButtonSound();
    _timer?.cancel();
    _microBreakTimer?.cancel();

    state.timerStatus.value = TimerStatus.stopped;
    state.remainingFocusTime.value = state.focusTimeSeconds.value;
    state.totalTime.value = state.focusTimeSeconds.value;
    state.isRunning.value = false;
    state.generateNextMicroBreakInterval();
  }

  /// 开始计时器
  void _startTimer() {
    if (state.timerStatus.value == TimerStatus.stopped) {
      // 首次启动,进入专注状态
      _startFocusSession();
    } else {
      // 从暂停状态恢复
      if (state.timerStatus.value == TimerStatus.paused) {
        // 更新 isRunning 状态
        state.isRunning.value = true;
        // 如果之前的状态是 focus 或者 microBreak, 则恢复为专注状态
        if ((state.previousStatus.value == TimerStatus.focus) ||
            (state.previousStatus.value == TimerStatus.microBreak)) {
          state.timerStatus.value = TimerStatus.focus;
        } else {
          // 恢复为之前的状态, 逻辑上这里应该只能是 bigBreak
          state.timerStatus.value = state.previousStatus.value;
        }
        // 重新开始专注计时器
        _startFocusCountdown();
        // 重新生成随机间隔
        state.generateNextMicroBreakInterval();
        // 重新开始微休息计时器
        _startMicroBreakCountdown();
      }
    }
  }

  /// 暂停计时器
  void _pauseTimer() {
    // 一同暂停专注和微休息
    _timer?.cancel();
    _microBreakTimer?.cancel();
    state.previousStatus.value = state.timerStatus.value;
    state.timerStatus.value = TimerStatus.paused;
    state.isRunning.value = false;
  }

  /// 开始专注会话
  void _startFocusSession() {
    state.timerStatus.value = TimerStatus.focus;
    state.remainingFocusTime.value = state.focusTimeSeconds.value;
    state.totalTime.value = state.focusTimeSeconds.value;
    state.isRunning.value = true;
    state.generateNextMicroBreakInterval();

    _startFocusCountdown();
    _startMicroBreakCountdown();
  }

  /// 开始倒计时
  void _startFocusCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingFocusTime.value > 0) {
        state.remainingFocusTime.value--;
      } else {
        _handleFocusTimerComplete();
      }
    });
  }

  /// 处理微休息到来时间和微休息期间倒计时
  void _startMicroBreakCountdown() {
    Get.log("当前状态: ${state.timerStatus.value}");
    // 处理微休息到来时间倒计时
    if (state.timerStatus.value == TimerStatus.focus) {
      Get.log("微休息倒计时开始");
      _microBreakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (state.nextMicroBreakTime.value > 0) {
          state.nextMicroBreakTime.value--;
          Get.log("距离微休息开始还有: ${state.nextMicroBreakTime.value}");
        } else {
          Get.log("休息时间1是: ${state.microBreakTimeSeconds.value}");
          _handleMicroBreakStatus(isStartMicroBreak: true);
        }
      });
    }
    // 处理微休息期间倒计时
    if (state.timerStatus.value == TimerStatus.microBreak) {
      Get.log("微休息期间");
      Get.log("休息时间是: ${state.remainingMicroBreakTime.value}");
      _microBreakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (state.remainingMicroBreakTime.value > 0) {
            Get.log("走到了if");
            state.remainingMicroBreakTime.value--;
            Get.log("微休息时间还剩有: ${state.remainingMicroBreakTime.value}");
          } else {
            Get.log("走到了else");
            _handleMicroBreakStatus(isStartMicroBreak: false);
          }
      });
    }
  }

  /// 处理微休息的开始和结束
  void _handleMicroBreakStatus({required bool isStartMicroBreak}) {
    Get.log("微休息开始");
    // 开始微休息
    if (isStartMicroBreak) {
      _microBreakTimer?.cancel();

      // 播放微休息开始音效
      _playAudio('audio/drop.mp3');

      // 进入微休息状态
      state.timerStatus.value = TimerStatus.microBreak;
      // state.remainingFocusTime.value = state.microBreakTimeSeconds.value;
      // state.totalTime.value = state.microBreakTimeSeconds.value;

      // 开始微休息倒计时
      // 设置微休息时间
      state.remainingMicroBreakTime.value = state.microBreakTimeSeconds.value;
      _startMicroBreakCountdown();
    } else {  // 微休息结束
      Get.log("微休息结束");
      _microBreakTimer?.cancel();

      // 播放微休息结束音效
      _playAudio('audio/ding.mp3');

      // 更新状态
      state.timerStatus.value = TimerStatus.focus;
      // state.remainingFocusTime.value = state.microBreakTimeSeconds.value;
      // state.totalTime.value = state.microBreakTimeSeconds.value;
      state.generateNextMicroBreakInterval();
      // 开始微休息倒计时
      _startMicroBreakCountdown();
    }

  }

  /// 处理计时器完成
  void _handleFocusTimerComplete() {
    _timer?.cancel();

    switch (state.timerStatus.value) {
      case TimerStatus.focus:
        _completeFocusSession();
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
    // 不在专注时段, 微休息停止计时
    _microBreakTimer?.cancel();

    // 播放专注完成音效
    _playAudio('audio/wakeup.mp3');

    // 增加完成周期数
    state.completedCycles.value++;

    // 进入大休息状态
    state.timerStatus.value = TimerStatus.bigBreak;
    state.remainingFocusTime.value = state.bigBreakTimeSeconds.value;
    state.totalTime.value = state.bigBreakTimeSeconds.value;

    // 开始大休息倒计时
    _startFocusCountdown();
  }

  /// 完成微休息(已废弃, 为供参考暂时保留注释)
  // void _completeMicroBreak() {
  //   // 播放微休息结束音效
  //   _playAudio('audio/ding.mp3');
  //
  //   // 回到专注状态，恢复之前的剩余时间
  //   state.timerStatus.value = TimerStatus.focus;
  //   state.totalTime.value = state.focusTimeSeconds.value;
  //
  //   // 生成下一次微休息间隔
  //   state.generateNextMicroBreakInterval();
  //
  //   // 继续专注倒计时和微休息倒计时
  //   _startFocusCountdown();
  //   _startMicroBreakCountdown();
  // }

  /// 完成大休息
  void _completeBigBreak() {
    // 播放大休息结束音效
    _playAudio('audio/alarm-wood.mp3');

    // 开始新的专注会话
    // _startFocusSession();
    // 重置计数器
    resetTimer();
  }

  /// 跳过当前阶段（仅在debug模式下可用）
  void skipCurrentPhase() {
    // 播放按钮音效
    _playAudio('audio/button.wav');

    // 立即结束当前阶段
    _timer?.cancel();
    _microBreakTimer?.cancel();

    switch (state.timerStatus.value) {
      case TimerStatus.focus:
        _completeFocusSession();
        break;
      case TimerStatus.microBreak:
        // _completeMicroBreak();
        _startFocusCountdown();
        _handleMicroBreakStatus(isStartMicroBreak: false);
        break;
      case TimerStatus.bigBreak:
        _completeBigBreak();
        break;
      default:
        break;
    }
  }

  /// 播放按钮音效
  void _playButtonSound() {
    _playAudio('audio/button.wav');
  }

  /// 播放音频
  void _playAudio(String assetPath) async {
    try {
      // 当新的播放请求来临时打断之前的播放
      // 目前还不可以处理按钮的快速点击, 仅是处理阶段结束音乐播放时按下按钮的情况
      if (_audioPlayer.state == PlayerState.playing) {
        _audioPlayer.stop();
      }
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      // 使用 Get.log 替代 print
      Get.log('播放音频失败: $e');
    }
  }

  /// 重新加载设置（当设置页面保存后调用）
  void reloadSettings() {
    _loadSettings();
  }
}
