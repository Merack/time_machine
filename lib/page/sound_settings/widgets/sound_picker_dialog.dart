import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/storage_keys.dart';
import '../controller.dart';

class SoundPickerDialog extends StatelessWidget {
  const SoundPickerDialog({
    super.key,
    required this.controller,
    required this.eventId,
  });

  final SoundSettingsController controller;
  final String eventId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventName = StorageKeys.eventDisplayNames[eventId] ?? eventId;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
          maxWidth: 480,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '为「$eventName」选择提示音',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _confirmReset(context, eventName),
                    tooltip: '恢复默认',
                    icon: const Icon(Icons.restart_alt),
                  ),
                ],
              ),
            ),
            // const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _buildBuiltinGroup(theme),
                    _buildSystemGroup(theme),
                    _buildCustomGroup(theme),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('关闭'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, String eventName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('恢复默认'),
        content: Text('确定将「$eventName」恢复为默认提示音?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      controller.resetToDefault(eventId);
      Get.back();
    }
  }

  Widget _buildBuiltinGroup(ThemeData theme) {
    return ExpansionTile(
      // initiallyExpanded: true,
      title: const Text('内置音效'),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
      children: StorageKeys.builtinSounds.entries.map((e) {
        final assetPath = e.key;
        final name = e.value;
        return Obx(() {
          final config = controller.state.configs[eventId];
          final isSelected = config?.type == StorageKeys.soundTypeBuiltin && config?.value == assetPath;
          final isPreviewing = controller.state.previewingTag.value == 'builtin:$assetPath';
          return ListTile(
            dense: true,
            leading: Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
            title: Text(name),
            subtitle: Text(
              assetPath,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            trailing: IconButton(
              onPressed: () => controller.previewBuiltin(assetPath),
              icon: Icon(isPreviewing ? Icons.stop : Icons.play_arrow),
              tooltip: isPreviewing ? '停止' : '试听',
            ),
            onTap: () => controller.selectBuiltin(eventId, assetPath),
          );
        });
      }).toList(),
    );
  }

  Widget _buildSystemGroup(ThemeData theme) {
    return ExpansionTile(
      title: const Text('系统铃声'),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        Obx(() {
          final config = controller.state.configs[eventId];
          final isSelected = config?.type == StorageKeys.soundTypeSystem;
          final isPreviewing = isSelected &&
              config != null &&
              controller.state.previewingTag.value == 'system:${config.value}';
          return ListTile(
            dense: true,
            leading: Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
            title: Text(isSelected ? (config?.displayName ?? '系统铃声') : '点击选择系统铃声'),
            subtitle: isSelected
                ? Text('已选: ${config?.displayName ?? '未知铃声'}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant))
                : null,
            trailing: isSelected && config != null
                ? IconButton(
                    onPressed: () => controller.previewSystem(config.value),
                    icon: Icon(isPreviewing ? Icons.stop : Icons.play_arrow),
                    tooltip: isPreviewing ? '停止' : '试听',
                  )
                : const Icon(Icons.chevron_right),
            onTap: () => controller.selectSystem(eventId),
          );
        }),
      ],
    );
  }

  Widget _buildCustomGroup(ThemeData theme) {
    return ExpansionTile(
      title: const Text('自定义(从文件选择)'),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        Obx(() {
          final config = controller.state.configs[eventId];
          final isSelected = config?.type == StorageKeys.soundTypeCustom;
          final isPreviewing = isSelected &&
              config != null &&
              controller.state.previewingTag.value == 'custom:${config.value}';
          return ListTile(
            dense: true,
            leading: Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
            title: Text(isSelected ? (config?.displayName ?? '自定义') : '点击选择本地音频'),
            subtitle: isSelected
                ? Text(
                    config?.value ?? '',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: isSelected && config != null
                ? IconButton(
                    onPressed: () => controller.previewCustom(config.value),
                    icon: Icon(isPreviewing ? Icons.stop : Icons.play_arrow),
                    tooltip: isPreviewing ? '停止' : '试听',
                  )
                : const Icon(Icons.chevron_right),
            onTap: () => controller.selectCustom(eventId),
          );
        }),
      ],
    );
  }
}
