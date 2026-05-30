import 'package:get/get.dart';

class SoundEventConfig {
  final String type;
  final String value;
  final String displayName;

  const SoundEventConfig({
    required this.type,
    required this.value,
    required this.displayName,
  });

  SoundEventConfig copyWith({String? type, String? value, String? displayName}) {
    return SoundEventConfig(
      type: type ?? this.type,
      value: value ?? this.value,
      displayName: displayName ?? this.displayName,
    );
  }
}

class SoundSettingsState {
  /// eventId -> 当前选择
  final RxMap<String, SoundEventConfig> configs = <String, SoundEventConfig>{}.obs;

  /// 当前正在试听的标识(eventId 或 builtin 资源路径)
  final RxString previewingTag = ''.obs;
}
