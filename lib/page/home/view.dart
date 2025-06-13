import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:time_machine/config/app_config.dart';
import 'package:time_machine/theme/theme_controller.dart';

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
    return Obx(() {
      final theme = Theme.of(context);
      final isZenMode = state.isZenMode.value;

      // 禅模式配色
      final backgroundColor = isZenMode ? Colors.black : theme.colorScheme.surface;
      final textColor = isZenMode ? Colors.white : theme.colorScheme.onSurface;
      final surfaceColor = isZenMode ? Colors.white.withValues(alpha: 0.1) : theme.colorScheme.surfaceContainerLow;

      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: PreferredSize(preferredSize: Size.fromHeight(kToolbarHeight),
            child: Obx(()=>Visibility(
              visible: !state.isZenMode.value,
              maintainState: true,
              maintainSize: true,
              maintainAnimation: true,
              child:  AppBar(
              title: const Text(
                AppConfig.APPNAME,
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
                IconButton(
                  onPressed: themeController.switchLightOrDark,
                  icon: const Icon(Icons.dark_mode_outlined),
                ),
              ],
            ),))),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // 周期统计
                _buildCycleCounter(context, isZenMode, textColor, surfaceColor),

                const SizedBox(height: 40),

                // 主要计时器区域
                Expanded(
                  child: Center(
                    child: _buildTimerSection(context, isZenMode, textColor),
                  ),
                ),

                const SizedBox(height: 20),

                // 控制按钮
                _buildControlButtons(isZenMode, textColor),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      );
    });
  }

  // 构建周期计数器
  Widget _buildCycleCounter(BuildContext context, bool isZenMode, Color textColor, Color surfaceColor) {
    final theme = Theme.of(context);

    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isZenMode ? surfaceColor : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isZenMode ? [] : [
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
              color: isZenMode ? Colors.white : theme.colorScheme.surfaceTint,
              size: 20,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            '已完成 ${state.completedCycles.value} 个时钟',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isZenMode ? Colors.white : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ));
  }

  // 构建计时器主要区域
  Widget _buildTimerSection(BuildContext context, bool isZenMode, Color textColor) {
    return Obx(() {
      final theme = Theme.of(context);

      // 根据状态选择进度条颜色
      Color progressColor;
      if (isZenMode) {
        // 禅模式下使用白色系配色
        switch (state.timerStatus.value) {
          case TimerStatus.focus:
            progressColor = Colors.white;
            break;
          case TimerStatus.microBreak:
            progressColor = Colors.white70;
            break;
          case TimerStatus.bigBreak:
            progressColor = Colors.white54;
            break;
          case TimerStatus.paused:
            progressColor = Colors.white38;
            break;
          default:
            progressColor = Colors.white;
        }
      } else {
        switch (state.timerStatus.value) {
          case TimerStatus.focus:
            progressColor = theme.colorScheme.primary;
            break;
          case TimerStatus.microBreak:
            progressColor = theme.colorScheme.secondary;
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
      }

      return CircularProgressWidget(
        progress: state.progress,
        size: 280,
        strokeWidth: 18,
        progressColor: progressColor,
        backgroundColor: isZenMode ? Colors.white.withValues(alpha: 0.2) : theme.colorScheme.surfaceContainerHighest,
        onTap: controller.toggleZenMode, // 添加点击事件
        child: TimerDisplayWidget(
          timeText: state.formattedTime,
          statusText: state.statusText,
          timeStyle: TextStyle(
            fontSize: 54,
            fontWeight: FontWeight.w400,
            color: isZenMode ? Colors.white : theme.colorScheme.onSurface,
            fontFeatures: const [
              FontFeature.tabularFigures(),
            ],
          ),
          statusStyle: TextStyle(
            fontSize: 16,
            color: isZenMode ? Colors.white : theme.colorScheme.outline,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    });
  }

  // 构建控制按钮
  Widget _buildControlButtons(bool isZenMode, Color textColor) {
    return Obx(() => ControlButtonsWidget(
      isRunning: state.isRunning.value,
      onPlayPause: controller.toggleTimer,
      onReset: controller.resetTimer,
      onSkip: Get.isLogEnable ? controller.skipCurrentPhase : null,
      isZenMode: isZenMode,
    ));
  }
}
