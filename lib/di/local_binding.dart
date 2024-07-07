import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:twake/services/storage_service.dart';

class LocalBinding extends Bindings {
  @override
  Future<void> dependencies() async {
    final storage = StorageService(reset: true);
    await storage.init();
    Get.put<StorageService>(storage);
  }
}