import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/models/company.dart';
import 'package:twake/models/workspace.dart';
import 'package:twake/repositories/auth_repository.dart';
import 'package:twake/repositories/collection_repository.dart';
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

Future<InitData> initMain() async {
  final logger = Logger();
  final profile = await ProfileRepository.load();
  logger.d('PROFILE DATA: ${profile.toJson()}');
  final companies =
      await CollectionRepository.load<Company>(Endpoint.companies);
  logger.d('COMPANIES: $companies');
  final workspaces =
      await CollectionRepository.load<Workspace>(Endpoint.workspaces);
  logger.d('WORKSPACES: $workspaces');
  final qp = {
    'workspace_id': workspaces.selected.id,
  };
  final channels = await CollectionRepository.load<Channel>(
    Endpoint.channels,
    queryParams: qp,
  );
  logger.d('CHANNELS: $channels');

  return InitData(
    profile: profile,
    companies: companies,
    workspaces: workspaces,
    channels: channels,
  );
}

class InitData {
  final ProfileRepository profile;
  final CollectionRepository companies;
  final CollectionRepository workspaces;
  final CollectionRepository channels;

  InitData({
    this.profile,
    this.companies,
    this.workspaces,
    this.channels,
  });
}
