import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 圆形进度条组件
///
/// 高性能的自定义圆形进度条，支持：
/// - 自定义进度值, 大小, 线条宽度和颜色
/// - 背景圆环显示
/// - 中心内容展示
/// - 点击回调
///
class CircularProgressWidget extends StatelessWidget {
  /// 进度值，范围 0.0 - 1.0
  final double progress;

  /// 组件大小（宽高相等）
  final double size;

  /// 线条宽度
  final double strokeWidth;

  /// 进度条颜色
  final Color progressColor;

  /// 背景圆环颜色
  final Color backgroundColor;

  /// 中心显示的内容
  final Widget? child;

  /// 点击回调
  final VoidCallback? onTap;

  const CircularProgressWidget({
    super.key,
    required this.progress,
    this.size = 200.0,
    this.strokeWidth = 8.0,
    this.progressColor = const Color(0xFF007AFF),
    this.backgroundColor = const Color(0xFFE5E5EA),
    this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 使用单个CustomPaint优化性能
    Widget progressWidget = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 合并背景进度条和变化的进度条绘制
          CustomPaint(
            size: Size(size, size),
            painter: _CircularProgressPainter(
              progress: progress,
              strokeWidth: strokeWidth,
              progressColor: progressColor,
              backgroundColor: backgroundColor,
            ),
          ),
          // 中心内容
          if (child != null) child!,
        ],
      ),
    );

    // 如果有点击回调, 包装在GestureDetector中
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: progressWidget,
      );
    }

    return progressWidget;
  }
}

/// 圆形进度条绘制器
///
/// 将背景圆环和进度圆弧合并到单个绘制器中, 提升性能
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  const _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 绘制背景圆环
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 绘制进度圆弧（仅当有进度时）
    if (progress > 0) {
      const startAngle = -math.pi / 2; // 从顶部开始
      final sweepAngle = 2 * math.pi * progress;

      final progressPaint = Paint()
        ..color = progressColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round; // 圆润端点

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
