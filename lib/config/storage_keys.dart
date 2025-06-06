/// 存储键常量定义
class StorageKeys {
  // 私有构造函数，防止实例化
  StorageKeys._();

  // 计时器设置相关
  static const String focusTimeMinutes = 'focus_time_minutes';
  static const String bigBreakTimeMinutes = 'big_break_time_minutes';
  static const String microBreakTimeSeconds = 'micro_break_time_seconds';
  static const String microBreakIntervalMinMinutes = 'micro_break_interval_min_minutes';
  static const String microBreakIntervalMaxMinutes = 'micro_break_interval_max_minutes';
  
  // 行为控制设置
  static const String isCountingUp = 'is_counting_up'; // true=正向计时，false=逆向计时
  static const String isProgressForward = 'is_progress_forward'; // true=正向填充，false=逆向填充
  
  // 默认值
  static const int defaultFocusTimeMinutes = 90;
  static const int defaultBigBreakTimeMinutes = 20;
  static const int defaultMicroBreakTimeSeconds = 10;
  static const int defaultMicroBreakIntervalMinMinutes = 3;
  static const int defaultMicroBreakIntervalMaxMinutes = 5;
  static const bool defaultIsCountingUp = false; // 默认逆向计时
  static const bool defaultIsProgressForward = true; // 默认正向填充
}
