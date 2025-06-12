import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

/// FocusSession数据库操作类
class FocusSessionDao {
  /// 插入专注会话
  static Future<int> insert(Map<String, dynamic> session) async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.insert(
        DatabaseHelper.tableFocusSessions,
        session,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      Get.log('插入专注会话成功: ${session[DatabaseHelper.columnId]}');
      return result;
    } catch (e) {
      Get.log('插入专注会话失败: $e');
      rethrow;
    }
  }

  /// 批量插入专注会话
  static Future<void> insertBatch(List<Map<String, dynamic>> sessions) async {
    if (sessions.isEmpty) return;

    try {
      final db = await DatabaseHelper.database;
      final batch = db.batch();

      for (final session in sessions) {
        batch.insert(
          DatabaseHelper.tableFocusSessions,
          session,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
      Get.log('批量插入专注会话成功: ${sessions.length} 条记录');
    } catch (e) {
      Get.log('批量插入专注会话失败: $e');
      rethrow;
    }
  }

  /// 查询所有专注会话
  static Future<List<Map<String, dynamic>>> queryAll() async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.query(
        DatabaseHelper.tableFocusSessions,
        orderBy: '${DatabaseHelper.columnStartTime} ASC',
      );
      Get.log('查询所有专注会话: ${result.length} 条记录');
      return result;
    } catch (e) {
      Get.log('查询所有专注会话失败: $e');
      return [];
    }
  }

  /// 按时间范围查询专注会话
  static Future<List<Map<String, dynamic>>> queryByDateRange(
      int startTime,
      int endTime,
      ) async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.query(
        DatabaseHelper.tableFocusSessions,
        where: '${DatabaseHelper.columnStartTime} >= ? AND ${DatabaseHelper.columnStartTime} < ?',
        whereArgs: [startTime, endTime],
        orderBy: '${DatabaseHelper.columnStartTime} ASC',
      );
      Get.log('按时间范围查询专注会话: ${result.length} 条记录');
      return result;
    } catch (e) {
      Get.log('按时间范围查询专注会话失败: $e');
      return [];
    }
  }

  /// 查询专注会话总数
  static Future<int> count() async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableFocusSessions}'
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      Get.log('专注会话总数: $count');
      return count;
    } catch (e) {
      Get.log('查询专注会话总数失败: $e');
      return 0;
    }
  }

  /// 删除所有专注会话
  static Future<int> deleteAll() async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.delete(DatabaseHelper.tableFocusSessions);
      Get.log('删除所有专注会话: $result 条记录');
      return result;
    } catch (e) {
      Get.log('删除所有专注会话失败: $e');
      return 0;
    }
  }

  /// 按ID删除专注会话
  /// 实际上用不到, 但还是保留吧
  static Future<int> deleteById(String id) async {
    try {
      final db = await DatabaseHelper.database;
      final result = await db.delete(
        DatabaseHelper.tableFocusSessions,
        where: '${DatabaseHelper.columnId} = ?',
        whereArgs: [id],
      );
      Get.log('删除专注会话: $id');
      return result;
    } catch (e) {
      Get.log('删除专注会话失败: $e');
      return 0;
    }
  }

  /// 获取基础统计数据
  static Future<Map<String, dynamic>> getBasicStatistics() async {
    try {
      final db = await DatabaseHelper.database;

      // 基础统计查询
      final basicStats = await db.rawQuery('''
        SELECT
          COUNT(*) as total_sessions,
          SUM(${DatabaseHelper.columnFocusDuration}) as total_focus_seconds,
          AVG(${DatabaseHelper.columnFocusDuration}) as avg_focus_seconds,
          MAX(${DatabaseHelper.columnFocusDuration}) as longest_session_seconds
        FROM ${DatabaseHelper.tableFocusSessions}
      ''');

      // 时段分布统计
      final timeOfDayStats = await db.rawQuery('''
        SELECT
          ${DatabaseHelper.columnTimeOfDay},
          COUNT(*) as count
        FROM ${DatabaseHelper.tableFocusSessions}
        GROUP BY ${DatabaseHelper.columnTimeOfDay}
      ''');

      // 周模式统计, 统计所有周1-7每天的专注数 (使用strftime获取星期几)
      // strftime和datetime是SQLite内置的时间处理函数
      // unixepoch 模式是以秒为单位的,因此 /1000 毫秒化秒
      final weeklyStats = await db.rawQuery('''
        SELECT
          CAST(strftime('%w', datetime(${DatabaseHelper.columnStartTime} / 1000, 'unixepoch')) AS INTEGER) as weekday,
          COUNT(*) as count
        FROM ${DatabaseHelper.tableFocusSessions}
        GROUP BY weekday
      ''');

      // 获取次数最多的那一天,并返回该日期和当天的次数
      final maxFocusCountDay = await db.rawQuery('''
        SELECT
          date(${DatabaseHelper.columnStartTime} / 1000, 'unixepoch') as date,
          COUNT(*) as sessions_count
        FROM ${DatabaseHelper.tableFocusSessions}
        GROUP BY date
        ORDER BY sessions_count DESC
        LIMIT 1
      ''');

      return {
        'basic': basicStats.isNotEmpty ? basicStats.first : {},
        'timeOfDay': timeOfDayStats,
        'weekly': weeklyStats,
        'maxDaily': maxFocusCountDay.isNotEmpty ? maxFocusCountDay.first : {},
      };
    } catch (e) {
      Get.log('获取基础统计数据失败: $e');
      return {
        'basic': {},
        'timeOfDay': <Map<String, dynamic>>[],
        'weekly': <Map<String, dynamic>>[],
        'maxDaily': {},
      };
    }
  }

  /// 获取时间范围内的统计数据
  static Future<Map<String, dynamic>> getTimeRangeStatistics(
      int startTime,
      int endTime,
      ) async {
    try {
      final db = await DatabaseHelper.database;

      final result = await db.rawQuery('''
        SELECT
          COUNT(*) as sessions,
          SUM(${DatabaseHelper.columnFocusDuration}) as total_seconds,
          AVG(${DatabaseHelper.columnFocusDuration}) as avg_seconds
        FROM ${DatabaseHelper.tableFocusSessions}
        WHERE ${DatabaseHelper.columnStartTime} >= ? AND ${DatabaseHelper.columnStartTime} < ?
      ''', [startTime, endTime]);

      return result.isNotEmpty ? result.first : {
        'sessions': 0,
        'total_seconds': 0,
        'avg_seconds': 0,
      };
    } catch (e) {
      Get.log('获取时间范围统计失败: $e');
      return {
        'sessions': 0,
        'total_seconds': 0,
        'avg_seconds': 0,
      };
    }
  }

  /// 获取最近N天的每日统计
  static Future<List<Map<String, dynamic>>> getRecentDailyStatistics(int days) async {
    try {
      final db = await DatabaseHelper.database;

      final result = await db.rawQuery('''
        SELECT
          date(${DatabaseHelper.columnStartTime} / 1000, 'unixepoch') as date,
          COUNT(*) as sessions,
          SUM(${DatabaseHelper.columnFocusDuration}) as total_seconds
        FROM ${DatabaseHelper.tableFocusSessions}
        WHERE ${DatabaseHelper.columnStartTime} >= ?
        GROUP BY date
        ORDER BY date ASC
      ''', [DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch]);

      return result;
    } catch (e) {
      Get.log('获取最近每日统计失败: $e');
      return [];
    }
  }

  /// 获取连续专注天数
  static Future<int> getConsecutiveDays() async {
    try {
      final db = await DatabaseHelper.database;

      // 获取所有有专注记录的日期
      final result = await db.rawQuery('''
        SELECT DISTINCT date(${DatabaseHelper.columnStartTime} / 1000, 'unixepoch') as focus_date
        FROM ${DatabaseHelper.tableFocusSessions}
        ORDER BY focus_date DESC
      ''');

      if (result.isEmpty) return 0;

      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      int consecutiveDays = 0;
      DateTime checkDate = today;

      // 如果今天没有专注记录，从昨天开始检查
      final focusDates = result.map((row) => row['focus_date'] as String).toSet();
      if (!focusDates.contains(todayStr)) {
        checkDate = today.subtract(const Duration(days: 1));
      }

      // 向前检查连续天数
      while (true) {
        final checkDateStr = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
        if (focusDates.contains(checkDateStr)) {
          consecutiveDays++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }

      return consecutiveDays;
    } catch (e) {
      Get.log('获取连续天数失败: $e');
      return 0;
    }
  }
}