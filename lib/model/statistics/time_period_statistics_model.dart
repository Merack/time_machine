/// 时间段统计数据模型
class TimePeriodStatisticsModel {
  final int sessions;
  final double hours;
  final double avgSessionsPerDay;
  final double avgHoursPerDay;

  const TimePeriodStatisticsModel({
    required this.sessions,
    required this.hours,
    required this.avgSessionsPerDay,
    required this.avgHoursPerDay,
  });

  factory TimePeriodStatisticsModel.fromMap(Map<String, dynamic> map) {
    return TimePeriodStatisticsModel(
      sessions: (map['sessions'] as num?)?.toInt() ?? 0,
      hours: (map['hours'] as num?)?.toDouble() ?? 0.0,
      avgSessionsPerDay: (map['avgSessionsPerDay'] as num?)?.toDouble() ?? 0.0,
      avgHoursPerDay: (map['avgHoursPerDay'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessions': sessions,
      'hours': hours,
      'avgSessionsPerDay': avgSessionsPerDay,
      'avgHoursPerDay': avgHoursPerDay,
    };
  }

  static const TimePeriodStatisticsModel empty = TimePeriodStatisticsModel(
    sessions: 0,
    hours: 0.0,
    avgSessionsPerDay: 0.0,
    avgHoursPerDay: 0.0,
  );

  @override
  String toString() {
    return 'TimePeriodStatistics{sessions: $sessions, hours: $hours, avgPerDay: $avgSessionsPerDay}';
  }
}