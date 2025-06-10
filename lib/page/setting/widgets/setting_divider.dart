import 'package:flutter/material.dart';

/// 设置分割线组件
class SettingDivider extends StatelessWidget {
  const SettingDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: colorScheme.outlineVariant.withValues(alpha: 0.5), // Material 3 分割线颜色
    );
  }
}
