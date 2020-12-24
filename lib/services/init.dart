import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/models/company.dart';
import 'package:twake/models/message.dart';
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
  final profile = await ProfileRepository.load();
  final companies =
      await CollectionRepository.load<Company>(Endpoint.companies);
  final workspaces = await CollectionRepository.load<Workspace>(
    Endpoint.workspaces,
    filters: [
      ['company_id', '=', companies.selected.id]
    ],
  );
  final channels = await CollectionRepository.load<Channel>(
    Endpoint.channels,
    queryParams: {'workspace_id': workspaces.selected.id},
    filters: [
      ['workspace_id', '=', workspaces.selected.id]
    ],
  );
  final messages =
      CollectionRepository<Message>(items: [], apiEndpoint: Endpoint.messages);

  return InitData(
    profile: profile,
    companies: companies,
    workspaces: workspaces,
    channels: channels,
    messages: messages,
  );
}

class InitData {
  final ProfileRepository profile;
  final CollectionRepository companies;
  final CollectionRepository workspaces;
  final CollectionRepository channels;
  final CollectionRepository messages;

  InitData({
    this.profile,
    this.companies,
    this.workspaces,
    this.channels,
    this.messages,
  });
}
