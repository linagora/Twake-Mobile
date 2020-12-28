import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info/package_info.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/models/company.dart';
import 'package:twake/models/direct.dart';
import 'package:twake/models/message.dart';
import 'package:twake/models/workspace.dart';
import 'package:twake/repositories/auth_repository.dart';
import 'package:twake/repositories/collection_repository.dart';
import 'package:twake/repositories/profile_repository.dart';
import 'package:twake/repositories/user_repository.dart';

import 'service_bundle.dart';

const AUTH_STORE_INDEX = 0;

Future<AuthRepository> initAuth() async {
  final store = Storage();
  await store.initDb();

  final _ = Api();

  if (kDebugMode)
    Logger.level = Level.debug;
  else
    Logger.level = Level.error;
  final logger = Logger();

  final authMap =
      await store.load(type: StorageType.Auth, key: AUTH_STORE_INDEX);

  logger.d('Auth data from storage: $authMap');

  final fcmToken = (await FirebaseMessaging().getToken());
  final apiVersion = (await PackageInfo.fromPlatform()).version;

  if (authMap != null) {
    logger.d('INIT APIVERSION: $apiVersion');
    final authRepository = AuthRepository.fromJson(authMap);
    authRepository
      ..fcmToken = fcmToken
      ..apiVersion = apiVersion
      ..updateHeaders()
      ..updateApiInterceptors();
    return authRepository;
  }
  return AuthRepository(fcmToken: fcmToken, apiVersion: apiVersion);
}

Future<InitData> initMain() async {
  final profile = await ProfileRepository.load();
  final _ = UserRepository(Endpoint.users);
  final companies =
      await CollectionRepository.load<Company>(Endpoint.companies);
  final workspaces = await CollectionRepository.load<Workspace>(
    Endpoint.workspaces,
    filters: [
      ['company_id', '=', companies.selected.id]
    ],
    queryParams: {'company_id': companies.selected.id},
  );
  final channels = await CollectionRepository.load<Channel>(
    Endpoint.channels,
    queryParams: {
      'workspace_id': workspaces.selected.id,
      'company_id': companies.selected.id,
    },
    filters: [
      ['workspace_id', '=', workspaces.selected.id]
    ],
  );
  final directs = await CollectionRepository.load<Direct>(
    Endpoint.directs,
    queryParams: {
      'company_id': companies.selected.id,
    },
    // TODO uncomment once company_id becomes available
    // filters: [
    // ['company_id', '=', workspaces.selected.id]
    // ],
  );
  final messages =
      CollectionRepository<Message>(items: [], apiEndpoint: Endpoint.messages);
  final threads =
      CollectionRepository<Message>(items: [], apiEndpoint: Endpoint.messages);

  return InitData(
    profile: profile,
    companies: companies,
    workspaces: workspaces,
    channels: channels,
    directs: directs,
    messages: messages,
    threads: threads,
  );
}

class InitData {
  final ProfileRepository profile;
  final CollectionRepository<Company> companies;
  final CollectionRepository<Workspace> workspaces;
  final CollectionRepository<Channel> channels;
  final CollectionRepository<Direct> directs;
  final CollectionRepository<Message> messages;
  final CollectionRepository<Message> threads;

  InitData({
    this.profile,
    this.companies,
    this.workspaces,
    this.channels,
    this.directs,
    this.messages,
    this.threads,
  });
}
