import 'package:get/get.dart';
import 'package:time_machine/model/statistics/statistics_models.dart';
import '../dao/focus_session_dao.dart';

/// 统计数据计算服务
class StatisticsDBService {
  // StatisticsDataModel? _statistics_data;

  // 缓存机制 (目前用不上, 不知道后面还有没用, 先注释留着吧)
  // StatisticsDataModel? _cachedBasicStats;
  // Map<String, dynamic>? _cachedTimePeriodStats;
  // List<Map<String, dynamic>>? _cachedRecentDailyStats;
  // DateTime? _lastCacheTime;

  // 缓存有效期（5分钟）
  // static const Duration _cacheValidDuration = Duration(minutes: 5);

  /// 检查缓存是否有效
  // bool get _isCacheValid {
  //   if (_lastCacheTime == null) return false;
  //   return DateTime.now().difference(_lastCacheTime!) < _cacheValidDuration;
  // }

  /// 清除缓存
  // void clearCache() {
  //   // _cachedTimePeriodStats = null;
  //   // _cachedRecentDailyStats = null;
  //   // _lastCacheTime = null;
  //   // Get.log('StatisticsService: 缓存已清除');
  // }

  /// 计算基础统计数据
  Future<StatisticsDataModel> calculateBasicStatistics() async {
    // 检查缓存
    // if (_isCacheValid && _cachedBasicStats != null) {
    //   Get.log('StatisticsService: 使用缓存的基础统计数据');
    //   return _cachedBasicStats!;
    // }

    try {
      // SQL聚合查询获取统计数据
      final statsResult = await FocusSessionDao.getBasicStatistics();
      // 基础数据
      final basicStats = statsResult['basic'] as Map<String, dynamic>;
      // 时间段分布
      final timeOfDayStats = statsResult['timeOfDay'] as List<Map<String, dynamic>>;
      final weeklyStats = statsResult['weekly'] as List<Map<String, dynamic>>;
      final maxDailyStats = statsResult['maxDaily'] as Map<String, dynamic>;

      // 如果没有数据, 返回空统计
      if (basicStats.isEmpty) {
        return StatisticsDataModel.empty;
      }

      // 解析基础统计数据
      final totalSessions = (basicStats['total_sessions'] as int?) ?? 0;
      final totalFocusSeconds = (basicStats['total_focus_seconds'] as int?) ?? 0;
      final avgFocusSeconds = (basicStats['avg_focus_seconds'] as double?) ?? 0.0;
      final longestSessionSeconds = (basicStats['longest_session_seconds'] as int?) ?? 0;

      final totalHours = totalFocusSeconds / 3600.0;
      final averageMinutes = avgFocusSeconds / 60.0;
      final longestSessionMinutes = (longestSessionSeconds / 60).round();

      // 获取连续天数
      final consecutiveDays = await FocusSessionDao.getConsecutiveDays();

      // 解析最高单日会话数
      final maxDailySessions = (maxDailyStats['sessions_count'] as int?) ?? 0;

      // 解析时段分布
      final timeOfDayDistribution = <String, int>{
        'morning': 0,
        'afternoon': 0,
        'evening': 0,
        'night': 0,
      };
      for (final stat in timeOfDayStats) {
        final timeOfDay = stat['time_of_day'] as String;
        final count = stat['count'] as int;
        timeOfDayDistribution[timeOfDay] = count;
      }

      // 解析周模式（SQLite的strftime('%w')返回0-6, 0是周日）
      final weeklyPattern = <int, int>{};
      for (int i = 1; i <= 7; i++) {
        weeklyPattern[i] = 0;
      }
      for (final stat in weeklyStats) {
        final sqliteWeekday = stat['weekday'] as int; // 0=周日, 1=周一, ..., 6=周六
        final count = stat['count'] as int;

        // 转换为Dart的weekday格式（1=周一, ..., 7=周日）
        final dartWeekday = sqliteWeekday == 0 ? 7 : sqliteWeekday;
        weeklyPattern[dartWeekday] = count;
      }

      final result = StatisticsDataModel(
        totalSessions: totalSessions,
        totalHours: totalHours,
        averageSessionMinutes: averageMinutes,
        consecutiveDays: consecutiveDays,
        longestSessionMinutes: longestSessionMinutes,
        maxDailySessions: maxDailySessions,
        timeOfDayDistribution: timeOfDayDistribution,
        weeklyPattern: weeklyPattern,
      );

      // 更新缓存
      // _statistics_data = result;
      // _lastCacheTime = DateTime.now();
      // Get.log('StatisticsService: 基础统计数据已缓存');

      return result;
    } catch (e) {
      Get.log('计算统计数据失败: $e');
      return StatisticsDataModel.empty;
    }
  }

  /// 计算时间维度统计
  Future<Map<String, dynamic>> calculateTimePeriodStatistics() async {
    try {
      final now = DateTime.now();

      // 计算各时间段的开始和结束时间
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);
      final weekEnd = weekStartDay.add(const Duration(days: 7));

      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 1);

      final yearStart = DateTime(now.year, 1, 1);
      final yearEnd = DateTime(now.year + 1, 1, 1);

