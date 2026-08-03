import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'setting_tile.dart';

/// 权限设置行
///
/// 已授权时右侧显示绿色状态徽章, 未授权显示操作按钮;
/// 永久拒绝时按钮变为错误色的"去设置", 由调用方决定跳转逻辑.
/// 设置页和通知设置页共用.
class PermissionRow extends StatelessWidget {
  const PermissionRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.describe,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final PermissionStatus status;
  final String describe;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final granted = status.isGranted;

    return SettingTile(
      title: title,
      subtitle: subtitle,
      trailing: granted
          ? _StatusBadge(text: describe, color: Colors.green.shade600)
          : ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: status.isPermanentlyDenied
                    ? theme.colorScheme.error
                    : null,
                foregroundColor: status.isPermanentlyDenied
                    ? theme.colorScheme.onError
                    : null,
              ),
              child: Text(status.isPermanentlyDenied ? '去设置' : '去授权'),
            ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
