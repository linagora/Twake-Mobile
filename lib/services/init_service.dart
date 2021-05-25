import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/company/company.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/models/workspace/workspace.dart';
import 'package:twake/services/service_bundle.dart';

class InitService {
  static final _apiService = ApiService(reset: true);
  static final _storageService = StorageService(reset: true);

  static Future<void> preAuthenticationInit() async {
    final globals = await _storageService.first(table: Table.globals);
    if (globals.isNotEmpty) {
      Globals.fromJson(globals);
    } else {
      final String fcmToken = (await FirebaseMessaging.instance.getToken())!;
      Globals(host: 'https://chat.twake.app', fcmToken: fcmToken);
    }
  }

  // should only be called once after successful authentication/login
  static Future<void> syncData() async {
    // 1. Fetch all the companies and save them to local store
    List<Map<String, dynamic>> remoteResult = await _apiService.get(
      endpoint: Endpoint.companies,
    );
    final companies = remoteResult.map(
      (i) => Company.fromJson(json: i, jsonify: false),
    );
    await _storageService.multiInsert(table: Table.company, data: companies);

    Iterable<Workspace> workspaces = Iterable.empty();
    Iterable<Channel> directs = Iterable.empty();
    for (final company in companies) {
      // 2. For each company fetch workspaces
      remoteResult = await _apiService.get(
        endpoint: Endpoint.workspaces,
        queryParameters: {'company_id': company.id},
      );
      workspaces = workspaces.followedBy(remoteResult.map(
        (i) => Workspace.fromJson(json: i, jsonify: false),
      ));

      // 3. For each company fetch direct chats
      remoteResult = await _apiService.get(
        endpoint: Endpoint.directs,
        queryParameters: {'company_id': company.id},
      );
      directs = directs.followedBy(remoteResult.map(
        (i) => Channel.fromJson(json: i, jsonify: false),
      ));
    }
    await _storageService.multiInsert(
      table: Table.workspace,
      data: workspaces,
    );
    await _storageService.multiInsert(
      table: Table.channel,
      data: directs,
    );

    Iterable<Channel> channels = Iterable.empty();
    Iterable<Account> accounts = Iterable.empty();
    Iterable<Account2Workspace> accounts2workspaces = Iterable.empty();
    for (final workspace in workspaces) {
      // 4. For each workspace fetch channel
      remoteResult = await _apiService.get(
        endpoint: Endpoint.channels,
        queryParameters: {
          'company_id': workspace.companyId,
          'workspace_id': workspace.id,
        },
      );
      channels = channels.followedBy(remoteResult.map(
        (i) => Channel.fromJson(json: i, jsonify: false),
      ));
      // 5. For each workspace fetch members
      remoteResult = await _apiService.get(
        endpoint: Endpoint.workspaceMembers,
        queryParameters: {
          'company_id': workspace.companyId,
          'workspace_id': workspace.id,
        },
      );
      accounts = accounts.followedBy(remoteResult.map(
        (i) => Account.fromJson(json: i),
      ));
      // Create links between accounts and workspaces
      accounts2workspaces = accounts2workspaces.followedBy(remoteResult.map(
        (i) => Account2Workspace(
          userId: i['id'],
          workspaceId: workspace.id,
        ),
      ));
    }
    await _storageService.multiInsert(
      table: Table.channel,
      data: directs,
    );

    await _storageService.multiInsert(table: Table.account, data: accounts);
    await _storageService.multiInsert(
      table: Table.account2workspace,
      data: accounts2workspaces,
    );

    // 6. For each channel/direct fetch messages (last 50 will do, default)
    Iterable<Message> messages = Iterable.empty();
    for (final channel in channels.followedBy(directs)) {
      remoteResult = await _apiService.get(
        endpoint: Endpoint.messages,
        queryParameters: {
          'company_id': channel.companyId,
          'workspace_id': channel.workspaceId,
          'channel_id': channel.id,
        },
      );
      messages = messages.followedBy(remoteResult.map(
        (i) => Message.fromJson(json: i, jsonify: false),
      ));
    }
    await _storageService.multiInsert(table: Table.message, data: messages);
  }
}