      // 并行查询各时间段的统计数据
      final results = await Future.wait([
        FocusSessionDao.getTimeRangeStatistics(
          todayStart.millisecondsSinceEpoch,
          todayEnd.millisecondsSinceEpoch,
        ),
        FocusSessionDao.getTimeRangeStatistics(
          weekStartDay.millisecondsSinceEpoch,
          weekEnd.millisecondsSinceEpoch,
        ),
        FocusSessionDao.getTimeRangeStatistics(
          monthStart.millisecondsSinceEpoch,
          monthEnd.millisecondsSinceEpoch,
        ),
        FocusSessionDao.getTimeRangeStatistics(
          yearStart.millisecondsSinceEpoch,
          yearEnd.millisecondsSinceEpoch,
        ),
      ]);

      return {
        'today': _formatPeriodStats(results[0], 1),
        'thisWeek': _formatPeriodStats(results[1], now.weekday),
        'thisMonth': _formatPeriodStats(results[2], now.day),
        'thisYear': _formatPeriodStats(results[3], now.dayOfYear),
      };
    } catch (e) {
      Get.log('计算时间维度统计失败: $e');
      return {
        'today': {'sessions': 0, 'hours': 0.0, 'avgSessionsPerDay': 0.0, 'avgHoursPerDay': 0.0},
        'thisWeek': {'sessions': 0, 'hours': 0.0, 'avgSessionsPerDay': 0.0, 'avgHoursPerDay': 0.0},
        'thisMonth': {'sessions': 0, 'hours': 0.0, 'avgSessionsPerDay': 0.0, 'avgHoursPerDay': 0.0},
        'thisYear': {'sessions': 0, 'hours': 0.0, 'avgSessionsPerDay': 0.0, 'avgHoursPerDay': 0.0},
      };
    }
  }

  /// 格式化时期统计数据
  Map<String, dynamic> _formatPeriodStats(Map<String, dynamic> sqlResult, int days) {
    final sessions = (sqlResult['sessions'] as int?) ?? 0;
    final totalSeconds = (sqlResult['total_seconds'] as int?) ?? 0;
    final totalHours = totalSeconds / 3600.0;
    final avgSessionsPerDay = days > 0 ? sessions / days : 0.0;
    final avgHoursPerDay = days > 0 ? totalHours / days : 0.0;

    return {
      'sessions': sessions,
      'hours': totalHours,
      'avgSessionsPerDay': avgSessionsPerDay,
      'avgHoursPerDay': avgHoursPerDay,
    };
  }

  /// 获取最近7天的每日统计
  Future<List<Map<String, dynamic>>> getRecentDailyStats() async {
    try {
      // 查询获取最近7天的数据
      final sqlResults = await FocusSessionDao.getRecentDailyStatistics(7);

      // 创建日期到统计数据的映射
      final dateStatsMap = <String, Map<String, dynamic>>{};
      for (final result in sqlResults) {
        final dateStr = result['date'] as String;
        final sessions = result['sessions'] as int;
        final totalSeconds = result['total_seconds'] as int;

        dateStatsMap[dateStr] = {
          'sessions': sessions,
          'hours': totalSeconds / 3600.0,
        };
      }

      // 生成最近7天的完整统计（包括没有数据的日期）
      final now = DateTime.now();
      final stats = <Map<String, dynamic>>[];

      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        final dayStats = dateStatsMap[dateStr] ?? {'sessions': 0, 'hours': 0.0};

        stats.add({
          'date': startOfDay,
          'sessions': dayStats['sessions'],
          'hours': dayStats['hours'],
          'dayOfWeek': _getDayOfWeekName(startOfDay.weekday),
          'isToday': i == 0,
        });
      }

      return stats;
    } catch (e) {
      Get.log('获取最近每日统计失败: $e');
      return [];
    }
  }

  /// 获取星期几的中文名称
  String _getDayOfWeekName(int weekday) {
    switch (weekday) {
      case 1: return '周一';
      case 2: return '周二';
      case 3: return '周三';
      case 4: return '周四';
      case 5: return '周五';
      case 6: return '周六';
      case 7: return '周日';
      default: return '未知';
    }
  }

  /// 获取时段分布百分比
  Map<String, double> getTimeOfDayPercentages(Map<String, int> distribution) {
    final total = distribution.values.fold<int>(0, (sum, count) => sum + count);
    if (total == 0) {
      return {
        'morning': 0.0,
        'afternoon': 0.0,
        'evening': 0.0,
        'night': 0.0,
      };
    }

    return distribution.map((key, value) => MapEntry(key, (value / total) * 100));
  }

  /// 获取时段名称
  String getTimeOfDayName(String timeOfDay) {
    switch (timeOfDay) {
      case 'morning': return '上午';
      case 'afternoon': return '下午';
      case 'evening': return '晚上';
      case 'night': return '深夜';
      default: return '未知';
    }
  }
}

/// DateTime扩展
extension DateTimeExtension on DateTime {
  int get dayOfYear {
    final startOfYear = DateTime(year, 1, 1);
    return difference(startOfYear).inDays + 1;
  }
}
