/// 存储键常量定义
class StorageKeys {
  // 私有构造函数, 防止实例化
  StorageKeys._();

  // 计时器设置相关
  static const String focusTimeMinutes = 'focus_time_minutes';
  static const String bigBreakTimeMinutes = 'big_break_time_minutes';
  static const String microBreakEnabled = 'micro_break_enabled';
  static const String microBreakTimeSeconds = 'micro_break_time_seconds';
  static const String microBreakIntervalMinMinutes =
      'micro_break_interval_min_minutes';
  static const String microBreakIntervalMaxMinutes =
      'micro_break_interval_max_minutes';

  // 行为控制设置
  static const String isCountingUp = 'is_counting_up'; // true=正向计时,false=逆向计时
  static const String isProgressForward =
      'is_progress_forward'; // true=正向填充,false=逆向填充
  static const String autoStartNextFocus = 'auto_start_next_focus';

  // 计时器模式
  static const String timerMode = 'timer_mode'; // 'random_break' | 'pomodoro'

  // 番茄时钟设置
  static const String pomodoroFocusMinutes = 'pomodoro_focus_minutes';
  static const String pomodoroShortBreakMinutes =
      'pomodoro_short_break_minutes';
  static const String pomodoroLongBreakMinutes = 'pomodoro_long_break_minutes';
  static const String pomodoroLongBreakInterval =
      'pomodoro_long_break_interval';

  // 主题设置
  static const String themeMode = 'theme_mode'; // 主题模式：light, dark, system

  // 实验性功能
  static const String backgroundRetentionEnabled =
      'background_retention_enabled';
  static const String backgroundRetentionMixWithOthers =
      'background_retention_mix_with_others';

  // 默认值
  static const String defaultTimerMode = 'pomodoro';
  static const int defaultFocusTimeMinutes = 90;
  static const int defaultBigBreakTimeMinutes = 20;
  static const bool defaultMicroBreakEnabled = true; // 默认启用微休息
  static const int defaultMicroBreakTimeSeconds = 10;
  static const int defaultMicroBreakIntervalMinMinutes = 3;
  static const int defaultMicroBreakIntervalMaxMinutes = 5;
  static const bool defaultIsCountingUp = false; // 默认逆向计时
  static const bool defaultIsProgressForward = true; // 默认正向填充
  static const bool defaultAutoStartNextFocus = false;
  static const String defaultThemeMode = 'system'; // 默认跟随系统
  static const bool defaultBackgroundRetentionEnabled = false;
  static const bool defaultBackgroundRetentionMixWithOthers = true;

  // 番茄时钟默认值
  static const int defaultPomodoroFocusMinutes = 25;
  static const int defaultPomodoroShortBreakMinutes = 5;
  static const int defaultPomodoroLongBreakMinutes = 20;
  static const int defaultPomodoroLongBreakInterval = 4;

  // ===== 提示音事件 =====
  // eventId 列表
  static const String soundEventMicroBreakStart = 'microBreakStart';
  static const String soundEventMicroBreakComplete = 'microBreakComplete';
  static const String soundEventFocusComplete = 'focusComplete';
  static const String soundEventBreakComplete = 'breakComplete';

  static const List<String> soundEventIds = [
    soundEventMicroBreakStart,
    soundEventMicroBreakComplete,
    soundEventFocusComplete,
    soundEventBreakComplete,
  ];

  // 提示音类型常量
  static const String soundTypeBuiltin = 'builtin';
  static const String soundTypeSystem = 'system';
  static const String soundTypeCustom = 'custom';

  // 软件内置音效资源路径(供选择对话框使用)
  static const Map<String, String> builtinSounds = {
    'audio/drop.mp3': 'drop',
    'audio/ding.mp3': 'ding',
    'audio/wakeup.mp3': 'wakeup',
    'audio/alarm-bell.mp3': 'bell',
    'audio/alarm-kitchen.mp3': 'kitchen',
    'audio/alarm-wood.mp3': 'wood',
  };

  // 各事件默认 builtin 资源路径
  static const Map<String, String> defaultEventSounds = {
    soundEventMicroBreakStart: 'audio/drop.mp3',
    soundEventMicroBreakComplete: 'audio/ding.mp3',
    soundEventFocusComplete: 'audio/wakeup.mp3',
    soundEventBreakComplete: 'audio/alarm-wood.mp3',
  };

  // 事件展示名
  static const Map<String, String> eventDisplayNames = {
    soundEventMicroBreakStart: '微休息开始',
    soundEventMicroBreakComplete: '微休息结束',
    soundEventFocusComplete: '专注完成',
    soundEventBreakComplete: '大休息/长休息结束',
  };

  // 提示音 MMKV 键辅助方法
  static String soundTypeKey(String eventId) => 'sound_${eventId}_type';
  static String soundValueKey(String eventId) => 'sound_${eventId}_value';
  static String soundDisplayNameKey(String eventId) =>
      'sound_${eventId}_display_name';

  // ===== 事件提醒通知 =====
  // 复用上面的 soundEventIds 作为通知事件集合, 不另建一套事件体系.
  // 暂停/从暂停恢复不属于事件, 因此不会发通知.

  /// 事件提醒通知渠道 ID
  ///
  /// 注意: Android 通知渠道创建后其重要性/声音/振动均不可再由代码修改,
  /// 只能通过更换渠道 ID 或用户清除应用数据来重建. 改动这些属性前务必确认.
  static const String notificationChannelEvents = 'time_machine_events';
  static const String notificationChannelEventsName = 'Time Machine 计时提醒';
  static const String notificationChannelEventsDesc = '专注完成、休息结束等计时事件提醒';

  /// 各事件通知 ID(与前台常驻通知的 1048596 区分开)
  /// 每个事件固定一个 ID, 重复触发时替换自身旧通知而不是堆叠
  static const Map<String, int> notificationIds = {
    soundEventMicroBreakStart: 1048601,
    soundEventMicroBreakComplete: 1048602,
    soundEventFocusComplete: 1048603,
    soundEventBreakComplete: 1048604,
  };

  /// 通知标题(默认取 eventDisplayNames, 这里只放需要区别于展示名的)
  static const Map<String, String> notificationTitles = {
    soundEventMicroBreakStart: '微休息开始',
    soundEventMicroBreakComplete: '微休息结束',
    soundEventFocusComplete: '专注完成',
    soundEventBreakComplete: '休息结束',
  };

  /// 通知正文
  static const Map<String, String> notificationBodies = {
    soundEventMicroBreakStart: '抬头远眺, 放松一下眼睛',
    soundEventMicroBreakComplete: '微休息结束, 回到专注',
    soundEventFocusComplete: '本轮专注已完成, 休息一下吧',
    soundEventBreakComplete: '休息结束, 准备开始下一轮专注',
  };

  /// 事件通知开关默认值: 全部关闭, 由用户按需开启
  static const bool defaultNotificationEnabled = false;

  /// 事件通知开关 MMKV 键
  static String notificationEnabledKey(String eventId) =>
      'notify_${eventId}_enabled';
}
