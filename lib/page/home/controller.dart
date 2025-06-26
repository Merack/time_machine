import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mmkv/mmkv.dart';

import '../../dao/focus_session_dao.dart';
import '../../model/focus_session_model.dart';
import '../../service/app_storage_service.dart';
import '../../config/storage_keys.dart';
import 'state.dart';

class HomeController extends GetxController {
  final HomeState state = HomeState();
  final AudioPlayer _audioPlayer = AudioPlayer();
  // 计时放在后台isolate里, 这里用不上了, 留着参考
  // Timer? _timer;
  // Timer? _microBreakTimer;
  late final MMKV _storage;
  // late final BackgroundTimerService _backgroundTimerService;
  final FlutterBackgroundService _backgroundService = FlutterBackgroundService();

  // 当前专注会话记录
  DateTime? _currentSessionStartTime;

  @override
  void onInit() {
    super.onInit();
    _storage = Get.find<AppStorageService>().mmkv;
    // _backgroundTimerService = Get.find<BackgroundTimerService>();
    _loadSettings();
    _registerService();
  }

  @override
  void onClose() {
    // _timer?.cancel();
    // _microBreakTimer?.cancel();
    _audioPlayer.dispose();
    super.onClose();
  }

  // 注册对后台服务的isolate的事件的监听
  void _registerService() {
    // 不断更新主isolate这边的 remainingFocusTime
    _backgroundService.on("timer_update").listen((event) {
      state.remainingFocusTime.value = event?["remainingSeconds"] ?? 0;
    });
    // 微休息开始时间
    _backgroundService.on("microBreakStart").listen((event) {
      // 延迟一秒执行, 尝试解决微休息低概率出现时间不准确的问题
      // Future.delayed(Duration(seconds: 1), () => _handleMicroBreakStart());
      _handleMicroBreakStart();
    });
    // 微休息完成
    _backgroundService.on("microBreakComplete").listen((event) {
      _handleMicroBreakComplete();
    });
    // 专注计时事件完成(专注状态或者大休息状态完成, 到时候改个名或者分开写吧太容易产生歧义了)
    _backgroundService.on("FocusTimerComplete").listen((event) {
      _handleFocusTimerComplete();
    });
  }

