import 'dart:math';
import 'package:get/get.dart';
import 'package:time_machine/service/database_service.dart';
import '../../dao/focus_session_dao.dart';
import '../../model/focus_session_model.dart';

/// 测试数据生成服务（仅用于开发和演示）
class TestDataController extends GetxController {
  late final DatabaseService _databaseServicee;

  @override
  void onInit() {
    super.onInit();
    _databaseServicee = Get.find<DatabaseService>();
  }

  /// 生成测试数据
  Future<void> generateTestData() async {
    try {
      // 清除现有数据
      await _databaseServicee.resetDatabase();

      final random = Random();
      final now = DateTime.now();
      final allSessions = <FocusSessionModel>[];

      // 生成过去30天的测试数据
      for (int dayOffset = 30; dayOffset >= 0; dayOffset--) {
        final date = now.subtract(Duration(days: dayOffset));

        // 随机决定这一天是否有专注记录（80%概率）
        if (random.nextDouble() < 0.8) {
          // 每天1-5次专注会话
          final sessionsCount = 1 + random.nextInt(5);

          for (int i = 0; i < sessionsCount; i++) {
            final session = _generateRandomSession(date, random);
            allSessions.add(session);
          }
        }
      }

      // 批量保存所有会话
      if (allSessions.isNotEmpty) {
        await FocusSessionDao.insertBatch(allSessions.map((sessions) => sessions.toMap()).toList());
      }

      Get.log('测试数据生成完成: ${allSessions.length} 条记录');
    } catch (e) {
      Get.log('生成测试数据失败: $e');
    }
  }

  /// 生成单个随机会话
  FocusSessionModel _generateRandomSession(DateTime date, Random random) {
    // 随机选择时段
    final timeSlots = [
      {'start': 6, 'end': 12},   // 上午
      {'start': 14, 'end': 18},  // 下午
      {'start': 19, 'end': 22},  // 晚上
      {'start': 0, 'end': 6},  // 深夜
    ];
    
    final timeSlot = timeSlots[random.nextInt(timeSlots.length)];
    final startHour = timeSlot['start']! + random.nextInt(timeSlot['end']! - timeSlot['start']!);
    final startMinute = random.nextInt(60);
    
    final startTime = DateTime(
      date.year,
      date.month,
      date.day,
      startHour,
      startMinute,
    );
    
    // 随机专注时长（15-60分钟）
    final focusDurationMinutes = 15 + random.nextInt(46);
    final focusDuration = focusDurationMinutes * 60;

    // 只生成完成的会话, 实际时长接近设定时长
    final actualDuration = (focusDuration * (0.9 + random.nextDouble() * 0.2)).round(); // 90%-110%

    final endTime = startTime.add(Duration(seconds: actualDuration));

    final session = FocusSessionModel(
      // id为null, 让数据库自动生成
      startTime: startTime,
      endTime: endTime,
      focusDuration: focusDuration,
      actualDuration: actualDuration,
      isCompleted: true, // 只生成完成的会话
      timeOfDay: FocusSessionModel.getTimeOfDay(startTime),
    );

    return session;
  }

  /// 生成今日测试数据
  Future<void> generateTodayTestData() async {
    try {
      final random = Random();
      final today = DateTime.now();
      final todaySessions = <FocusSessionModel>[];

      // 生成2-4次今日专注记录
      final sessionsCount = 2 + random.nextInt(3);

      for (int i = 0; i < sessionsCount; i++) {
        final session = _generateRandomSession(today, random);
        todaySessions.add(session);
      }

      // 批量保存今日会话
      if (todaySessions.isNotEmpty) {
        await FocusSessionDao.insertBatch(todaySessions.map((session) {
          return session.toMap();
        }).toList());
      }

      Get.log('今日测试数据生成完成: ${todaySessions.length} 条记录');
    } catch (e) {
      Get.log('生成今日测试数据失败: $e');
    }
  }
}
