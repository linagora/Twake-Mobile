import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:twake/services/api.dart';
import 'package:twake/services/storage.dart';
import 'package:twake/repositories/auth_repository.dart';

const AUTH_STORE_INDEX = 0;

Future<AuthRepository> init() async {
  // Initilize Storage class (singleton)
  final store = Storage();

  // Initilize Api class (singleton)
  final _ = Api();

  if (kDebugMode)
    Logger.level = Level.debug;
  else
    Logger.level = Level.error;

  // Try to load auth from store

  final authMap =
      await store.load(type: StorageType.Auth, key: AUTH_STORE_INDEX);
  if (authMap != null) {
    return AuthRepository.fromJson(authMap);
  }
  return AuthRepository();
}
