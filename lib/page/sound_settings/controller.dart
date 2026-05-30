import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:mmkv/mmkv.dart';
import 'package:path/path.dart' as p;

import '../../config/storage_keys.dart';
import '../../service/app_storage_service.dart';
import '../../service/custom_sound_storage_service.dart';
import '../../service/permission_service.dart';
import '../../service/ringtone_picker_service.dart';
import 'state.dart';

class SoundSettingsController extends GetxController {
  final SoundSettingsState state = SoundSettingsState();
  final AudioPlayer _previewPlayer = AudioPlayer();
  late final MMKV _storage;
  late final CustomSoundStorageService _customSoundStorage;
  late final RingtonePickerService _ringtonePicker;
  late final PermissionService _permissionService;

  StreamSubscription<void>? _previewCompleteSub;
  StreamSubscription<void>? _systemCompleteSub;

  @override
  void onInit() {
    super.onInit();
    _storage = Get.find<AppStorageService>().mmkv;
    _customSoundStorage = Get.find<CustomSoundStorageService>();
    _ringtonePicker = Get.find<RingtonePickerService>();
    _permissionService = Get.find<PermissionService>();

    // 内置 / 自定义试听播放完成 -> 复位按钮
    _previewCompleteSub = _previewPlayer.onPlayerComplete.listen((_) {
      state.previewingTag.value = '';
    });

    // 系统铃声试听播放完成 -> 复位按钮
    _systemCompleteSub = _ringtonePicker.onCompleted.listen((_) {
      final tag = state.previewingTag.value;
      if (tag.startsWith('system:')) {
        state.previewingTag.value = '';
      }
    });

    _loadAll();
  }

  @override
  void onClose() {
    _previewCompleteSub?.cancel();
    _systemCompleteSub?.cancel();
    _previewPlayer.dispose();
    _ringtonePicker.stopSystemRingtone();
    super.onClose();
  }

  void _loadAll() {
    for (final eventId in StorageKeys.soundEventIds) {
      state.configs[eventId] = _readEvent(eventId);
    }
  }

  SoundEventConfig _readEvent(String eventId) {
    final type = _storage.decodeString(StorageKeys.soundTypeKey(eventId)) ??
        StorageKeys.soundTypeBuiltin;
    final value = _storage.decodeString(StorageKeys.soundValueKey(eventId)) ??
        StorageKeys.defaultEventSounds[eventId]!;
    // storedName: system 类型存铃声标题(uri 非文件路径无法取名);
    // custom 类型存用户选择文件的原始文件名(磁盘上文件按 eventId 命名)。
    final storedName =
        _storage.decodeString(StorageKeys.soundDisplayNameKey(eventId));
    return SoundEventConfig(
      type: type,
      value: value,
      displayName: _resolveDisplayName(type, value, storedName),
    );
  }

  String _resolveDisplayName(String type, String value, String? storedName) {
    switch (type) {
      case StorageKeys.soundTypeBuiltin:
        return StorageKeys.builtinSounds[value] ?? p.basename(value);
      case StorageKeys.soundTypeCustom:
        if (storedName != null && storedName.isNotEmpty) return storedName;
        return p.basename(value);
      case StorageKeys.soundTypeSystem:
        if (storedName != null && storedName.isNotEmpty) return storedName;
        return '系统铃声';
      default:
        return '默认';
    }
  }

  /// 选择内置
  Future<void> selectBuiltin(String eventId, String assetPath) async {
    await stopAllPreview();
    _storage.encodeString(StorageKeys.soundTypeKey(eventId), StorageKeys.soundTypeBuiltin);
    _storage.encodeString(StorageKeys.soundValueKey(eventId), assetPath);
    _storage.removeValue(StorageKeys.soundDisplayNameKey(eventId));
    state.configs[eventId] = _readEvent(eventId);
    state.configs.refresh();
  }

  /// 选择系统铃声
  Future<void> selectSystem(String eventId) async {
    await stopAllPreview();
    final current = _storage.decodeString(StorageKeys.soundValueKey(eventId));
    final picked = await _ringtonePicker.pickSystemRingtone(currentUri: current);
    if (picked == null) return;
    _storage.encodeString(StorageKeys.soundTypeKey(eventId), StorageKeys.soundTypeSystem);
    _storage.encodeString(StorageKeys.soundValueKey(eventId), picked.uri);
    Get.log(picked.uri);
    _storage.encodeString(StorageKeys.soundDisplayNameKey(eventId), picked.title);
    state.configs[eventId] = SoundEventConfig(
      type: StorageKeys.soundTypeSystem,
      value: picked.uri,
      displayName: picked.title,
    );
    state.configs.refresh();
  }

