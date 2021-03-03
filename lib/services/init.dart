import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:twake/models/channel.dart';
import 'package:twake/models/company.dart';
import 'package:twake/models/direct.dart';
import 'package:twake/models/workspace.dart';
import 'package:twake/repositories/add_channel_repository.dart';
import 'package:twake/repositories/add_direct_repository.dart';
import 'package:twake/repositories/add_workspace_repository.dart';
import 'package:twake/repositories/auth_repository.dart';
import 'package:twake/repositories/collection_repository.dart';
import 'package:twake/repositories/edit_channel_repository.dart';
import 'package:twake/repositories/fields_repository.dart';
import 'package:twake/repositories/member_repository.dart';
import 'package:twake/repositories/messages_repository.dart';
import 'package:twake/repositories/profile_repository.dart';
import 'package:twake/repositories/sheet_repository.dart';
import 'package:twake/repositories/user_repository.dart';

// import 'package:twake/utils/emojis.dart';
import 'package:twake/repositories/draft_repository.dart';

import 'service_bundle.dart';

Future<AuthRepository> initAuth() async {
  final store = Storage();
  await store.initDb();
  // final configurationRepository = await ConfigurationRepository.load();
  // print('Actual host for auth: ${configurationRepository.host}');
  final _api = Api();
  final _state = await Connectivity().checkConnectivity();
  _api.hasConnection = _state != ConnectivityResult.none;

  if (kDebugMode)
    Logger.level = Level.debug;
  else
    Logger.level = Level.error;

  final repository = await AuthRepository.load();
  await repository.getAuthMode();
  return repository;
}

Future<InitData> initMain() async {
  // await Emojis.load();
  final profile = await ProfileRepository.load();
  final sheet = await SheetRepository.load();
  final addChannel = await AddChannelRepository.load();
  final addDirect = AddDirectRepository();
  final editChannel = await EditChannelRepository.load();
  final addWorkspace = AddWorkspaceRepository();
  final fields = FieldsRepository(fields: [], data: {});
  final draft = DraftRepository();
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
      MessagesRepository(items: [], apiEndpoint: Endpoint.messages);
  final messagesDirect =
      MessagesRepository(items: [], apiEndpoint: Endpoint.messages);
  final threads = MessagesRepository(items: [], apiEndpoint: Endpoint.messages);
  var channelMembers;
  if (!channels.isEmpty) {
    channelMembers = await MemberRepository.load(
      Endpoint.channelMembers,
      queryParams: {
        'company_id': companies.selected.id,
        'workspace_id': workspaces.selected.id,
        'channel_id': channels.selected.id,
      },
      sortFields: {'channel_id': true},
    );
  } else
    channelMembers = MemberRepository(
      items: [],
      apiEndpoint: Endpoint.channelMembers,
    );

  return InitData(
    profile: profile,
    companies: companies,
    workspaces: workspaces,
    channels: channels,
    directs: directs,
    messages: messages,
    messagesDirect: messagesDirect,
    threads: threads,
    sheet: sheet,
    addChannel: addChannel,
    editChannel: editChannel,
    channelMembers: channelMembers,
    addWorkspace: addWorkspace,
    draft: draft,
    fields: fields,
  );
}

class InitData {
  final ProfileRepository profile;
  final CollectionRepository<Company> companies;
  final CollectionRepository<Workspace> workspaces;
  final CollectionRepository<Channel> channels;
  final CollectionRepository<Direct> directs;
  final MemberRepository channelMembers;
  final MessagesRepository messages;
  final MessagesRepository messagesDirect;
  final MessagesRepository threads;
  final SheetRepository sheet;
  final AddChannelRepository addChannel;
  final EditChannelRepository editChannel;
  final AddWorkspaceRepository addWorkspace;
  final DraftRepository draft;
  final FieldsRepository fields;

  InitData({
    this.profile,
    this.companies,
    this.workspaces,
    this.channels,
    this.directs,
    this.channelMembers,
    this.messages,
    this.messagesDirect,
    this.threads,
    this.sheet,
    this.addChannel,
    this.editChannel,
    this.addWorkspace,
    this.draft,
    this.fields,
  });
}
