import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:twake/services/api_service.dart';
import 'package:twake/services/push_notifications_service.dart';
import 'package:twake/services/socketio_service.dart';
import 'package:twake/services/synchronization_service.dart';

class RemoteBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(PushNotificationsService(reset: true));

    Get.put(ApiService(reset: true));

    Get.put(SocketIOService(reset: true));

    Get.put(SynchronizationService(reset: true));
  }
}