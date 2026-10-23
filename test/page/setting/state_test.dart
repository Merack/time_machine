import 'package:flutter_test/flutter_test.dart';
import 'package:time_machine/page/setting/state.dart';

void main() {
  test(
    'background retention defaults to disabled with media mixing enabled',
    () {
      final state = SettingState();
      addTearDown(state.dispose);

      expect(state.backgroundRetentionEnabled.value, isFalse);
      expect(state.backgroundRetentionMixWithOthers.value, isTrue);
    },
  );
}
