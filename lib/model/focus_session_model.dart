/// 单个专注会话数据模型
class FocusSessionModel {
  final int? id; // 数据库自增id, 新建时为null
  final DateTime startTime;
  final DateTime endTime;
  final int focusDuration; // 专注时长（秒）
  final int actualDuration; // 实际时长（秒）- 保留字段但不用于统计
  final bool isCompleted; // 是否完成 - 保留字段兼容性, 但总是true
  final String timeOfDay; // 时段：morning, afternoon, evening, night

  const FocusSessionModel({
    this.id, // 可选, 新建时为null, 数据库会自动分配
    required this.startTime,
    required this.endTime,
    required this.focusDuration,
    required this.actualDuration,
    this.isCompleted = true, // 默认为true, 因为只记录完成的会话
    required this.timeOfDay,
  });

  /// 从数据库Map创建FocusSession
  factory FocusSessionModel.fromMap(Map<String, dynamic> map) {
    return FocusSessionModel(
      id: map['id'] as int?,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['end_time'] as int),
      focusDuration: map['focus_duration'] as int,
      actualDuration: map['actual_duration'] as int,
      isCompleted: (map['is_completed'] as int) == 1,
      timeOfDay: map['time_of_day'] as String,
    );
  }

  /// 转换为数据库Map（不包含id, 让数据库自动生成）
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime.millisecondsSinceEpoch,
      'focus_duration': focusDuration,
      'actual_duration': actualDuration,
      'is_completed': isCompleted ? 1 : 0,
      'time_of_day': timeOfDay,
    };

    // 如果id不为null（更新操作）, 则包含id
    // 理论上不存在更新的操作, 但还是保留吧
    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  /// 获取专注日期（不包含时间）
  DateTime get focusDate {
    return DateTime(startTime.year, startTime.month, startTime.day);
  }

  /// 获取专注时长（分钟）
  double get focusDurationMinutes {
    return focusDuration / 60.0;
  }

  /// 获取实际时长（分钟）- 保留但不用于统计
  double get actualDurationMinutes {
    return actualDuration / 60.0;
  }

  /// 判断时段
  static String getTimeOfDay(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour >= 6 && hour < 12) {
      return 'morning';
    } else if (hour >= 12 && hour < 18) {
      return 'afternoon';
    } else if (hour >= 18 && hour < 24) {
      return 'evening';
    } else {
      return 'night';
    }
  }

  @override
  String toString() {
    return 'FocusSession{id: $id, startTime: $startTime, duration: ${focusDurationMinutes}min, completed: $isCompleted}';
  }
}