  /// 从存储中加载设置
  void _loadSettings() {
    state.focusTimeSeconds.value =
        _storage.decodeInt(
          StorageKeys.focusTimeMinutes,
          defaultValue: StorageKeys.defaultFocusTimeMinutes,
        ) * 60; // 转换为秒

    state.bigBreakTimeSeconds.value =
        _storage.decodeInt(
          StorageKeys.bigBreakTimeMinutes,
          defaultValue: StorageKeys.defaultBigBreakTimeMinutes,
        ) * 60; // 转换为秒

    state.microBreakEnabled.value = _storage.decodeBool(
      StorageKeys.microBreakEnabled,
      defaultValue: StorageKeys.defaultMicroBreakEnabled,
    );

    state.microBreakTimeSeconds.value = _storage.decodeInt(
      StorageKeys.microBreakTimeSeconds,
      defaultValue: StorageKeys.defaultMicroBreakTimeSeconds,
    );

    state.minMicroBreakInterval.value =
        _storage.decodeInt(
          StorageKeys.microBreakIntervalMinMinutes,
          defaultValue: StorageKeys.defaultMicroBreakIntervalMinMinutes,
        ) * 60; // 转换为秒

    state.maxMicroBreakInterval.value =
        _storage.decodeInt(
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

    // 自动开始下一个专注
    state.autoStartNextFocus.value = _storage.decodeBool(
      StorageKeys.autoStartNextFocus,
      defaultValue: StorageKeys.defaultAutoStartNextFocus,
    );

    // 如果当前是停止状态, 更新初始时间
    if (state.timerStatus.value == TimerStatus.stopped) {
      state.remainingFocusTime.value = state.focusTimeSeconds.value;
      state.totalTime.value = state.focusTimeSeconds.value;
    }
  }

  /// 开始/暂停计时器
  void toggleTimer() {
    // _playButtonSound();
    if (state.isRunning.value) {
      _pauseTimer();
    } else {
      _playButtonSound();
      _startTimer();
    }
  }

  /// 重置计时器 (未保活版, 用不上了, 留着参考)
  // void resetTimer() {
  //   // _playButtonSound();
  //
  //   // 停止后台计时器服务
  //   // _backgroundTimerService.resetTimer();
  //
  //   // 清空当前会话信息（未完成的专注不记录）
  //   _currentSessionStartTime = null;
  //
  //   _timer?.cancel();
  //   _microBreakTimer?.cancel();
  //
  //   state.timerStatus.value = TimerStatus.stopped;
  //   state.remainingFocusTime.value = state.focusTimeSeconds.value;
  //   state.totalTime.value = state.focusTimeSeconds.value;
  //   state.isRunning.value = false;
  //   state.generateNextMicroBreakInterval();
  // }

  /// 重置计时器(new)
  void resetTimer() {
    // _playButtonSound();

    // 停止后台计时器
    _backgroundService.invoke('stop_timer');

    // 清空当前会话信息（未完成的专注不记录）
    _currentSessionStartTime = null;

    state.timerStatus.value = TimerStatus.stopped;
    state.remainingFocusTime.value = state.focusTimeSeconds.value;
    state.totalTime.value = state.focusTimeSeconds.value;
    state.isRunning.value = false;
    state.generateNextMicroBreakInterval();
  }

  /// 开始计时器 (未保活版, 用不上了, 留着参考)
  // void _startTimer() {
  //   if (state.timerStatus.value == TimerStatus.stopped) {
  //     // 首次启动,进入专注状态
  //     _startFocusSession();
  //   } else {
  //     // 从暂停状态恢复
  //     if (state.timerStatus.value == TimerStatus.paused) {
  //       // 更新 isRunning 状态
  //       state.isRunning.value = true;
  //       // 如果之前的状态是 focus 或者 microBreak, 则恢复为专注状态
  //       if ((state.previousStatus.value == TimerStatus.focus) ||
  //           (state.previousStatus.value == TimerStatus.microBreak)) {
  //         state.timerStatus.value = TimerStatus.focus;
  //       } else {
  //         // 恢复为之前的状态, 逻辑上这里应该只能是 bigBreak
  //         state.timerStatus.value = state.previousStatus.value;
  //       }
  //       // 重新开始专注计时器
  //       _startFocusCountdown();
  //       // 重新生成随机间隔
  //       state.generateNextMicroBreakInterval();
  //       // 重新开始微休息计时器
  //       _startMicroBreakCountdown();
  //     }
  //   }
  // }
  /// 开始计时器(new)
  Future<void> _startTimer() async {
    bool isBackgroundServiceRunning = await _backgroundService.isRunning();
    if (!isBackgroundServiceRunning) {
      await _backgroundService.startService();
      Get.log("===开始后台服务===");
    }
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
        _backgroundService.invoke('start_focus_countdown', {
          'remainingFocusTime': state.remainingFocusTime.value
        });
        // 重新生成随机间隔
        state.generateNextMicroBreakInterval();
        // 重新开始微休息计时器
        if (checkIsEnabledMicroBreak()) {
          _backgroundService.invoke('start_micro_break_countdown', {
            'microBreakCountDownTime': state.nextMicroBreakTime.value,
            'timerStatus': state.timerStatus.value.name
          });
        }
      }
    }
  }

  /// 暂停计时器 (未保活版, 用不上了, 留着参考)
  // void _pauseTimer() {
  //   // 一同暂停专注和微休息
  //   _timer?.cancel();
  //   _microBreakTimer?.cancel();
  //   state.previousStatus.value = state.timerStatus.value;
  //   state.timerStatus.value = TimerStatus.paused;
  //   state.isRunning.value = false;
  // }

  /// 暂停计时器 (new)
  void _pauseTimer() {
    // 一同暂停专注和微休息
    _backgroundService.invoke("stop_timer");
    state.previousStatus.value = state.timerStatus.value;
    state.timerStatus.value = TimerStatus.paused;
    state.isRunning.value = false;
  }

  /// 开始专注会话 (new, 直接写在旧版里了, 忘记开一个新版了, 不管了 -_-)
  void _startFocusSession() {
    state.timerStatus.value = TimerStatus.focus;
    state.remainingFocusTime.value = state.focusTimeSeconds.value;
    state.totalTime.value = state.focusTimeSeconds.value;
    state.isRunning.value = true;
    state.generateNextMicroBreakInterval();

    // 记录专注会话开始时间
    _currentSessionStartTime = DateTime.now();

    // 启用后台计时
    _backgroundService.invoke('start_focus_countdown', {
      'remainingFocusTime': state.remainingFocusTime.value
    });

    if (checkIsEnabledMicroBreak()) {
      // Get.log("启用微休息后台计时");
      _backgroundService.invoke('start_micro_break_countdown', {
        'microBreakCountDownTime': state.nextMicroBreakTime.value,
        // isolate 之间的传递数据竟然不支持枚举类型的序列化
        // 更变态的是你不支持就算了, 我传进去竟然也不报错. 这个bug找得我心态爆炸
        // isolate通信枚举类型不能直接传, 即使不报错(我也不知道为什么不报错)
        // 枚举类型处理: 传它的name属性或者index属性, 分别是String和int, 保证代码逻辑正常
        'timerStatus': state.timerStatus.value.name
      });
    }

    // 保留原有的前台计时器作为备用
    // _startFocusCountdown();
    // _startMicroBreakCountdown();
  }

  /// 开始倒计时(未保活版, 用不上, 留着参考)
  // void _startFocusCountdown() {
  //   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     if (state.remainingFocusTime.value > 0) {
  //       state.remainingFocusTime.value--;
  //     } else {
  //       _handleFocusTimerComplete();
  //     }
  //   });
  // }

  /// 检查是否启用微休息
  bool checkIsEnabledMicroBreak() {
    Get.log("检查是否启用微休息: ");
    if (!state.microBreakEnabled.value || state.microBreakTimeSeconds.value == 0) {
      Get.log("不启用微休息");
      return false;
    } else {
      Get.log("启用微休息");
      return true;
    }
  }

  /// 处理微休息到来时间和微休息期间倒计时 (未保活版, 用不上, 留着参考)
  // void _startMicroBreakCountdown() {
  //   // 检查微休息是否启用
  //   if (!state.microBreakEnabled.value) {
  //     return;
  //   }
  //
  //   // 不启用微休息的逻辑
  //   if (state.microBreakTimeSeconds.value == 0) {
  //     return;
  //   }
  //   // 处理微休息到来时间倒计时
  //   if (state.timerStatus.value == TimerStatus.focus) {
  //     _microBreakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //       if (state.nextMicroBreakTime.value > 0) {
  //         state.nextMicroBreakTime.value--;
  //         Get.log("距离微休息开始还有: ${state.nextMicroBreakTime.value}");
  //       } else {
  //         _handleMicroBreakStatus(isStartMicroBreak: true);
  //       }
  //     });
  //   }
  //   // 处理微休息期间倒计时
  //   if (state.timerStatus.value == TimerStatus.microBreak) {
  //     _microBreakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //       if (state.remainingMicroBreakTime.value > 0) {
  //         state.remainingMicroBreakTime.value--;
  //         Get.log("微休息时间还剩有: ${state.remainingMicroBreakTime.value}");
  //       } else {
  //         Get.log("微休息完成");
  //         _handleMicroBreakStatus(isStartMicroBreak: false);
  //       }
  //     });
  //   }
  // }

  /// 微休息开始处理函数
  void _handleMicroBreakStart() {
    Get.log("微休息开始");
      // 播放微休息开始音效
      _playAudio('audio/drop.mp3');

      // 进入微休息状态
      state.timerStatus.value = TimerStatus.microBreak;

      // 开始微休息倒计时
      // 设置微休息时间
      state.remainingMicroBreakTime.value = state.microBreakTimeSeconds.value;
      _backgroundService.invoke('start_micro_break_countdown', {
        'microBreakCountDownTime': state.remainingMicroBreakTime.value,
        'timerStatus': state.timerStatus.value.name
    });
  }

  /// 微休息完成处理函数
  void _handleMicroBreakComplete() {
    Get.log("微休息结束");

    // 播放微休息结束音效
    _playAudio('audio/ding.mp3');

    // 更新状态
    state.timerStatus.value = TimerStatus.focus;

    state.generateNextMicroBreakInterval();
    // 开始微休息倒计时
    _backgroundService.invoke('start_micro_break_countdown', {
      'microBreakCountDownTime': state.nextMicroBreakTime.value,
      'timerStatus': state.timerStatus.value.name
    });
  }

  /// 处理微休息的开始和结束 (未保活版, 用不上, 留着参考)
  // void _handleMicroBreakStatus({required bool isStartMicroBreak}) {
  //   Get.log("微休息开始");
  //   // 开始微休息
  //   if (isStartMicroBreak) {
  //     _microBreakTimer?.cancel();
  //
  //     // 播放微休息开始音效
  //     _playAudio('audio/drop.mp3');
  //
  //     // 进入微休息状态
  //     state.timerStatus.value = TimerStatus.microBreak;
  //
  //     // 开始微休息倒计时
  //     // 设置微休息时间
  //     state.remainingMicroBreakTime.value = state.microBreakTimeSeconds.value;
  //     _startMicroBreakCountdown();
  //   } else {
  //     // 微休息结束
  //     Get.log("微休息结束");
  //     _microBreakTimer?.cancel();
  //
  //     // 播放微休息结束音效
  //     _playAudio('audio/ding.mp3');
  //
  //     // 更新状态
  //     state.timerStatus.value = TimerStatus.focus;
  //
  //     state.generateNextMicroBreakInterval();
  //     // 开始微休息倒计时
  //     _startMicroBreakCountdown();
  //   }
  // }

  /// 处理计时器完成 (未保活版, 用不上了, 留着参考)
  // void _handleFocusTimerComplete() {
  //   _timer?.cancel();
  //
  //   switch (state.timerStatus.value) {
  //     case TimerStatus.focus:
  //       _completeFocusStatus();
  //       break;
  //     // 如果专注计时走完正好又处于微休息期间时, 仍然认为完成了专注任务
  //     case TimerStatus.microBreak:
  //       _completeFocusStatus();
  //       break;
  //     case TimerStatus.bigBreak:
  //       _completeBigBreak();
  //       break;
  //     default:
  //       break;
  //   }
  // }

  /// 处理计时器完成(new)
  void _handleFocusTimerComplete() {
    switch (state.timerStatus.value) {
      case TimerStatus.focus:
        _completeFocusStatus();
        break;
    // 如果专注计时走完正好又处于微休息期间时, 仍然认为完成了专注任务
      case TimerStatus.microBreak:
        _completeFocusStatus();
        break;
      case TimerStatus.bigBreak:
        _completeBigBreak();
        break;
      default:
        break;
    }
  }

  /// 完成专注状态倒计时 (未保活版, 用不上了, 留着参考)
  // void _completeFocusStatus() {
  //   // 不在专注时段, 微休息停止计时
  //   _microBreakTimer?.cancel();
  //
  //   // 记录专注会话完成
  //   _recordFocusSession();
  //
  //   // 播放专注完成音效
  //   _playAudio('audio/wakeup.mp3');
  //
  //   // 增加完成周期数
  //   state.completedCycles.value++;
  //
  //   // 如果用户设置大休息时间为0, 则跳过休息阶段
  //   if (state.bigBreakTimeSeconds.value == 0) {
  //     if (state.autoStartNextFocus.value) {
  //       // 直接开始下一轮专注
  //       resetTimer();
  //       _startFocusSession();
  //     } else {
  //       // 仅重置计时器, 保持停止状态
  //       resetTimer();
  //     }
  //     // 直接return 这个函数
  //     return;
  //   }
  //
  //   // 进入大休息状态
  //   state.timerStatus.value = TimerStatus.bigBreak;
  //   state.remainingFocusTime.value = state.bigBreakTimeSeconds.value;
  //   state.totalTime.value = state.bigBreakTimeSeconds.value;
  //
  //   // 开始大休息倒计时
  //   _startFocusCountdown();
  // }
  /// 完成专注状态倒计时(new)
  void _completeFocusStatus() {
    // 不在专注时段, 微休息停止计时
    _backgroundService.invoke('stop_micro_break_timer');

    // 记录专注会话完成
    _recordFocusSession();

    // 播放专注完成音效
    _playAudio('audio/wakeup.mp3');

    // 增加完成周期数
    state.completedCycles.value++;

    // 如果用户设置大休息时间为0, 则跳过休息阶段
    if (state.bigBreakTimeSeconds.value == 0) {
      _completeBigBreak();
      // 直接return 这个函数
      return;
    }

    // 进入大休息状态
    state.timerStatus.value = TimerStatus.bigBreak;
    state.remainingFocusTime.value = state.bigBreakTimeSeconds.value;
    state.totalTime.value = state.bigBreakTimeSeconds.value;

    // 开始大休息倒计时
    _backgroundService.invoke('start_focus_countdown', {
      'remainingFocusTime': state.remainingFocusTime.value
    });
  }

  /// 完成大休息
  void _completeBigBreak() {
    // 播放大休息结束音效
    if (state.bigBreakTimeSeconds.value != 0) {
      _playAudio('audio/alarm-wood.mp3');
    }

    if (state.autoStartNextFocus.value) {
      // 直接开始下一轮专注
      resetTimer();
      _startFocusSession();
    } else {
      // 仅重置计时器, 保持停止状态
      resetTimer();
    }
  }

  /// 跳过当前阶段（仅在debug模式下可用）(未保活版, 用不上了, 留着参考)
  // void skipCurrentPhase() {
  //   // 播放按钮音效
  //   _playAudio('audio/button.wav');
  //
  //   // 立即结束当前阶段
  //   _timer?.cancel();
  //   _microBreakTimer?.cancel();
  //
  //   switch (state.timerStatus.value) {
  //     case TimerStatus.focus:
  //       _completeFocusStatus();
  //       break;
  //     case TimerStatus.microBreak:
  //       // _completeMicroBreak();
  //       _startFocusCountdown();
  //       _handleMicroBreakStatus(isStartMicroBreak: false);
  //       break;
  //     case TimerStatus.bigBreak:
  //       _completeBigBreak();
  //       break;
  //     default:
  //       break;
  //   }
  // }
  /// 跳过当前阶段（仅在debug模式下可用）(new)
  void skipCurrentPhase() {
    // 播放按钮音效
    // _playAudio('audio/button.wav');

    // 立即结束当前阶段 (这个也忘记复制新版了)
    _backgroundService.invoke('stop_timer');

    switch (state.timerStatus.value) {
      case TimerStatus.focus:
        _completeFocusStatus();
        break;
      case TimerStatus.microBreak:
        _backgroundService.invoke('start_focus_countdown', {
          'remainingFocusTime': state.remainingFocusTime.value
        });
        _handleMicroBreakComplete();
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

  /// 切换禅模式
  void toggleZenMode() {
    state.isZenMode.value = !state.isZenMode.value;
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

  /// 记录专注会话（仅记录完成的会话）
  Future<void> _recordFocusSession() async {
    if (_currentSessionStartTime == null) {
      Get.log('专注会话开始时间为空, 无法记录');
      return;
    }

    try {
      final endTime = DateTime.now();
      final actualDuration = endTime.difference(_currentSessionStartTime!).inSeconds;

      final session = FocusSessionModel(
        // id为null, 让数据库自动生成
        startTime: _currentSessionStartTime!,
        endTime: endTime,
        focusDuration: state.focusTimeSeconds.value,
        actualDuration: actualDuration,
        isCompleted: true, // 只记录完成的会话,所以总是true, 为了兼容就留下这个字段了
        timeOfDay: FocusSessionModel.getTimeOfDay(_currentSessionStartTime!),
      );

      await FocusSessionDao.insert(session.toMap());
      Get.log('专注会话记录成功');

      // 清空当前会话信息
      _currentSessionStartTime = null;

    } catch (e) {
      Get.log('记录专注会话失败: $e');
    }
  }

  /// 重新加载设置（当设置页面保存后调用）
  void reloadSettings() {
    _loadSettings();
  }
}
