import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/company/company.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/models/workspace/workspace.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/utils/extensions.dart';

class InitService {
  static late final ApiService _apiService;
  static late final StorageService _storageService;

  static Future<void> preAuthenticationInit() async {
    _storageService = StorageService(reset: true);
    await _storageService.init();

    final g = await _storageService.first(table: Table.globals);
    Globals globals;
    if (g.isNotEmpty) {
      globals = Globals.fromJson(g);
      globals.channelIdSet = null;
      globals.threadIdSet = null;
    } else {
      final String fcmToken = (await FirebaseMessaging.instance.getToken())!;
      globals = Globals(host: 'https://beta.twake.app', fcmToken: fcmToken);
      globals.save();
    }

    SocketIOService(reset: true);
    PushNotificationsService(reset: true);
    _apiService = ApiService(reset: true);
    SynchronizationService(reset: true);
    if (globals.oidcAuthority == null)
      await globals.hostSet('https://web.qa.twake.app');
  }

  // should only be called once after successful authentication/login
  // yields numbers from 1 to 100 meaning percentage of completion
  static Stream<int> syncData() async* {
    // 0. Fetch and save the user's id into Globals
    await _apiService
        .get(endpoint: sprintf(Endpoint.account, ['me']), key: 'resource')
        .then((userData) {
      final currentAccount = Account.fromJson(json: userData, transform: true);
      Globals.instance.userIdSet = currentAccount.id;
      _storageService.insert(table: Table.account, data: currentAccount);
    });

    yield 5;

    List<dynamic> remoteResult = await _apiService.get(
      endpoint: sprintf(Endpoint.companies, [Globals.instance.userId]),
      key: 'resources',
    );

    yield 15;

    final companies = remoteResult.map(
      (i) => Company.fromJson(json: i, tranform: true),
    );
    _storageService.multiInsert(table: Table.company, data: companies);
    // Set company id in Globals if not set already
    if (Globals.instance.companyId == null) {
      Globals.instance.companyIdSet = companies.first.id;
    }

    final workspaceFutures = companies.map((c) async {
      // 2. For each company fetch workspaces
      remoteResult = await _apiService.get(
        endpoint: sprintf(Endpoint.workspaces, [c.id]),
        key: 'resources',
      );
      final workspaces = remoteResult.map(
        (i) => Workspace.fromJson(json: i, transform: true),
      );

      _storageService.multiInsert(
        table: Table.workspace,
        data: workspaces,
      );
      return workspaces;
    });

    final directFutures = companies.map((c) async {
      // 3. For each company fetch direct chats
      remoteResult = await _apiService.get(
        endpoint: sprintf(Endpoint.channels, [c.id, 'direct']),
        queryParameters: {'mine': 1},
        key: 'resources',
      );
      final directs = remoteResult.map(
        (i) => Channel.fromJson(json: i, jsonify: false, transform: true),
      );
      _storageService.multiInsert(
        table: Table.channel,
        data: directs,
      );
      return directs;
    });

    final workspaces =
        (await Future.wait(workspaceFutures)).reduce((a, b) => a.followedBy(b));

    yield 35;

    final directs =
        (await Future.wait(directFutures)).reduce((a, b) => a.followedBy(b));

    yield 70;

    // Set workspace id in Globals if not set already
    if (Globals.instance.workspaceId == null) {
      Globals.instance.workspaceIdSet = workspaces.first.id;
    }

    final channelFutures = workspaces.map((w) async {
      // 4. For each workspace fetch channel
      remoteResult = await _apiService.get(
        endpoint: sprintf(Endpoint.channels, [w.companyId, w.id]),
        queryParameters: {'mine': 1},
        key: 'resources',
      );
      final channels = remoteResult.map(
        (i) => Channel.fromJson(json: i, jsonify: false, transform: true),
      );

      _storageService.multiInsert(
        table: Table.channel,
        data: channels,
      );

      return channels;
    });

    final accountFutures = workspaces.map((w) async {
      // 5. For each workspace fetch members
      remoteResult = await _apiService.get(
        endpoint: sprintf(Endpoint.workspaceMembers, [w.companyId, w.id]),
        key: 'resources',
      );
      final accounts = remoteResult.map(
        (i) => Account.fromJson(json: i['user']),
      );
      // Create links between accounts and workspaces
      final accounts2workspaces = remoteResult.map(
        (i) => Account2Workspace(
          userId: i['user_id'],
          workspaceId: w.id,
        ),
      );

      _storageService.multiInsert(table: Table.account, data: accounts);

      _storageService.multiInsert(
        table: Table.account2workspace,
        data: accounts2workspaces,
      );
    });

    final channels =
        (await Future.wait(channelFutures)).reduce((a, b) => a.followedBy(b));

    yield 95;

    Future.wait(accountFutures);

    // 6. For each channel/direct fetch messages (last 100 will do, default)
    channels
        .followedBy(directs)
        .map((c) async {
          remoteResult = await _apiService.get(
            endpoint: sprintf(
              Endpoint.threads,
              [c.companyId, c.workspaceId, c.id],
            ),
            queryParameters: {
              'emojis': false,
              'include_users': 1,
              'limit': 100,
            },
            key: 'resources',
          );
          final messages = remoteResult
              .where((rm) => rm['type'] == 'message' && rm['subtype'] == null)
              .map(
                (i) => Message.fromJson(
                  i,
                  jsonify: false,
                  transform: true,
                  channelId: c.id,
                ),
              );

          _storageService.multiInsert(table: Table.message, data: messages);
        })
        .toList()
        .chunks(7)
        .forEach((f) async {
          await Future.wait(f);
        });
    yield 100;
  }
}
