import 'package:get/get.dart';
import 'package:twake/routing/route_paths.dart';

Future<dynamic> push(String routeName, {dynamic arguments}) async {
  return Get.toNamed(routeName, arguments: arguments);
}

Future<dynamic> pushOff(String routeName, {dynamic arguments}) async {
  return Get.offAndToNamed(routeName, arguments: arguments);
}

void popBack({dynamic result}) {
  Get.back(result: result);
}

void popToHome() {
  Get.offAllNamed(RoutePaths.initial);
}
