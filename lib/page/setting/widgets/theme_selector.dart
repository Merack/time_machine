import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/theme_controller.dart';

/// 主题选择器组件
class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final theme = Theme.of(context);

    return Obx(() {
      final currentMode = themeController.themeModeString;
      final availableModes = themeController.availableThemeModes;

      return PopupMenuButton<String>(
        initialValue: currentMode,
        onSelected: (String value) {
          themeController.changeThemeMode(value);
        },
        itemBuilder: (BuildContext context) {
          return availableModes.map((String mode) {
            return PopupMenuItem<String>(
              value: mode,
              child: Row(
                children: [
                  // 选中状态指示器
                  Icon(
                    currentMode == mode ? Icons.check : null,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    themeController.getThemeModeDisplayName(mode),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: currentMode == mode
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      fontWeight: currentMode == mode
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                themeController.getThemeModeDisplayName(currentMode),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_drop_down,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      );
    });
  }
}
