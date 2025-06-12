/// 每日统计数据模型
class DailyStatisticsModel {
  final DateTime date;
  final int sessions;
  final double hours;
  final String dayOfWeek;
  final bool isToday;

  const DailyStatisticsModel({
    required this.date,
    required this.sessions,
    required this.hours,
    required this.dayOfWeek,
    required this.isToday,
  });

  factory DailyStatisticsModel.fromMap(Map<String, dynamic> map) {
    return DailyStatisticsModel(
      date: map['date'] as DateTime,
      sessions: (map['sessions'] as num?)?.toInt() ?? 0,
      hours: (map['hours'] as num?)?.toDouble() ?? 0.0,
      dayOfWeek: map['dayOfWeek'] as String? ?? '',
      isToday: map['isToday'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'sessions': sessions,
      'hours': hours,
      'dayOfWeek': dayOfWeek,
      'isToday': isToday,
    };
  }

  @override
  String toString() {
    return 'DailyStatistics{date: $date, sessions: $sessions, hours: $hours}';
  }
}