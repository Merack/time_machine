import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';

/// Setting数据库操作类
class SettingDao {
  /// 插入设置项
  static Future<int> insert(Database db, Map<String, dynamic> setting) async {
    try {
      // final db = await DatabaseHelper.database;
      final result = await db.insert(
        DatabaseHelper.tableSettings,
        setting,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      Get.log('插入设置项成功: ${setting['key']}');
      return result;
    } catch (e) {
      Get.log('插入设置项失败: $e');
      rethrow;
    }
  }

  /// 批量插入设置项
  static Future<void> insertBatch(Database db, List<Map<String, dynamic>> settings) async {
    if (settings.isEmpty) return;

    try {
      // final db = await DatabaseHelper.database;
      final batch = db.batch();

      for (final setting in settings) {
        batch.insert(
          DatabaseHelper.tableSettings,
          setting,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
      Get.log('批量插入设置项成功: ${settings.length} 条记录');
    } catch (e) {
      Get.log('批量插入设置项失败: $e');
      rethrow;
    }
  }

  /// 查询所有设置项
  static Future<List<Map<String, dynamic>>> queryAll(Database db) async {
    try {
      // final db = await DatabaseHelper.database;
      final result = await db.query(
        DatabaseHelper.tableSettings,
        orderBy: '${DatabaseHelper.columnSettingKey} ASC',
      );
      Get.log('查询所有设置项: ${result.length} 条记录');
      return result;
    } catch (e) {
      Get.log('查询所有设置项失败: $e');
      return [];
    }
  }

  /// 根据键名查询设置项
  static Future<Map<String, dynamic>?> queryByKey(Database db, String key) async {
    try {
      // final db = await DatabaseHelper.database;
      final result = await db.query(
        DatabaseHelper.tableSettings,
        where: '${DatabaseHelper.columnSettingKey} = ?',
        whereArgs: [key],
        limit: 1,
      );
      
      if (result.isNotEmpty) {
        Get.log('查询设置项成功: $key');
        return result.first;
      } else {
        Get.log('设置项不存在: $key');
        return null;
      }
    } catch (e) {
      Get.log('查询设置项失败: $e');
      return null;
    }
  }

  /// 删除所有设置项（用于恢复前清空）
  static Future<void> deleteAll(Database db) async {
    try {
      // final db = await DatabaseHelper.database;
      final count = await db.delete(DatabaseHelper.tableSettings);
      Get.log('删除所有设置项: $count 条记录');
    } catch (e) {
      Get.log('删除所有设置项失败: $e');
      rethrow;
    }
  }

  /// 根据键名删除设置项
  static Future<void> deleteByKey(Database db, String key) async {
    try {
      // final db = await DatabaseHelper.database;
      final count = await db.delete(
        DatabaseHelper.tableSettings,
        where: '${DatabaseHelper.columnSettingKey} = ?',
        whereArgs: [key],
      );
      Get.log('删除设置项: $key, 影响行数: $count');
    } catch (e) {
      Get.log('删除设置项失败: $e');
      rethrow;
    }
  }

  /// 更新设置项
  static Future<void> update(Database db, Map<String, dynamic> setting) async {
    try {
      // final db = await DatabaseHelper.database;
      final count = await db.update(
        DatabaseHelper.tableSettings,
        setting,
        where: '${DatabaseHelper.columnSettingKey} = ?',
        whereArgs: [setting['key']],
      );
      Get.log('更新设置项: ${setting['key']}, 影响行数: $count');
    } catch (e) {
      Get.log('更新设置项失败: $e');
      rethrow;
    }
  }

  /// 获取设置项数量
  static Future<int> getCount(Database db) async {
    try {
      // final db = await DatabaseHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableSettings}'
      );
      final count = result.first['count'] as int;
      Get.log('设置项总数: $count');
      return count;
    } catch (e) {
      Get.log('获取设置项数量失败: $e');
      return 0;
    }
  }
}
