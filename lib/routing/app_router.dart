import 'package:get/get.dart';

void push(String routeName, {dynamic arguments}) {
  Get.toNamed(routeName, arguments: arguments);
}

void popBack() {
  Get.back();
}
