import 'package:flutter/material.dart';

/// 应用主题定义
class AppThemes {
  // 私有构造函数, 防止实例化
  AppThemes._();

  /// 主题模式枚举
  static const String light = 'light';
  static const String dark = 'dark';
  static const String system = 'system';

  /// 主色调, 使用 Material 3 推荐的紫色
  static const Color _seedColor = Color(0xFF6750A4);

  /// 亮色主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.light,
      ),
    );
  }

  /// 暗色主题
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.dark,
      ),
    );
  }

  /// 根据字符串获取 ThemeMode
  static ThemeMode getThemeModeFromString(String mode) {
    switch (mode) {
      case light:
        return ThemeMode.light;
      case dark:
        return ThemeMode.dark;
      case system:
      default:
        return ThemeMode.system;
    }
  }

  /// 根据 ThemeMode 获取字符串
  static String getStringFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return light;
      case ThemeMode.dark:
        return dark;
      case ThemeMode.system:
        return system;
    }
  }

  /// 获取主题模式的显示名称
  static String getThemeModeDisplayName(String mode) {
    switch (mode) {
      case light:
        return '亮色模式';
      case dark:
        return '暗色模式';
      case system:
      default:
        return '跟随系统';
    }
  }

  /// 所有可用的主题模式
  static const List<String> availableThemeModes = [
    system,
    light,
    dark,
  ];
}