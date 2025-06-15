abstract class AppRoutes {
  // 私有构造函数, 防止实例化此类
  AppRoutes._();

  // 初始路由
  static const String INITIAL = '/main';

  static const String TEST = '/test';
  static const String MAIN = '/main';
  static const String HOME = '/home';
  static const String SETTING = '/setting';
  static const String OTHER = "/other";
  static const String ABOUT = '/about';
  static const String DONATE = '/donate';

  // 带参数的路由
  static const String USER_DETAILS = '/user/:id';
}