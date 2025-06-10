import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:time_machine/theme/theme_controller.dart';

import '../../config/app_config.dart';
import 'controller.dart';
import 'state.dart';
import 'widgets/circular_progress_widget.dart';
import 'widgets/timer_display_widget.dart';
import 'widgets/control_buttons_widget.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final controller = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(HomeController());
  final state = Get.find<HomeController>().state;
  final themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    // 构建周期计数器
    Widget buildCycleCounter() {
      final theme = Theme.of(context);

      return Obx(() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.completedCycles.value > 0) ...[
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.surfaceTint,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              '已完成 ${state.completedCycles.value} 个时钟',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ));
    }

    // 构建计时器主要区域
    Widget buildTimerSection() {
      return Obx(() {
        final theme = Theme.of(context);

        // 根据状态选择进度条颜色 - 使用 Material 3 颜色
        Color progressColor;
        switch (state.timerStatus.value) {
          case TimerStatus.focus:
            progressColor = theme.colorScheme.primary;
            break;
          case TimerStatus.microBreak:
            progressColor = theme.colorScheme.onPrimaryFixedVariant;
            break;
          case TimerStatus.bigBreak:
            progressColor = theme.colorScheme.tertiary;
            break;
          case TimerStatus.paused:
            progressColor = theme.colorScheme.outline;
            break;
          default:
            progressColor = theme.colorScheme.primary;
        }

        return CircularProgressWidget(
          progress: state.progress,
          size: 280,
          strokeWidth: 18,
          progressColor: progressColor,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: TimerDisplayWidget(
            timeText: state.formattedTime,
            statusText: state.statusText,
            timeStyle: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w400,
              color: theme.colorScheme.onSurface,
              fontFeatures: const [
                FontFeature.tabularFigures(),
              ],
            ),
            statusStyle: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      });
    }

    // 构建控制按钮
    Widget buildControlButtons() {
      return Obx(() => ControlButtonsWidget(
        isRunning: state.isRunning.value,
        onPlayPause: controller.toggleTimer,
        onReset: controller.resetTimer,
        onSkip: AppConfig.isDebug ? controller.skipCurrentPhase : null,
      ));
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          '专注计时器',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(onPressed: themeController.switchLightOrDark,
              icon: const Icon(Icons.dark_mode_outlined)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // 周期统计
              buildCycleCounter(),

              const SizedBox(height: 40),

              // 主要计时器区域
              Expanded(
                child: Center(
                  child: buildTimerSection(),
                ),
              ),

              const SizedBox(height: 20),

              // 控制按钮
              buildControlButtons(),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
