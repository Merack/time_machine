import 'package:time_machine/page/main/state.dart';

class MainController {
  final MainState state = MainState();

  void updateIndex(int newIndex) {
    state.currentIndex.value = newIndex;
  }
}