/// 统计数据模型
class StatisticsDataModel {
  final int totalSessions; // 总专注次数
  final double totalHours; // 总专注时长
  final double averageSessionMinutes; // 平均专注时长
  final int consecutiveDays; // 连续专注天数
  final int longestSessionMinutes; // 最长专注时间
  final int maxDailySessions; // 每日最多专注次数
  final Map<String, int> timeOfDayDistribution; // 各个时间段专注次数
  final Map<int, int> weeklyPattern; // 1-7 (Monday-Sunday)

  const StatisticsDataModel({
    required this.totalSessions,
    required this.totalHours,
    required this.averageSessionMinutes,
    required this.consecutiveDays,
    required this.longestSessionMinutes,
    required this.maxDailySessions,
    required this.timeOfDayDistribution,
    required this.weeklyPattern,
  });

  /// 空数据
  static const StatisticsDataModel empty = StatisticsDataModel(
    totalSessions: 0,
    totalHours: 0.0,
    averageSessionMinutes: 0.0,
    consecutiveDays: 0,
    longestSessionMinutes: 0,
    maxDailySessions: 0,
    timeOfDayDistribution: {},
    weeklyPattern: {},
  );
}