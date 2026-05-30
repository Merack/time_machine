import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 系统铃声选择/播放(走 MethodChannel,原生 RingtoneManager / MediaPlayer 实现)
class RingtonePickerService extends GetxService {
  static const MethodChannel _channel =
      MethodChannel('top.merack.time_machine/ringtone');

  final StreamController<void> _completionController =
      StreamController<void>.broadcast();

  /// 系统铃声"自然播放完成"事件流(stopRingtone 主动停止不会触发)
  Stream<void> get onCompleted => _completionController.stream;

  @override
  void onInit() {
    super.onInit();
    _channel.setMethodCallHandler(_onNativeCall);
  }

  @override
  void onClose() {
    _channel.setMethodCallHandler(null);
    _completionController.close();
    super.onClose();
  }

  Future<dynamic> _onNativeCall(MethodCall call) async {
    if (call.method == 'onRingtoneCompleted') {
      if (!_completionController.isClosed) {
        // 往stream里加入信号
        _completionController.add(null);
      }
    }
    return null;
  }

  /// 弹出系统铃声选择器,返回 {uri, title} 或 null
  Future<RingtoneSelection?> pickSystemRingtone({String? currentUri}) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'pickRingtone',
        {'currentUri': currentUri},
      );
      if (result == null) return null;
      final uri = result['uri'] as String?;
      final title = (result['title'] as String?) ?? '系统铃声';
      if (uri == null || uri.isEmpty) return null;
      return RingtoneSelection(uri: uri, title: title);
    } on PlatformException catch (e) {
      Get.log('pickSystemRingtone 失败: $e');
      return null;
    }
  }

  /// 播放系统铃声(用于试听 / 计时事件触发)
  Future<bool> playSystemRingtone(String uri) async {
    try {
      final ok = await _channel.invokeMethod<bool>('playRingtone', {'uri': uri});
      return ok ?? false;
    } on PlatformException catch (e) {
      Get.log('playSystemRingtone 失败: $e');
      return false;
    }
  }

  /// 停止当前系统铃声播放
  Future<void> stopSystemRingtone() async {
    try {
      await _channel.invokeMethod('stopRingtone');
    } on PlatformException catch (e) {
      Get.log('stopSystemRingtone 失败: $e');
    }
  }

  /// 根据 URI 取标题(用于显示当前选中)
  Future<String?> getRingtoneTitle(String uri) async {
    try {
      return await _channel.invokeMethod<String>('getRingtoneTitle', {'uri': uri});
    } on PlatformException catch (e) {
      Get.log('getRingtoneTitle 失败: $e');
      return null;
    }
  }
}

class RingtoneSelection {
  final String uri;
  final String title;
  const RingtoneSelection({required this.uri, required this.title});
}
