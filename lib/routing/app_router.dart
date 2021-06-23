import 'package:get/get.dart';

Future<dynamic> push(String routeName, {dynamic arguments}) async {
  return Get.toNamed(routeName, arguments: arguments);
}

void popBack({dynamic result}) {
  Get.back(result: result);
}
