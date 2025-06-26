import 'package:get/get.dart';
import 'package:time_machine/page/statistics/state.dart';
import '../../database/statistics_db_service.dart';
import '../../model/statistics/statistics_models.dart';

class StatisticsController extends GetxController {
  final Rx<StatisticsState> state = const StatisticsState.initial().obs;
  late final StatisticsDBService _statisticsService;

  @override
  void onInit() {
    super.onInit();
    _statisticsService = Get.put(StatisticsDBService());
    loadStatistics();
  }

  /// 加载统计数据
  Future<void> loadStatistics() async {
    try {

      state.value = const StatisticsState.loading();

      // 并行加载所有统计数据
      final results = await Future.wait([
        _statisticsService.calculateBasicStatistics(),
        _statisticsService.calculateTimePeriodStatistics(),
        _statisticsService.getRecentDailyStats(),
      ]);

      final basicStats = results[0] as StatisticsDataModel;
      final timePeriodStats = results[1] as Map<String, dynamic>;
      final recentDailyStatsRaw = results[2] as List<Map<String, dynamic>>;


      final completeStats = CompleteStatisticsModel(
        basicStats: basicStats,
        today: TimePeriodStatisticsModel.fromMap(timePeriodStats['today'] ?? {}),
        thisWeek: TimePeriodStatisticsModel.fromMap(timePeriodStats['thisWeek'] ?? {}),
        thisMonth: TimePeriodStatisticsModel.fromMap(timePeriodStats['thisMonth'] ?? {}),
        thisYear: TimePeriodStatisticsModel.fromMap(timePeriodStats['thisYear'] ?? {}),
        recentDays: recentDailyStatsRaw.map((data) => DailyStatisticsModel.fromMap(data)).toList(),
      );

      state.value = StatisticsState.loaded(completeStats);

    } catch (e) {
      state.value = StatisticsState.error('加载统计数据失败: $e');
      Get.log('加载统计数据失败: $e');
    }
  }

  /// 刷新统计数据
  Future<void> refreshStatistics() async {
    // 清除缓存以强制重新加载
    // _statisticsService.clearCache();
    await loadStatistics();
  }

  /// 格式化时长显示
  String formatDuration(double minutes) {
    if (minutes < 60) {
      return '${minutes.toStringAsFixed(0)}分钟';
    } else {
      final hours = minutes / 60;
      return '${hours.toStringAsFixed(1)}小时';
    }
  }

  /// 格式化小时显示
  String formatHours(double hours) {
    if (hours < 1) {
      return '${(hours * 60).toStringAsFixed(1)}分钟';
    } else {
      return '${hours.toStringAsFixed(1)}小时';
    }
  }

  /// 格式化百分比
  String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// 获取时段分布百分比
  Map<String, double> getTimeOfDayPercentages(Map<String, int> distribution) {
    return _statisticsService.getTimeOfDayPercentages(distribution);
  }

  // 便捷的getter方法
  bool get isLoading => state.value.isLoading;
  bool get hasData => state.value.hasData;
  bool get hasError => state.value.hasError;
  String? get errorMessage => state.value.errorMessage;
  CompleteStatisticsModel? get data => state.value.data;
}
