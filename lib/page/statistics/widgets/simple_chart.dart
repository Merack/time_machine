import 'package:flutter/material.dart';

/// 简单的柱状图组件
class SimpleBarChart extends StatelessWidget {
  final List<ChartData> data;
  final String title;
  final double height;
  final Color? barColor;

  const SimpleBarChart({
    Key? key,
    required this.data,
    required this.title,
    this.height = 200,
    this.barColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = barColor ?? theme.colorScheme.primary;
    
    if (data.isEmpty) {
      return _buildEmptyChart(context);
    }

    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    
    return Card(
      elevation: 1,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.map((item) {
                  final normalizedHeight = maxValue > 0 
                      ? (item.value / maxValue) * (height - 40)
                      : 0.0;
                  
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // 数值标签
                          if (item.value > 0)
                            Text(
                              item.value.toStringAsFixed(item.value % 1 == 0 ? 0 : 1),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          const SizedBox(height: 4),
                          // 柱子
                          Container(
                            height: normalizedHeight < 4 && item.value > 0 ? 4 : normalizedHeight,
                            decoration: BoxDecoration(
                              color: item.value > 0 
                                  ? primaryColor 
                                  : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 标签
                          Text(
                            item.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 1,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              height: height,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '暂无数据',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 简单的环形进度图
class SimpleProgressRing extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final String centerText;
  final String? subtitle;
  final double size;
  final Color? progressColor;

  const SimpleProgressRing({
    Key? key,
    required this.progress,
    required this.centerText,
    this.subtitle,
    this.size = 120,
    this.progressColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = progressColor ?? theme.colorScheme.primary;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // 背景圆环
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          // 进度圆环
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 8,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          // 中心文字
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  centerText,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 图表数据模型
class ChartData {
  final String label;
  final double value;
  final DateTime? date;

  const ChartData({
    required this.label,
    required this.value,
    this.date,
  });
}

/// 时段分布饼图（使用简单的条形表示）
class TimeOfDayDistribution extends StatelessWidget {
  final Map<String, double> distribution; // 百分比
  final Map<String, int> counts; // 原始数量

  const TimeOfDayDistribution({
    Key? key,
    required this.distribution,
    required this.counts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final timeSlots = [
      {'key': 'morning', 'label': '上午', 'icon': Icons.wb_sunny},
      {'key': 'afternoon', 'label': '下午', 'icon': Icons.wb_sunny_outlined},
      {'key': 'evening', 'label': '晚上', 'icon': Icons.nights_stay_outlined},
      {'key': 'night', 'label': '深夜', 'icon': Icons.bedtime},
    ];

    return Card(
      elevation: 1,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '专注时段分布',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...timeSlots.map((slot) {
              final key = slot['key'] as String;
              final label = slot['label'] as String;
              final icon = slot['icon'] as IconData;
              final percentage = distribution[key] ?? 0.0;
              final count = counts[key] ?? 0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text(
                        label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '$count次 (${percentage.toStringAsFixed(1)}%)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
