import 'package:get/get.dart';

class NotificationSettingsState {
  /// eventId -> 是否开启通知
  final RxMap<String, bool> enabled = <String, bool>{}.obs;

  NotificationSettingsState();
}
