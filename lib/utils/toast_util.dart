import 'package:fluttertoast/fluttertoast.dart';

// 重新导出 Toast,使调用方仅 import 本文件即可使用 Toast.LENGTH_SHORT/LONG。
export 'package:fluttertoast/fluttertoast.dart' show Toast;

/// 统一 Toast 封装,替代原 Get.snackbar。
///
/// 使用原生 fluttertoast:标题与正文以两行展示。
/// 时长仅 SHORT/LONG 两档,通过 [toastLength] 指定,默认 [Toast.LENGTH_SHORT]。
/// 注意:Android 11+ 系统会忽略原生 Toast 的位置(gravity)与自定义样式。
class ToastUtil {
  ToastUtil._();

  static void show(
    String title,
    String message, {
    Toast toastLength = Toast.LENGTH_SHORT,
  }) {
    Fluttertoast.showToast(
      msg: title.isEmpty ? message : '$title\n$message',
      toastLength: toastLength,
      gravity: ToastGravity.TOP,
    );
  }
}
