import 'package:flutter/material.dart';

/// 控制按钮组件
class ControlButtonsWidget extends StatelessWidget {
  final bool isRunning; // 是否正在运行
  final VoidCallback onPlayPause; // 播放/暂停回调
  final VoidCallback onReset; // 重置回调
  final VoidCallback? onSkip; // 跳过回调（可选，仅在debug模式下显示）

  const ControlButtonsWidget({
    super.key,
    required this.isRunning,
    required this.onPlayPause,
    required this.onReset,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [
      // 播放/暂停按钮
      _CircularButton(
        onPressed: onPlayPause,
        icon: isRunning ? Icons.pause : Icons.play_arrow,
        backgroundColor: const Color(0xFF007AFF),
        iconColor: Colors.white,
        size: 64,
      ),
      // 重置按钮
      _CircularButton(
        onPressed: onReset,
        icon: Icons.refresh,
        backgroundColor: Colors.grey[300]!,
        iconColor: Colors.grey[700]!,
        size: 64,
      ),
    ];

    // 如果提供了跳过回调，添加跳过按钮
    if (onSkip != null) {
      buttons.add(
        _CircularButton(
          onPressed: onSkip!,
          icon: Icons.skip_next,
          backgroundColor: Colors.orange[300]!,
          iconColor: Colors.white,
          size: 64,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons,
    );
  }
}

/// 圆形按钮组件
class _CircularButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  const _CircularButton({
    required this.onPressed,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: size * 0.4,
          ),
        ),
      ),
    );
  }
}
