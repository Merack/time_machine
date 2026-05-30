/// 存储键常量定义
class StorageKeys {
  // 私有构造函数, 防止实例化
  StorageKeys._();

  // 计时器设置相关
  static const String focusTimeMinutes = 'focus_time_minutes';
  static const String bigBreakTimeMinutes = 'big_break_time_minutes';
  static const String microBreakEnabled = 'micro_break_enabled';
  static const String microBreakTimeSeconds = 'micro_break_time_seconds';
  static const String microBreakIntervalMinMinutes = 'micro_break_interval_min_minutes';
  static const String microBreakIntervalMaxMinutes = 'micro_break_interval_max_minutes';
  
  // 行为控制设置
  static const String isCountingUp = 'is_counting_up'; // true=正向计时,false=逆向计时
  static const String isProgressForward = 'is_progress_forward'; // true=正向填充,false=逆向填充
  static const String autoStartNextFocus = 'auto_start_next_focus';

  // 计时器模式
  static const String timerMode = 'timer_mode'; // 'random_break' | 'pomodoro'

  // 番茄时钟设置
  static const String pomodoroFocusMinutes = 'pomodoro_focus_minutes';
  static const String pomodoroShortBreakMinutes = 'pomodoro_short_break_minutes';
  static const String pomodoroLongBreakMinutes = 'pomodoro_long_break_minutes';
  static const String pomodoroLongBreakInterval = 'pomodoro_long_break_interval';

  // 主题设置
  static const String themeMode = 'theme_mode'; // 主题模式：light, dark, system

  // 默认值
  static const String defaultTimerMode = 'random_break';
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
  static String soundDisplayNameKey(String eventId) => 'sound_${eventId}_display_name';

}
