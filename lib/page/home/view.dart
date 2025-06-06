import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';
import 'state.dart';
import 'widgets/circular_progress_widget.dart';
import 'widgets/timer_display_widget.dart';
import 'widgets/control_buttons_widget.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeController controller = Get.put(HomeController());
  final HomeState state = Get.find<HomeController>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '专注计时器',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // 周期统计
              _buildCycleCounter(),

              const SizedBox(height: 40),

              // 主要计时器区域
              Expanded(
                child: Center(
                  child: _buildTimerSection(),
                ),
              ),

              const SizedBox(height: 40),

              // 控制按钮
              _buildControlButtons(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建周期计数器
  Widget _buildCycleCounter() {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green[600],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '已完成周期: ${state.completedCycles.value}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    ));
  }

  /// 构建计时器主要区域
  Widget _buildTimerSection() {
    return Obx(() {
      // 根据状态选择进度条颜色
      Color progressColor;
      switch (state.timerStatus.value) {
        case TimerStatus.focus:
          progressColor = const Color(0xFF007AFF);
          break;
        case TimerStatus.microBreak:
          progressColor = const Color(0xFFFF9500);
          break;
        case TimerStatus.bigBreak:
          progressColor = const Color(0xFF34C759);
          break;
        case TimerStatus.paused:
          progressColor = Colors.grey;
          break;
        default:
          progressColor = const Color(0xFF007AFF);
      }

      return CircularProgressWidget(
        progress: state.progress,
        size: 280,
        strokeWidth: 12,
        progressColor: progressColor,
        backgroundColor: Colors.grey[200]!,
        child: TimerDisplayWidget(
          timeText: state.formattedTime,
          statusText: state.statusText,
          timeStyle: const TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w200,
            color: Colors.black87,
            fontFeatures: [
              FontFeature.tabularFigures(),
            ],
          ),
          statusStyle: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    });
  }

  /// 构建控制按钮
  Widget _buildControlButtons() {
    return Obx(() => ControlButtonsWidget(
      isRunning: state.isRunning.value,
      onPlayPause: controller.toggleTimer,
      onReset: controller.resetTimer,
    ));
  }
}
