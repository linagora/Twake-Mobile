import 'package:get/get.dart';
import 'package:twake/di/data_bindings.dart';
import 'package:twake/utils/platform_detection.dart';

class MainBindings extends Bindings {
  @override
  Future<void> dependencies() async {
    Get.put(PlatformDetection());
    DataBindings().dependencies();
  }

}