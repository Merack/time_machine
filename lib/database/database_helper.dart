import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:get/get.dart';

/// SQLite数据库助手类 - 用于数据库相关(非表查询)的操作
class DatabaseHelper {
  static const String _databaseName = 'time_machine.db';
  static const int _databaseVersion = 1;
  
  // 表名
  static const String tableFocusSessions = 'focus_sessions';
  static const String tableSettings = 'settings';

  // focus_sessions表字段名
  static const String columnId = 'id';
  static const String columnStartTime = 'start_time';
  static const String columnEndTime = 'end_time';
  static const String columnFocusDuration = 'focus_duration';
  static const String columnActualDuration = 'actual_duration';
  static const String columnIsCompleted = 'is_completed';
  static const String columnTimeOfDay = 'time_of_day';

  // settings表字段名
  static const String columnSettingId = 'id';
  static const String columnSettingKey = 'key';
  static const String columnSettingValue = 'value';
  static const String columnSettingType = 'type';
  static const String columnSettingCreatedAt = 'created_at';
  
  static Database? _database;
  
  /// 获取数据库实例
  static Future<Database> get database async {
    // 单例模式
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  /// 初始化数据库
  static Future<Database> _initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, _databaseName);
      
      Get.log('数据库路径: $path');
      
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      Get.log('数据库初始化失败: $e');
      rethrow;
    }
  }
  
  /// 创建表
  static Future<void> _onCreate(Database db, int version) async {
    try {
      // 创建focus_sessions表
      await db.execute('''
        CREATE TABLE $tableFocusSessions (
          $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnStartTime INTEGER NOT NULL,
          $columnEndTime INTEGER NOT NULL,
          $columnFocusDuration INTEGER NOT NULL,
          $columnActualDuration INTEGER NOT NULL,
          $columnIsCompleted INTEGER NOT NULL DEFAULT 1,
          $columnTimeOfDay TEXT NOT NULL
        )
      ''');

      // 创建settings表
      // await db.execute('''
      //   CREATE TABLE $tableSettings (
      //     $columnSettingId INTEGER PRIMARY KEY AUTOINCREMENT,
      //     $columnSettingKey TEXT NOT NULL UNIQUE,
      //     $columnSettingValue TEXT NOT NULL,
      //     $columnSettingType TEXT NOT NULL,
      //     $columnSettingCreatedAt INTEGER NOT NULL
      //   )
      // ''');

      // 创建focus_sessions表索引以优化查询性能
      await db.execute('''
        CREATE INDEX idx_focus_sessions_start_time
        ON $tableFocusSessions ($columnStartTime)
      ''');

      await db.execute('''
        CREATE INDEX idx_focus_sessions_time_of_day
        ON $tableFocusSessions ($columnTimeOfDay)
      ''');

      await db.execute('''
        CREATE INDEX idx_focus_sessions_date_range
        ON $tableFocusSessions ($columnStartTime, $columnEndTime)
      ''');

      // 创建settings表索引
      // await db.execute('''
      //   CREATE INDEX idx_settings_key
      //   ON $tableSettings ($columnSettingKey)
      // ''');

      Get.log('数据库表创建成功');
    } catch (e) {
      Get.log('创建表失败: $e');
      rethrow;
    }
  }
  
  /// 数据库升级
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Get.log('数据库升级: $oldVersion -> $newVersion');
  }
  
  /// 关闭数据库
  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
      Get.log('数据库已关闭');
    }
  }
  
  /// 删除数据库（用于测试）
  static Future<void> deleteDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, _databaseName);
      await databaseFactory.deleteDatabase(path);
      _database = null;
      Get.log('数据库已删除');
    } catch (e) {
      Get.log('删除数据库失败: $e');
    }
  }
  
  /// 获取数据库信息
  static Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final db = await database;
      final version = await db.getVersion();
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'"
      );
      
      return {
        'version': version,
        'tables': tables,
        'path': db.path,
      };
    } catch (e) {
      Get.log('获取数据库信息失败: $e');
      return {};
    }
  }
}
