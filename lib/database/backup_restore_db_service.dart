import 'dart:io';
import 'package:get/get.dart';
import 'package:mmkv/mmkv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';

import '../config/storage_keys.dart';
import '../dao/focus_session_dao.dart';
import '../dao/setting_dao.dart';
import '../model/setting_model.dart';
import 'database_helper.dart';
import '../service/app_storage_service.dart';

/// 数据备份与恢复服务
class BackupRestoreDBService {
  late final MMKV _mmkv;

  BackupRestoreDBService(){
    _mmkv = Get.find<AppStorageService>().mmkv;
  }

  /// 执行数据备份
  /// 返回备份文件的完整路径，失败时返回null
  Future<String?> backupData() async {
    try {
      Get.log('开始数据备份...');
      
      // 获取Download目录
      final downloadsDir = await _getDownloadsDirectory();
      // final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) {
        Get.log('无法获取Downloads目录');
        return null;
      }
      
      // 创建备份文件路径
      final backupFile = '${downloadsDir.path}/time_machine_backup.db';
      // 检查备份文件是否已存在
      final backupFileObj = File(backupFile);
      if (await backupFileObj.exists()) {
        // 删除旧文件
        await backupFileObj.delete();
        Get.log('删除已存在的备份文件');
      }

      // 创建备份数据库
      final backupDB = await openDatabase(
        backupFile,
        version: 1,
        onCreate: (db, version) async {
          // 创建与主数据库相同的表结构
          await _createBackupTables(db);
        },
        // 更新: 直接删除整个数据库文件再重建, 性能可能会更好一点
        // 如果旧的备份文件已存在, 那么每次打开时都删除旧表
        // onOpen: (db) async {
        //   await _createBackupTables(db);
        // },
      );

      // 将MMKV设置数据转移到settings表
      await _transferMMKVToSettings(backupDB);
      
      // 复制focus_sessions数据
      final focusSessions = await FocusSessionDao.queryAll();
      if (focusSessions.isNotEmpty) {
        final batch = backupDB.batch();
        for (final session in focusSessions) {
          batch.insert(DatabaseHelper.tableFocusSessions, session);
        }
        await batch.commit(noResult: true);
      }
      
      // 关闭数据库
      await backupDB.close();
      
      Get.log('数据备份完成: $backupFile');
      return backupFile;
      
    } catch (e) {
      Get.log('数据备份失败: $e');
      return null;
    }
  }

  /// 执行数据恢复
  /// 返回是否成功
  Future<bool> restoreData() async {
    try {
      Get.log('开始数据恢复...');
      // Get.log('===${(await getDownloadsDirectory())?.path}===');
      
      // 选择备份文件
      final result = await FilePicker.platform.pickFiles(
        // 这里的FileType.custom无法识别db文件, 还是用默认的any吧, 只不过这样要自己验证后缀了
        // TODO: 文件后缀验证
        // type: FileType.custom,
        // allowedExtensions: ['db'],
        dialogTitle: '选择备份文件',
        initialDirectory: (await _getDownloadsDirectory())?.path,
      );
      
      if (result == null || result.files.isEmpty) {
        Get.log('用户取消选择文件');
        return false;
      }
      
      final backupFilePath = result.files.first.path;
      if (backupFilePath == null) {
        Get.log('无效的文件路径');
        return false;
      }
      
      final backupFile = File(backupFilePath);
      if (!await backupFile.exists()) {
        Get.log('备份文件不存在');
        return false;
      }
      
      // 验证备份文件
      if (!await _validateBackupFile(backupFile)) {
        Get.log('备份文件验证失败');
        return false;
      }
      
      // 打开备份数据库
      final backupDb = await openDatabase(backupFile.path, readOnly: true);
      
      // 恢复focus_sessions数据
      await _restoreFocusSessions(backupDb);
      
      // 恢复settings数据到MMKV
      await _restoreSettingsToMMKV(backupDb);
      
      // 关闭备份数据库
      await backupDb.close();
      
      Get.log('数据恢复完成');
      return true;
      
    } catch (e) {
      Get.log('数据恢复失败: $e');
      return false;
    }
  }

  /// 获取Download目录
  Future<Directory?> _getDownloadsDirectory() async {
    try {
      if (Platform.isAndroid) {
        // Android平台获取Download目录
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          // 获取外部存储根目录
          final externalStorageRoot = directory.path.split('/Android')[0];
          final downloadsPath = '$externalStorageRoot/Download';
          final downloadsDir = Directory(downloadsPath);

          // 确保目录存在
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }
          Get.log("$downloadsDir");

          return downloadsDir;
        }
      }
      // 其他平台没时间适配, 先使用文档目录吧
      return await getApplicationDocumentsDirectory();
    } catch (e) {
      Get.log('获取Downloads目录失败: $e');
      return null;
    }
  }

  /// 将MMKV设置数据转移到settings表
  Future<void> _transferMMKVToSettings(Database backupDB) async {
    final settingsToBackup = <SettingModel>[];
    
    // 定义需要备份的设置键和类型
    final settingsMap = <String, String>{
      StorageKeys.focusTimeMinutes: 'int',
      StorageKeys.bigBreakTimeMinutes: 'int',
      StorageKeys.microBreakEnabled: 'bool',
      StorageKeys.microBreakTimeSeconds: 'int',
      StorageKeys.microBreakIntervalMinMinutes: 'int',
      StorageKeys.microBreakIntervalMaxMinutes: 'int',
      StorageKeys.isCountingUp: 'bool',
      StorageKeys.isProgressForward: 'bool',
      StorageKeys.autoStartNextFocus: 'bool',
      StorageKeys.themeMode: 'string',
    };
    
    for (final entry in settingsMap.entries) {
      final key = entry.key;
      final type = entry.value;
      
      dynamic value;
      switch (type) {
        case 'int':
          value = _mmkv.decodeInt(key);
          break;
        case 'bool':
          value = _mmkv.decodeBool(key);
          break;
        case 'string':
          value = _mmkv.decodeString(key);
          break;
      }
      
      if (value != null) {
        final setting = SettingModel.fromMMKV(
          key: key,
          value: value,
          type: type,
        );
        settingsToBackup.add(setting);
      }
    }
    
    // 批量插入到settings表
    if (settingsToBackup.isNotEmpty) {
      final settingMaps = settingsToBackup.map((s) => s.toMap()).toList();
      await SettingDao.insertBatch(backupDB, settingMaps);
    }
  }

  /// 创建备份数据库表结构
  Future<void> _createBackupTables(Database db) async {
    // 先删除已存在的表，然后创建focus_sessions表(更新: 直接删除整个数据库文件再重建, 性能可能会更好一点)
    // await db.execute('DROP TABLE IF EXISTS ${DatabaseHelper.tableFocusSessions}');
    await db.execute('''
      CREATE TABLE ${DatabaseHelper.tableFocusSessions} (
        ${DatabaseHelper.columnId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseHelper.columnStartTime} INTEGER NOT NULL,
        ${DatabaseHelper.columnEndTime} INTEGER NOT NULL,
        ${DatabaseHelper.columnFocusDuration} INTEGER NOT NULL,
        ${DatabaseHelper.columnActualDuration} INTEGER NOT NULL,
        ${DatabaseHelper.columnIsCompleted} INTEGER NOT NULL DEFAULT 1,
        ${DatabaseHelper.columnTimeOfDay} TEXT NOT NULL
      )
    ''');
    
    // 先删除已存在的表，然后创建settings表 (更新: 直接删除整个数据库文件重建, 性能可能会更好一点)
    // await db.execute('DROP TABLE IF EXISTS ${DatabaseHelper.tableSettings}');
    await db.execute('''
      CREATE TABLE ${DatabaseHelper.tableSettings} (
        ${DatabaseHelper.columnSettingId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseHelper.columnSettingKey} TEXT NOT NULL UNIQUE,
        ${DatabaseHelper.columnSettingValue} TEXT NOT NULL,
        ${DatabaseHelper.columnSettingType} TEXT NOT NULL,
        ${DatabaseHelper.columnSettingCreatedAt} INTEGER NOT NULL
      )
    ''');
  }

  /// 验证备份文件的有效性
  Future<bool> _validateBackupFile(File backupFile) async {
    try {
      final db = await openDatabase(backupFile.path, readOnly: true);
      
      // 检查必要的表是否存在
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'"
      );
      
      final tableNames = tables.map((t) => t['name'] as String).toSet();
      final requiredTables = {
        DatabaseHelper.tableFocusSessions,
        DatabaseHelper.tableSettings,
      };
      
      await db.close();
      
      return requiredTables.every((table) => tableNames.contains(table));
    } catch (e) {
      Get.log('验证备份文件失败: $e');
      return false;
    }
  }

  /// 恢复focus_sessions数据
  Future<void> _restoreFocusSessions(Database backupDb) async {
    // 清空现有数据
    final mainDb = await DatabaseHelper.database;
    await mainDb.delete(DatabaseHelper.tableFocusSessions);
    
    // 从备份恢复数据
    final sessions = await backupDb.query(DatabaseHelper.tableFocusSessions);
    if (sessions.isNotEmpty) {
      await FocusSessionDao.insertBatch(sessions);
    }
  }

  /// 恢复settings数据到MMKV
  Future<void> _restoreSettingsToMMKV(Database backupDb) async {
    final settings = await backupDb.query(DatabaseHelper.tableSettings);
    
    for (final settingMap in settings) {
      final setting = SettingModel.fromMap(settingMap);
      final key = setting.key;
      final value = setting.typedValue;
      
      switch (setting.type) {
        case 'int':
          _mmkv.encodeInt(key, value as int);
          break;
        case 'bool':
          _mmkv.encodeBool(key, value as bool);
          break;
        case 'string':
          _mmkv.encodeString(key, value as String);
          break;
      }
    }
  }
}