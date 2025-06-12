import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

/// 数据库服务管理类
class DatabaseService extends GetxService {
  Database? _database;
  Database get database => _database!;
  // @override
  // Future<void> onInit() async {
  //   super.onInit();
  //   await _initializeDatabase();
  // }

  Future<DatabaseService> init() async {
    try {
      Get.log('DatabaseService: 开始初始化数据库...');

      // 初始化数据库连接
      _database = await DatabaseHelper.database;

      // 获取数据库信息
      final dbInfo = await DatabaseHelper.getDatabaseInfo();
      Get.log('DatabaseService: 数据库初始化成功');
      Get.log('DatabaseService: 数据库版本: ${dbInfo['version']}');
      Get.log('DatabaseService: 数据库路径: ${dbInfo['path']}');
      Get.log('DatabaseService: 数据表: ${dbInfo['tables']}');

    } catch (e) {
      Get.log('DatabaseService: 数据库初始化失败: $e');
      rethrow;
    }
    return this;
  }
  /// 初始化数据库
  // Future<void> _initializeDatabase() async {
  //   try {
  //     Get.log('DatabaseService: 开始初始化数据库...');
  //
  //     // 初始化数据库连接
  //     await DatabaseHelper.database;
  //
  //     // 获取数据库信息
  //     final dbInfo = await DatabaseHelper.getDatabaseInfo();
  //     Get.log('DatabaseService: 数据库初始化成功');
  //     Get.log('DatabaseService: 数据库版本: ${dbInfo['version']}');
  //     Get.log('DatabaseService: 数据库路径: ${dbInfo['path']}');
  //     Get.log('DatabaseService: 数据表: ${dbInfo['tables']}');
  //
  //   } catch (e) {
  //     Get.log('DatabaseService: 数据库初始化失败: $e');
  //     rethrow;
  //   }
  // }

  @override
  void onClose() {
    super.onClose();
    _closeDatabase();
  }

  /// 关闭数据库
  Future<void> _closeDatabase() async {
    try {
      await DatabaseHelper.close();
      Get.log('DatabaseService: 数据库已关闭');
    } catch (e) {
      Get.log('DatabaseService: 关闭数据库失败: $e');
    }
  }

  /// 获取数据库状态
  Future<Map<String, dynamic>> getDatabaseStatus() async {
    try {
      final dbInfo = await DatabaseHelper.getDatabaseInfo();
      return {
        'initialized': true,
        'version': dbInfo['version'],
        'path': dbInfo['path'],
        'tables': dbInfo['tables'],
      };
    } catch (e) {
      return {
        'initialized': false,
        'error': e.toString(),
      };
    }
  }

  /// 重置数据库（仅用于开发和测试）
  Future<void> resetDatabase() async {
    try {
      Get.log('DatabaseService: 开始重置数据库...');
      
      // 关闭当前数据库连接
      await DatabaseHelper.close();
      
      // 删除数据库文件
      await DatabaseHelper.deleteDatabase();
      
      // 重新初始化数据库
      // await _initializeDatabase();
      await init();
      
      Get.log('DatabaseService: 数据库重置完成');
    } catch (e) {
      Get.log('DatabaseService: 数据库重置失败: $e');
      rethrow;
    }
  }
}
