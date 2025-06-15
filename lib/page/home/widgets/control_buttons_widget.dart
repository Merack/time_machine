import 'package:flutter/material.dart';

/// 控制按钮组件
class ControlButtonsWidget extends StatelessWidget {
  final bool isRunning; // 是否正在运行
  final VoidCallback onPlayPause; // 播放/暂停回调
  final VoidCallback onReset; // 重置回调
  final VoidCallback? onSkip; // 跳过回调（可选, 仅在debug模式下显示）
  final bool isZenMode; // 是否为禅模式

  const ControlButtonsWidget({
    super.key,
    required this.isRunning,
    required this.onPlayPause,
    required this.onReset,
    this.onSkip,
    this.isZenMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 禅模式配色
    final buttonBackgroundColor = isZenMode ? Colors.black : theme.colorScheme.primary;
    final buttonForegroundColor = isZenMode ? Colors.white70 : theme.colorScheme.onPrimary;
    final buttonElevation = isZenMode ? 0.0 : 3.0;

    List<Widget> buttons = [
      // 播放/暂停按钮 - 使用 FloatingActionButton
      FloatingActionButton(
        onPressed: onPlayPause,
        backgroundColor: buttonBackgroundColor,
        foregroundColor: buttonForegroundColor,
        elevation: buttonElevation,
        shape: CircleBorder(),
        child: Icon(
          isRunning ? Icons.pause : Icons.chevron_right,
          size: 28,
        ),
      ),

      // 重置按钮 - 使用 FilledButton.tonal
      FloatingActionButton(
        onPressed: onReset,
        backgroundColor: buttonBackgroundColor,
        foregroundColor: buttonForegroundColor,
        elevation: buttonElevation,
        shape: CircleBorder(),
        child: const Icon(
          Icons.refresh,
          size: 24,
        ),
      ),
    ];

    // 如果提供了跳过回调, 添加跳过按钮
    if (onSkip != null) {
      buttons.add(
        FilledButton(
          onPressed: onSkip!,
          style: FilledButton.styleFrom(
            backgroundColor: isZenMode ? Colors.black : theme.colorScheme.tertiary,
            foregroundColor: isZenMode ? Colors.white : theme.colorScheme.onTertiary,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            minimumSize: const Size(56, 56),
            elevation: buttonElevation,
          ),
          child: const Icon(
            Icons.skip_next,
            size: 24,
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons,
    );
  }
}
