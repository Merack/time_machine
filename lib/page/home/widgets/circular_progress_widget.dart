import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 圆形进度条组件
class CircularProgressWidget extends StatelessWidget {
  final double progress; // 进度值 0.0 - 1.0
  final double size; // 组件大小
  final double strokeWidth; // 线条宽度
  final Color progressColor; // 进度条颜色
  final Color backgroundColor; // 背景颜色
  final Widget? child; // 中心显示的内容
  final VoidCallback? onTap; // 点击回调

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
    Widget progressWidget = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 背景圆环
          CustomPaint(
            size: Size(size, size),
            painter: _CircularProgressPainter(
              progress: 1.0,
              strokeWidth: strokeWidth,
              color: backgroundColor,
              isBackground: true,
            ),
          ),
          // 进度圆环
          CustomPaint(
            size: Size(size, size),
            painter: _CircularProgressPainter(
              progress: progress,
              strokeWidth: strokeWidth,
              color: progressColor,
              isBackground: false,
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
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final bool isBackground;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.isBackground,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = isBackground ? StrokeCap.butt : StrokeCap.round;

    if (isBackground) {
      // 绘制背景圆环
      canvas.drawCircle(center, radius, paint);
    } else {
      // 绘制进度圆弧
      const startAngle = -math.pi / 2; // 从顶部开始
      final sweepAngle = 2 * math.pi * progress;

      // 添加渐变效果
      if (progress > 0) {
        final gradient = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweepAngle,
          colors: [
            color.withAlpha((255 * 0.3).round()),
            color,
            color.withAlpha((255 * 0.8).round()),
          ],
          stops: const [0.0, 0.5, 1.0],
        );

        paint.shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: radius),
        );
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      // 绘制进度点（圆润效果）
      if (progress > 0 && progress < 1.0) {
        final endAngle = startAngle + sweepAngle;
        final endPoint = Offset(
          center.dx + radius * math.cos(endAngle),
          center.dy + radius * math.sin(endAngle),
        );

        final dotPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        canvas.drawCircle(endPoint, strokeWidth / 2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _CircularProgressPainter &&
        (oldDelegate.progress != progress ||
            oldDelegate.color != color ||
            oldDelegate.strokeWidth != strokeWidth);
  }
}
