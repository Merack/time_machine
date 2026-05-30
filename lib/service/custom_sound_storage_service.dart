import 'dart:io';

import 'package:get/get.dart';
import 'package:mmkv/mmkv.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../config/storage_keys.dart';
import 'app_storage_service.dart';

/// 自定义提示音文件管理
///
/// 把用户通过文件管理器选中的音频复制到应用私有目录,
/// 避免源文件被删除/移动/无权访问导致播放失败。
///
/// 目录: `getApplicationDocumentsDirectory()/sounds/<eventId>.<ext>`
class CustomSoundStorageService extends GetxService {
  late final MMKV _storage;
  Directory? _soundsDir;

  Future<CustomSoundStorageService> init() async {
    _storage = Get.find<AppStorageService>().mmkv;
    _soundsDir = await _ensureSoundsDir();
    await cleanupOrphans();
    return this;
  }

  Future<Directory> _ensureSoundsDir() async {
    final docDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docDir.path, 'sounds'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> get soundsDir async {
    return _soundsDir ??= await _ensureSoundsDir();
  }

  /// 把外部音频文件复制到私有目录
  /// 返回复制后的绝对路径,失败返回 null
  Future<String?> importCustomSound(String eventId, String sourcePath) async {
    try {
      final src = File(sourcePath);
      if (!await src.exists()) {
        Get.log('源文件不存在: $sourcePath');
        return null;
      }

      // 删掉该 eventId 的旧自定义音(如果有)
      await _deleteExistingForEvent(eventId);

      final ext = p.extension(sourcePath); // 含点符号
      final dir = await soundsDir;
      final dest = File(p.join(dir.path, '$eventId$ext'));
      await src.copy(dest.path);

      Get.log('自定义音效已保存: ${dest.path}');
      return dest.path;
    } catch (e) {
      Get.log('保存自定义音效失败: $e');
      return null;
    }
  }

  /// 清除指定事件的自定义音文件(不动 MMKV 配置)
  Future<void> _deleteExistingForEvent(String eventId) async {
    final dir = await soundsDir;
    if (!await dir.exists()) return;
    await for (final entity in dir.list()) {
      if (entity is File) {
        final name = p.basenameWithoutExtension(entity.path);
        if (name == eventId) {
          try {
            await entity.delete();
          } catch (e) {
            Get.log('删除旧自定义音失败: $e');
          }
        }
      }
    }
  }

  /// 启动时清理 MMKV 没在引用的孤儿文件
  Future<void> cleanupOrphans() async {
    try {
      final dir = await soundsDir;
      if (!await dir.exists()) return;

      // 收集所有事件当前引用的 custom 路径
      final referenced = <String>{};
      for (final eventId in StorageKeys.soundEventIds) {
        final type = _storage.decodeString(StorageKeys.soundTypeKey(eventId));
        if (type == StorageKeys.soundTypeCustom) {
          final path = _storage.decodeString(StorageKeys.soundValueKey(eventId));
          if (path != null && path.isNotEmpty) {
            referenced.add(path);
          }
        }
      }

      await for (final entity in dir.list()) {
        if (entity is File && !referenced.contains(entity.path)) {
          try {
            await entity.delete();
            Get.log('清理孤儿音效: ${entity.path}');
          } catch (e) {
            Get.log('清理孤儿音效失败: $e');
          }
        }
      }
    } catch (e) {
      Get.log('cleanupOrphans 异常: $e');
    }
  }

  /// 重置数据库时清空所有自定义音
  Future<void> clearAllCustomSounds() async {
    try {
      final dir = await soundsDir;
      if (!await dir.exists()) return;
      await for (final entity in dir.list()) {
        if (entity is File) {
          try {
            await entity.delete();
          } catch (_) {}
        }
      }
    } catch (e) {
      Get.log('clearAllCustomSounds 异常: $e');
    }
  }

  /// 检查文件是否还存在
  Future<bool> fileExists(String path) async {
    if (path.isEmpty) return false;
    return File(path).exists();
  }
}
