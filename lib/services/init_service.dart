import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';

class InitService {
  static final apiService = ApiService(reset: true);
  static final storageService = StorageService(reset: true);

  static Future<void> preAuthenticationInit() async {
    final globals = await storageService.first(table: Table.globals);
    if (globals.isNotEmpty) {
      Globals.fromJson(globals);
    } else {
      final String fcmToken = (await FirebaseMessaging.instance.getToken())!;
      Globals(host: 'https://chat.twake.app', fcmToken: fcmToken);
    }
  }

  // should only be called once after successful authentication/login
  static Future<void> syncData() async {
    // 1. TODO fetch all companies
    // 2. TODO for each company fetch workspaces
    // 3. TODO for each company fetch direct chats
    // 4. TODO for each workspace fetch channel
    // 5. TODO for each workspace fetch members
    // 6. TODO for each channel/direct fetch messages (last 50 will do)
  }
}
