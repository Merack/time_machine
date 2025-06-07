import 'package:get/get.dart';
import 'package:time_machine/page/main/state.dart';

class MainController extends GetxController{
  final MainState state = MainState();

  void updateIndex(int newIndex) {
    state.currentIndex = newIndex;
    update();
  }
}