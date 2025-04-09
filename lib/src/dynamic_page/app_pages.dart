import 'package:get/get.dart';

class AppPages {
  AppPages._();

  static List<GetPage> routes = [];

  /// 注册路由
  static void registerRoute(List<GetPage> routes) {
    AppPages.routes.addAll(routes);
  }
}