  /// 选择文件管理器自定义
  Future<void> selectCustom(String eventId) async {
    await stopAllPreview();

    // Android 13+ 需要 READ_MEDIA_AUDIO
    final granted = await _permissionService.requestAudioRead();
    if (!granted) {
      Get.snackbar(
        '权限不足',
        '请授予音频读取权限后重试',
        snackPosition: SnackPosition.TOP,
        barBlur: 100,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final result = await FilePicker.pickFiles(
      type: FileType.audio,
      dialogTitle: '选择音频文件',
    );
    if (result == null || result.files.isEmpty) return;
    final src = result.files.first.path;
    if (src == null) return;
    // 文件管理器选中文件的原始名(含扩展名),仅用于展示
    final originalName = result.files.first.name;

    final dest = await _customSoundStorage.importCustomSound(eventId, src);
    if (dest == null) {
      Get.snackbar(
        '导入失败',
        '无法保存自定义音效',
        snackPosition: SnackPosition.TOP,
        barBlur: 100,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // 文件已复制进 documents/sounds/,清掉 file_picker 在 cacheDir 留下的临时副本,避免缓存膨胀
    try {
      await FilePicker.clearTemporaryFiles();
    } catch (e) {
      Get.log('清理 file_picker 缓存失败: $e');
    }

    _storage.encodeString(StorageKeys.soundTypeKey(eventId), StorageKeys.soundTypeCustom);
    _storage.encodeString(StorageKeys.soundValueKey(eventId), dest);
    _storage.encodeString(StorageKeys.soundDisplayNameKey(eventId), originalName);
    state.configs[eventId] = SoundEventConfig(
      type: StorageKeys.soundTypeCustom,
      value: dest,
      displayName: originalName,
    );
    state.configs.refresh();
  }

  /// 重置为默认
  Future<void> resetToDefault(String eventId) async {
    await stopAllPreview();
    final defaultPath = StorageKeys.defaultEventSounds[eventId]!;
    _storage.encodeString(StorageKeys.soundTypeKey(eventId), StorageKeys.soundTypeBuiltin);
    _storage.encodeString(StorageKeys.soundValueKey(eventId), defaultPath);
    _storage.removeValue(StorageKeys.soundDisplayNameKey(eventId));
    state.configs[eventId] = _readEvent(eventId);
    state.configs.refresh();
  }

  /// 试听
  Future<void> previewBuiltin(String assetPath) async {
    final tag = 'builtin:$assetPath';
    // 播放状态再点击为停止
    if (state.previewingTag.value == tag) {
      await stopAllPreview();
      return;
    }
    await stopAllPreview();
    state.previewingTag.value = tag;
    try {
      await _previewPlayer.play(AssetSource(assetPath));
    } catch (e) {
      Get.log('试听失败: $e');
      state.previewingTag.value = '';
    }
  }

  Future<void> previewCustom(String filePath) async {
    final tag = 'custom:$filePath';
    if (state.previewingTag.value == tag) {
      await stopAllPreview();
      return;
    }
    await stopAllPreview();
    if (!await File(filePath).exists()) {
      Get.snackbar(
        '试听失败',
        '文件不存在',
        snackPosition: SnackPosition.TOP,
        barBlur: 100,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    state.previewingTag.value = tag;
    try {
      await _previewPlayer.play(DeviceFileSource(filePath));
    } catch (e) {
      Get.log('试听自定义失败: $e');
      state.previewingTag.value = '';
    }
  }

  Future<void> previewSystem(String uri) async {
    final tag = 'system:$uri';
    if (state.previewingTag.value == tag) {
      await stopAllPreview();
      return;
    }
    await stopAllPreview();
    state.previewingTag.value = tag;
    final ok = await _ringtonePicker.playSystemRingtone(uri);
    if (!ok) state.previewingTag.value = '';
  }

  Future<void> stopAllPreview() async {
    if (_previewPlayer.state == PlayerState.playing) {
      await _previewPlayer.stop();
    }
    await _ringtonePicker.stopSystemRingtone();
    state.previewingTag.value = '';
  }
}
