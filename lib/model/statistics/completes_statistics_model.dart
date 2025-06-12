
import 'package:time_machine/model/statistics/statistics_models.dart';

/// 完整的统计数据集合
class CompleteStatisticsModel {
  final StatisticsDataModel basicStats;
  final TimePeriodStatisticsModel today;
  final TimePeriodStatisticsModel thisWeek;
  final TimePeriodStatisticsModel thisMonth;
  final TimePeriodStatisticsModel thisYear;
  final List<DailyStatisticsModel> recentDays;

  const CompleteStatisticsModel({
    required this.basicStats,
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
    required this.thisYear,
    required this.recentDays,
  });

  static const CompleteStatisticsModel empty = CompleteStatisticsModel(
    basicStats: StatisticsDataModel.empty,
    today: TimePeriodStatisticsModel.empty,
    thisWeek: TimePeriodStatisticsModel.empty,
    thisMonth: TimePeriodStatisticsModel.empty,
    thisYear: TimePeriodStatisticsModel.empty,
    recentDays: [],
  );

  @override
  String toString() {
    return 'CompleteStatistics{totalSessions: ${basicStats.totalSessions}, recentDays: ${recentDays.length}}';
  }
}