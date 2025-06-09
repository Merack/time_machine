import 'package:flutter/material.dart';

/// 倒计时显示组件
class TimerDisplayWidget extends StatelessWidget {
  final String timeText; // 时间文本 (MM:SS)
  final String statusText; // 状态文本
  final TextStyle? timeStyle; // 时间文本样式
  final TextStyle? statusStyle; // 状态文本样式

  const TimerDisplayWidget({
    super.key,
    required this.timeText,
    required this.statusText,
    this.timeStyle,
    this.statusStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 状态文本
        Text(
          statusText,
          style: statusStyle ??
              TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        // 时间显示
        Text(
          timeText,
          style: timeStyle ??
              const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                fontFeatures: [
                  FontFeature.tabularFigures(), // 使用等宽数字
                ],
              ),
        ),
      ],
    );
  }
}
