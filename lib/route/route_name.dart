abstract class AppRoutes {
  // 私有构造函数，防止实例化此类
  AppRoutes._();

  // 初始路由，通常是启动页或主页
  static const String INITIAL = '/main';

  static const String TEST = '/test';
  static const String MAIN = '/main';
  static const String HOME = '/home';
  static const String SETTING = '/setting';
  static const String OTHER = "/other";

  // 带参数的路由
  static const String USER_DETAILS = '/user/:id';
}