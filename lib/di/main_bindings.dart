import 'package:get/get.dart';
import 'package:twake/di/local_binding.dart';
import 'package:twake/repositories/language_repository.dart';
import 'package:twake/repositories/theme_repository.dart';
import 'package:twake/services/init_service.dart';
import 'package:twake/utils/platform_detection.dart';

class MainBindings extends Bindings {
  @override
  Future<void> dependencies() async {
    //init service to get Globals
    Get.put(InitService());

    Get.put(PlatformDetection());

    await LocalBinding().dependencies();

    Get.put(LanguageRepository());
    Get.put(ThemeRepository());
  }
}
