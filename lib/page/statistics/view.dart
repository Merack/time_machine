import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';
import 'widgets/statistics_card.dart';
import 'widgets/simple_chart.dart';

class StatisticsPage extends StatelessWidget {
  StatisticsPage({Key? key}) : super(key: key);

  final StatisticsController controller = Get.put(StatisticsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('专注统计'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshStatistics,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage ?? '未知错误',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshStatistics,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        if (!controller.hasData) {
          return const Center(
            child: Text('暂无数据'),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshStatistics,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildBasicStatistics(context),
              const SizedBox(height: 16),
              _buildTimePeriodStatistics(context),
              const SizedBox(height: 16),
              _buildRecentTrend(context),
              const SizedBox(height: 16),
              _buildTimeDistribution(context),
              const SizedBox(height: 16),
              // 功能与_buildRecentTrend有点重复了
              // 即使他俩不完全相同
              // _buildWeeklyPattern(context),
            ],
          ),
        );
      }),
    );
  }

  /// 构建基础统计卡片
  Widget _buildBasicStatistics(BuildContext context) {
    final stats = controller.data?.basicStats;
    if (stats == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '基础统计',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            StatisticsCard(
              title: '总专注次数',
              value: '${stats.totalSessions}',
              icon: Icons.timer,
            ),
            StatisticsCard(
              title: '总专注时长',
              value: controller.formatHours(stats.totalHours),
              icon: Icons.schedule,
            ),
            StatisticsCard(
              title: '平均时长',
              value: controller.formatDuration(stats.averageSessionMinutes),
              icon: Icons.trending_up,
            ),
            StatisticsCard(
              title: '连续天数',
              value: '${stats.consecutiveDays}',
              // subtitle: '天',
              icon: Icons.local_fire_department,
              iconColor: stats.consecutiveDays > 7
                  ? Colors.orange
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  /// 构建时间维度统计
  Widget _buildTimePeriodStatistics(BuildContext context) {
    final data = controller.data;
    if (data == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '维度统计',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TimePeriodCard(
          title: '本周',
          sessions: '${data.thisWeek.sessions}次',
          hours: controller.formatHours(data.thisWeek.hours),
          avgSessionsPerDay: '${data.thisWeek.avgSessionsPerDay.toStringAsFixed(1)}次',
          avgTimePerDay: controller.formatHours(data.thisWeek.avgHoursPerDay),
          icon: Icons.view_week,
        ),
        const SizedBox(height: 8),
        TimePeriodCard(
          title: '本月',
          sessions: '${data.thisMonth.sessions}次',
          hours: controller.formatHours(data.thisMonth.hours),
          avgSessionsPerDay: '${data.thisMonth.avgSessionsPerDay.toStringAsFixed(1)}次',
          avgTimePerDay: controller.formatHours(data.thisMonth.avgHoursPerDay),
          icon: Icons.calendar_month,
        ),
        const SizedBox(height: 8),
        TimePeriodCard(
          title: '本年',
          sessions: '${data.thisYear.sessions}次',
          hours: controller.formatHours(data.thisYear.hours),
          avgSessionsPerDay: '${data.thisYear.avgSessionsPerDay.toStringAsFixed(1)}次',
          avgTimePerDay: controller.formatHours(data.thisYear.avgHoursPerDay),
          icon: Icons.calendar_today,
        ),
      ],
    );
  }

  /// 构建最近趋势
  Widget _buildRecentTrend(BuildContext context) {
    final recentStats = controller.data?.recentDays ?? [];

    if (recentStats.isEmpty) {
      return const SizedBox.shrink();
    }

    final chartData = recentStats.map((stat) {
      return ChartData(
        label: stat.dayOfWeek,
        value: stat.sessions.toDouble(),
        date: stat.date,
      );
    }).toList();

    return SimpleBarChart(
      data: chartData,
      title: '最近7天专注次数',
      height: 180,
    );
  }

  /// 构建时段分布
  Widget _buildTimeDistribution(BuildContext context) {
    final stats = controller.data?.basicStats;
    if (stats == null) return const SizedBox.shrink();

    final distribution = controller.getTimeOfDayPercentages(
      stats.timeOfDayDistribution,
    );

    return TimeOfDayDistribution(
      distribution: distribution,
      counts: stats.timeOfDayDistribution,
    );
  }

  /// 构建周模式 (暂时用不上)
  Widget _buildWeeklyPattern(BuildContext context) {
    final stats = controller.data?.basicStats;
    if (stats == null) return const SizedBox.shrink();

    final chartData = [
      ChartData(label: '周一', value: (stats.weeklyPattern[1] ?? 0).toDouble()),
      ChartData(label: '周二', value: (stats.weeklyPattern[2] ?? 0).toDouble()),
      ChartData(label: '周三', value: (stats.weeklyPattern[3] ?? 0).toDouble()),
      ChartData(label: '周四', value: (stats.weeklyPattern[4] ?? 0).toDouble()),
      ChartData(label: '周五', value: (stats.weeklyPattern[5] ?? 0).toDouble()),
      ChartData(label: '周六', value: (stats.weeklyPattern[6] ?? 0).toDouble()),
      ChartData(label: '周日', value: (stats.weeklyPattern[7] ?? 0).toDouble()),
    ];

    return SimpleBarChart(
      data: chartData,
      title: '周专注模式',
      height: 180,
    );
  }
}
