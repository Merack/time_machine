import 'package:flutter/material.dart';

/// 控制按钮组件 - Material 3 优化版本
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
    final theme = Theme.of(context);

    List<Widget> buttons = [
      // 播放/暂停按钮 - 使用 FloatingActionButton
      FloatingActionButton(
        onPressed: onPlayPause,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 3,
        shape: CircleBorder(),
        child: Icon(
          isRunning ? Icons.pause : Icons.chevron_right,
          size: 28,
        ),
      ),

      // 重置按钮 - 使用 FilledButton.tonal
      FloatingActionButton(
        onPressed: onReset,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 3,
        shape: CircleBorder(),
        child: const Icon(
          Icons.refresh,
          size: 24,
        ),
      ),
    ];

    // 如果提供了跳过回调，添加跳过按钮
    if (onSkip != null) {
      buttons.add(
        FilledButton(
          onPressed: onSkip!,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.tertiary,
            foregroundColor: theme.colorScheme.onTertiary,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            minimumSize: const Size(56, 56),
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
