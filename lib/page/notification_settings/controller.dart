import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../config/storage_keys.dart';
import '../../service/notification_service.dart';
import '../../service/permission_service.dart';
import '../../utils/toast_util.dart';
import 'state.dart';

class NotificationSettingsController extends GetxController {
  final NotificationSettingsState state = NotificationSettingsState();

  late final NotificationService _notificationService;
  late final PermissionService _permissionService;

  PermissionService get permissionService => _permissionService;

  @override
  void onInit() {
    super.onInit();
    _notificationService = Get.find<NotificationService>();
    _permissionService = Get.find<PermissionService>();
    _loadAll();
  }

  void _loadAll() {
    for (final eventId in StorageKeys.soundEventIds) {
      state.enabled[eventId] = _notificationService.isEventEnabled(eventId);
    }
  }

  /// 切换某事件的通知开关
  ///
  /// 开关立即写入 MMKV(与设置页的"保存"按钮无关, 这里是即时生效的).
  /// 打开开关时如果系统通知权限还没给, 顺手引导用户去授权, 否则开了也收不到.
  Future<void> toggleEvent(String eventId, bool value) async {
    _notificationService.setEventEnabled(eventId, value);
    state.enabled[eventId] = value;

    if (!value) return;

    final status = _permissionService.notificationStatus.value;
    if (status.isGranted) return;

    if (status.isPermanentlyDenied) {
      ToastUtil.show('通知权限未开启', '请在系统设置中允许通知, 否则收不到提醒');
      return;
    }

    final granted = await _permissionService.requestNotification();
    if (!granted) {
      ToastUtil.show('通知权限未开启', '未获得通知权限, 开关已保存但暂时收不到提醒');
    }
  }

  /// 请求通知权限(权限行按钮)
  Future<void> handlePermissionAction() async {
    final status = _permissionService.notificationStatus.value;
    if (status.isPermanentlyDenied) {
      ToastUtil.show('需要在系统设置中手动开启', '权限已被永久拒绝, 即将跳转到应用设置');
      await _permissionService.openSettings();
      return;
    }
    await _permissionService.requestNotification();
  }
}
