/// 设置数据模型 - 用于备份恢复时的数据传输
class SettingModel {
  final int? id; // 数据库自增id, 新建时为null
  final String key; // 设置键名
  final String value; // 设置值(统一转为字符串存储)
  final String type; // 数据类型: 'int', 'bool', 'string'
  final DateTime createdAt; // 创建时间

  const SettingModel({
    this.id, // 可选, 新建时为null, 数据库会自动分配
    required this.key,
    required this.value,
    required this.type,
    required this.createdAt,
  });

  /// 从数据库Map创建SettingModel
  factory SettingModel.fromMap(Map<String, dynamic> map) {
    return SettingModel(
      id: map['id'] as int?,
      key: map['key'] as String,
      value: map['value'] as String,
      type: map['type'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  /// 转换为数据库Map（不包含id, 让数据库自动生成）
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'key': key,
      'value': value,
      'type': type,
      'created_at': createdAt.millisecondsSinceEpoch,
    };

    // 如果id不为null（更新操作）, 则包含id
    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  /// 从MMKV数据创建SettingModel (用于备份设置)
  factory SettingModel.fromMMKV({
    required String key,
    required dynamic value,
    required String type,
  }) {
    return SettingModel(
      key: key,
      value: value.toString(),
      type: type,
      createdAt: DateTime.now(),
    );
  }

  /// 获取类型化的值(用于恢复数据到MMKV)
  dynamic get typedValue {
    switch (type) {
      case 'int':
        return int.tryParse(value) ?? 0;
      case 'bool':
        return value.toLowerCase() == 'true';
      case 'string':
        return value;
      default:
        return value;
    }
  }

  @override
  String toString() {
    return 'SettingModel{id: $id, key: $key, value: $value, type: $type}';
  }
}
