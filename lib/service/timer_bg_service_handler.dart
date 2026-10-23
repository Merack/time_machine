import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';

import '../page/home/state.dart';

class TimerBackgroundServiceHandler {
  final ServiceInstance _service;

  // 专注计时器
  Timer? _timer;
  // 微休息计时器
  Timer? _microBreakTimer;
  AudioPlayer? _backgroundRetentionPlayer;
  bool _backgroundRetentionEnabled = false;
  bool _backgroundRetentionMixWithOthers = true;
  bool _timerIsActive = false;
  bool? _activeMixWithOthers;
  Future<void> _backgroundRetentionUpdates = Future<void>.value();

  TimerBackgroundServiceHandler(this._service);

  void cancelAllTimers() {
    _timer?.cancel();
    _timer = null;
    _microBreakTimer?.cancel();
    _microBreakTimer = null;
  }

  // 开始专注和大休息计时
  void startFocusCountdown(int remainingFocusTime) {
    _timerIsActive = true;
    unawaited(_queueBackgroundRetentionUpdate());

    // 确保先取消现有计时器
    _timer?.cancel();
    _timer = null;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingFocusTime > 0) {
        remainingFocusTime--;
        _service.invoke("timer_update", {
          "remainingSeconds": remainingFocusTime,
        });
      } else {
        timer.cancel();
        _service.invoke("FocusTimerComplete");
      }
    });
  }

  // 微休息计时
  void startMicroBreakCountdown(
    int microBreakCountDownTime,
    TimerStatus timerStatus,
  ) {
    // 确保先取消现有计时器
    _microBreakTimer?.cancel();
    _microBreakTimer = null;

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

  Future<void> close() async {
    _timer?.cancel();
    _microBreakTimer?.cancel();
    _timerIsActive = false;
    await _queueBackgroundRetentionUpdate();
  }

  Future<void> _queueBackgroundRetentionUpdate() {
    final update = _backgroundRetentionUpdates.then(
      (_) => _updateBackgroundRetentionPlayback(),
    );
    _backgroundRetentionUpdates = update.catchError((Object error) {
      Get.log('更新静音后台播放状态失败: $error');
    });
    return _backgroundRetentionUpdates;
  }

  Future<void> _updateBackgroundRetentionPlayback() async {
    if (!Platform.isAndroid ||
        !_timerIsActive ||
        !_backgroundRetentionEnabled) {
      await _stopBackgroundRetentionPlayback();
      return;
    }

    final currentPlayer = _backgroundRetentionPlayer;
    if (currentPlayer != null &&
        currentPlayer.state == PlayerState.playing &&
        _activeMixWithOthers == _backgroundRetentionMixWithOthers) {
      return;
    }

    await _stopBackgroundRetentionPlayback();

    final player = AudioPlayer();
    _backgroundRetentionPlayer = player;
    _activeMixWithOthers = _backgroundRetentionMixWithOthers;

    try {
      await player.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            audioFocus: _backgroundRetentionMixWithOthers
                ? AndroidAudioFocus.none
                : AndroidAudioFocus.gain,
          ),
        ),
      );
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(0);
      await player.play(AssetSource('audio/silence.wav'));
    } catch (e) {
      Get.log('启动静音后台播放失败: $e');
      if (identical(_backgroundRetentionPlayer, player)) {
        _backgroundRetentionPlayer = null;
        _activeMixWithOthers = null;
      }
      try {
        await player.dispose();
      } catch (_) {}
    }
  }

  Future<void> _stopBackgroundRetentionPlayback() async {
    final player = _backgroundRetentionPlayer;
    _backgroundRetentionPlayer = null;
    _activeMixWithOthers = null;
    if (player == null) return;

    try {
      await player.stop();
    } catch (e) {
      Get.log('停止静音后台播放失败: $e');
    }
    try {
      await player.dispose();
    } catch (e) {
      Get.log('释放静音后台播放器失败: $e');
    }
  }

  Future<void> _setBackgroundRetentionConfig(
    Map<String, dynamic>? event,
  ) async {
    _backgroundRetentionEnabled = event?['enabled'] == true;
    _backgroundRetentionMixWithOthers = event?['mixWithOthers'] != false;
    await _queueBackgroundRetentionUpdate();
  }

  // 注册服务, 监听来自主isolate发过来的事件
  void _registerService() {
    // 停止微休息计时
    _service.on("stop_micro_break_timer").listen((event) {
      _microBreakTimer?.cancel();
    });

    // 停止专注计时和微休息计时
    _service.on("stop_timer").listen((event) {
      cancelAllTimers();
      _timerIsActive = false;
      unawaited(_queueBackgroundRetentionUpdate());
    });

    _service.on("set_background_retention_config").listen((event) {
      unawaited(_setBackgroundRetentionConfig(event));
    });

    // 开始专注计时器
    _service.on("start_focus_countdown").listen((event) {
      if (event != null &&
          (event.containsKey('backgroundRetentionEnabled') ||
              event.containsKey('backgroundRetentionMixWithOthers'))) {
        unawaited(
          _setBackgroundRetentionConfig({
            'enabled': event['backgroundRetentionEnabled'],
            'mixWithOthers': event['backgroundRetentionMixWithOthers'],
          }),
        );
      }
      startFocusCountdown(event?['remainingFocusTime'] ?? 5400);
    });

    // 开始微休息倒计时
    _service.on("start_micro_break_countdown").listen((event) {
      // 烦人的枚举类型转化
      String timerStatusString = event?['timerStatus'];
      TimerStatus timerStatus = TimerStatus.values.firstWhere(
        (e) => e.name == timerStatusString,
        orElse: () => TimerStatus.focus,
      );
      startMicroBreakCountdown(
        event?['microBreakCountDownTime'] ?? 180,
        timerStatus,
      );
    });

    // 停止服务
    _service.on("stop_service").listen((event) async {
      await close();
      await _service.stopSelf();
    });
  }
}
