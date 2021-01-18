import 'package:flutter/foundation.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/models/company.dart';
import 'package:twake/models/direct.dart';
import 'package:twake/models/message.dart';
import 'package:twake/models/workspace.dart';
import 'package:twake/repositories/add_channel_repository.dart';
import 'package:twake/repositories/auth_repository.dart';
import 'package:twake/repositories/collection_repository.dart';
import 'package:twake/repositories/profile_repository.dart';
import 'package:twake/repositories/sheet_repository.dart';
import 'package:twake/repositories/user_repository.dart';
import 'package:twake/utils/emojis.dart';
import 'package:twake/utils/drafts.dart';

import 'service_bundle.dart';

Future<AuthRepository> initAuth() async {
  final store = Storage();
  await store.initDb();

  final _ = Api();

  if (kDebugMode)
    Logger.level = Level.debug;
  else
    Logger.level = Level.error;

  return await AuthRepository.load();
}

Future<InitData> initMain() async {
  await Emojis.load();
  // await Drafts.load();
  final profile = await ProfileRepository.load();
  final sheet = await SheetRepository.load();
  final addChannel = await AddChannelRepository.load();
  final _ = UserRepository(Endpoint.users);
  final companies = await CollectionRepository.load<Company>(
    Endpoint.companies,
    sortFields: {'name': true},
  );
  final workspaces = await CollectionRepository.load<Workspace>(
    Endpoint.workspaces,
    filters: [
      ['company_id', '=', companies.selected.id]
    ],
    queryParams: {'company_id': companies.selected.id},
    sortFields: {'name': true},
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
    sortFields: {'name': true},
  );
  final directs = await CollectionRepository.load<Direct>(
    Endpoint.directs,
    queryParams: {
      'company_id': companies.selected.id,
    },
    sortFields: {'last_activity': false},
    filters: [
      ['company_id', '=', companies.selected.id]
    ],
  );
  // final directs =
  // CollectionRepository<Direct>(items: [], apiEndpoint: Endpoint.directs);
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
    sheet: sheet,
    addChannel: addChannel,
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
  final SheetRepository sheet;
  final AddChannelRepository addChannel;

  InitData({
    this.profile,
    this.companies,
    this.workspaces,
    this.channels,
    this.directs,
    this.messages,
    this.threads,
    this.sheet,
    this.addChannel,
  });
}
