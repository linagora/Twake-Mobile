import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:twake/repositories/auth_repository.dart';
import 'package:twake/repositories/profile_repository.dart';

import 'service_bundle.dart';

const AUTH_STORE_INDEX = 0;

Future<AuthRepository> initAuth() async {
  // Initilize Storage class (singleton)
  final store = Storage();
  await store.initDb();

  // Initilize Api class (singleton)
  final _ = Api();

  if (kDebugMode)
    Logger.level = Level.debug;
  else
    Logger.level = Level.error;
  final logger = Logger();

  // Try to load auth from store
  final authMap =
      await store.load(type: StorageType.Auth, key: AUTH_STORE_INDEX);

  logger.d('Auth data from storage: $authMap');

  final fcmToken = (await FirebaseMessaging().getToken());

  if (authMap != null) {
    return AuthRepository.fromJson(authMap)..fcmToken = fcmToken;
  }
  return AuthRepository(fcmToken);
}

Future<void> initMain() async {
  await ProfileRepository.load();
}
