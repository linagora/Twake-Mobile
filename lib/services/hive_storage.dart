import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:twake/data/local/account2workspace_hive_client.dart';
import 'package:twake/data/local/account_hive_client.dart';
import 'package:twake/data/local/authentication_hive_client.dart';
import 'package:twake/data/local/badge_hive_client.dart';
import 'package:twake/data/local/channel_hive_client.dart';
import 'package:twake/data/local/company_hive_client.dart';
import 'package:twake/data/local/globals_hive_client.dart';
import 'package:twake/data/local/message_hive_client.dart';
import 'package:twake/data/local/sharedlocation_hive_client.dart';
import 'package:twake/data/local/workspace_hive_client.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/account/account2workspace_hive.dart';
import 'package:twake/models/account/account_hive.dart';
import 'package:twake/models/authentication/authentication.dart';
import 'package:twake/models/authentication/authentication_hive.dart';
import 'package:twake/models/badge/badge.dart';
import 'package:twake/models/badge/badge_hive.dart';
import 'package:twake/models/base_model/base_model.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/channel/channel_hive.dart';
import 'package:twake/models/channel/channel_role.dart';
import 'package:twake/models/channel/channel_stats_hive.dart';
import 'package:twake/models/company/company.dart';
import 'package:twake/models/company/company_hive.dart';
import 'package:twake/models/company/company_role.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/globals/globals_hive.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/models/message/message_hive.dart';
import 'package:twake/models/message/pinned_info_hive.dart';
import 'package:twake/models/message/reaction.dart';
import 'package:twake/models/model_extensions.dart';
import 'package:twake/models/receive_sharing/shared_location.dart';
import 'package:twake/models/receive_sharing/shared_location_hive.dart';
import 'package:twake/models/workspace/workspace.dart';
import 'package:twake/models/workspace/workspace_hive.dart';
import 'package:twake/models/workspace/workspace_role.dart';
import 'package:twake/services/storage_service.dart';

/// This service provides common methods for all tables in Hive storage
/// that only is represented by base data object (base model, map object, etc.)
class HiveStorage {

  final _accountHiveClient = Get.find<AccountHiveClient>();
  final _authenticationHiveClient = Get.find<AuthenticationHiveClient>();
  final _badgeHiveClient = Get.find<BadgeHiveClient>();
  final _account2workspaceHiveClient = Get.find<Account2WorkspaceHiveClient>();
  final _companyHiveClient = Get.find<CompanyHiveClient>();
  final _workspaceHiveClient = Get.find<WorkspaceHiveClient>();
  final _channelHiveClient = Get.find<ChannelHiveClient>();
  final _messageHiveClient = Get.find<MessageHiveClient>();
  final _globalsHiveClient = Get.find<GlobalsHiveClient>();
  final _sharedLocationHiveClient = Get.find<SharedLocationHiveClient>();

  Future<void> init() async {
    await Hive.initFlutter();
    registerAdapters();
  }

  void registerAdapters() {
    // main adapters
    Hive.registerAdapter(AuthenticationHiveAdapter());
    Hive.registerAdapter(AccountHiveAdapter());
    Hive.registerAdapter(Account2WorkspaceHiveAdapter());
    Hive.registerAdapter(CompanyHiveAdapter());
    Hive.registerAdapter(WorkspaceHiveAdapter());
    Hive.registerAdapter(ChannelHiveAdapter());
    Hive.registerAdapter(MessageHiveAdapter());
    Hive.registerAdapter(GlobalsHiveAdapter());
    Hive.registerAdapter(BadgeHiveAdapter());
    Hive.registerAdapter(SharedLocationHiveAdapter());
    // child adapters
    Hive.registerAdapter(BadgeTypeAdapter());
    Hive.registerAdapter(ChannelRoleAdapter());
    Hive.registerAdapter(ChannelStatsHiveAdapter());
    Hive.registerAdapter(ChannelVisibilityAdapter());
    Hive.registerAdapter(CompanyRoleAdapter());
    Hive.registerAdapter(ChannelsTypeAdapter());
    Hive.registerAdapter(DeliveryAdapter());
    Hive.registerAdapter(MessageSubtypeAdapter());
    Hive.registerAdapter(MessageSummaryAdapter());
    Hive.registerAdapter(PinnedInfoHiveAdapter());
    Hive.registerAdapter(ReactionAdapter());
    Hive.registerAdapter(WorkspaceRoleAdapter());
  }

  Future<void> insert({
    required Table table,
    required BaseModel data,
  }) async {
    switch(table) {
      case Table.authentication:
        if(data is Authentication) {
          final authHive = data.toAuthenticationHive();
          _authenticationHiveClient.insert(authHive);
        }
        break;
      case Table.account:
        if(data is Account) {
          final accountHive = data.toAccountHive();
          _accountHiveClient.insert(accountHive);
        }
        break;
      case Table.account2workspace:
        if(data is Account2Workspace) {
          final a2w = data.toAccount2WorkspaceHive();
          _account2workspaceHiveClient.insert(a2w);
        }
        break;
      case Table.company:
        if(data is Company) {
          final companyHive = data.toCompanyHive();
          _companyHiveClient.insert(companyHive);
        }
        break;
      case Table.workspace:
        if(data is Workspace) {
          final wsHive = data.toWorkspaceHive();
          _workspaceHiveClient.insert(wsHive);
        }
        break;
      case Table.channel:
        if(data is Channel) {
          final cHive = data.toChannelHive();
          _channelHiveClient.insert(cHive);
        }
        break;
      case Table.message:
        if(data is Message) {
          final mHive = data.toMessageHive();
          _messageHiveClient.insert(mHive);
        }
        break;
      case Table.globals:
        if(data is Message) {
          final gHive = data.toMessageHive();
          _messageHiveClient.insert(gHive);
        }
        break;
      case Table.badge:
        if(data is Badge) {
          final badgeHive = data.toBadgeHive();
          _badgeHiveClient.insert(badgeHive);
        }
        break;
      case Table.sharedLocation:
        if(data is SharedLocation) {
          final slHive = data.toSharedLocationHive();
          _sharedLocationHiveClient.insert(slHive);
        }
        break;
    }
  }

  Future<void> cleanInsert({
    required Table table,
    required BaseModel data,
  }) async {
    switch(table) {
      case Table.authentication:
        if(data is Authentication) {
          final authHive = data.toAuthenticationHive();
          _authenticationHiveClient.cleanInsert(authHive);
        }
        break;
      case Table.account:
        if(data is Account) {
          final accountHive = data.toAccountHive();
          _accountHiveClient.cleanInsert(accountHive);
        }
        break;
      case Table.account2workspace:
        if(data is Account2Workspace) {
          final a2wHive = data.toAccount2WorkspaceHive();
          _account2workspaceHiveClient.cleanInsert(a2wHive);
        }
        break;
      case Table.company:
        if(data is Company) {
          final companyHive = data.toCompanyHive();
          _companyHiveClient.cleanInsert(companyHive);
        }
        break;
      case Table.workspace:
        if(data is Workspace) {
          final wsHive = data.toWorkspaceHive();
          _workspaceHiveClient.cleanInsert(wsHive);
        }
        break;
      case Table.channel:
        if(data is Channel) {
          final cHive = data.toChannelHive();
          _channelHiveClient.cleanInsert(cHive);
        }
        break;
      case Table.message:
        if(data is Message) {
          final mHive = data.toMessageHive();
          _messageHiveClient.cleanInsert(mHive);
        }
        break;
      case Table.globals:
        if(data is Globals) {
          final gHive = data.toGlobalsHive();
          _globalsHiveClient.cleanInsert(gHive);
        }
        break;
      case Table.badge:
        if(data is Badge) {
          final badgeHive = data.toBadgeHive();
          _badgeHiveClient.cleanInsert(badgeHive);
        }
        break;
      case Table.sharedLocation:
        if(data is SharedLocation) {
          final mHive = data.toSharedLocationHive();
          _sharedLocationHiveClient.cleanInsert(mHive);
        }
        break;
    }
  }

  Future<void> multiInsert({
    required Table table,
    required Iterable<BaseModel> data,
  }) async {
    switch(table) {
      case Table.authentication:
        if(data is Iterable<Authentication>) {
          final authHiveList = data.map((auth) => auth.toAuthenticationHive()).toList();
          _authenticationHiveClient.multiInsert(authHiveList);
        }
        break;
      case Table.account:
        if(data is Iterable<Account>) {
          final accountHiveList = data.map((account) => account.toAccountHive()).toList();
          _accountHiveClient.multiInsert(accountHiveList);
        }
        break;
      case Table.account2workspace:
        if(data is Iterable<Account2Workspace>) {
          final a2wHiveList = data.map((aw2) => aw2.toAccount2WorkspaceHive()).toList();
          _account2workspaceHiveClient.multiInsert(a2wHiveList);
        }
        break;
      case Table.company:
        if(data is Iterable<Company>) {
          final companyList = data.map((comp) => comp.toCompanyHive()).toList();
          _companyHiveClient.multiInsert(companyList);
        }
        break;
      case Table.workspace:
        if(data is Iterable<Workspace>) {
          final wsList = data.map((ws) => ws.toWorkspaceHive()).toList();
          _workspaceHiveClient.multiInsert(wsList);
        }
        break;
      case Table.channel:
        if(data is Iterable<Channel>) {
          final cHiveList = data.map((c) => c.toChannelHive()).toList();
          _channelHiveClient.multiInsert(cHiveList);
        }
        break;
      case Table.message:
        if(data is Iterable<Message>) {
          final mHiveList = data.map((m) => m.toMessageHive()).toList();
          _messageHiveClient.multiInsert(mHiveList);
        }
        break;
      case Table.globals:
        if(data is Iterable<Globals>) {
          final mHiveList = data.map((m) => m.toGlobalsHive()).toList();
          _globalsHiveClient.multiInsert(mHiveList);
        }
        break;
      case Table.badge:
        if(data is Iterable<Badge>) {
          final badgeHiveList = data.map((badge) => badge.toBadgeHive()).toList();
          _badgeHiveClient.multiInsert(badgeHiveList);
        }
        break;
      case Table.sharedLocation:
        if(data is Iterable<SharedLocation>) {
          final mHiveList = data.map((m) => m.toSharedLocationHive()).toList();
          _sharedLocationHiveClient.multiInsert(mHiveList);
        }
        break;
    }
  }

  Future<List<Map<String, Object?>>> select({
    required Table table,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    switch(table) {

      case Table.authentication:
        final result = await _authenticationHiveClient.selectById(
          ids: whereArgs?.map((e) => e as String).toList(),
        );
        final mapRs = result.map((authHive) {
          return authHive.toAuthentication().toJson();
        }).toList();
        return Future.value(mapRs);

      case Table.account:
        List<AccountHive> result = [];
        if(where == 'id = ?') {
          result = await _accountHiveClient.selectById(
            ids: whereArgs?.map((e) => e as String).toList(),
          );
        } else if(where != null && where.contains('username IN')) {
          List<String> usernames = [];
          RegExp reg = RegExp('\\(([^\\(\\)]+)\\)');
          final usernameNoParentheses = reg.stringMatch(where);  // username1, username2
          usernames = usernameNoParentheses?.split(',') ?? [];
          usernames = usernames.length > 0 ? usernames.map((e) => e.trim()).toList() : [];
          result = await _accountHiveClient.selectByUsernames(
              usernames: usernames
          );
        }
        final mapRs = result.map((accountHive) {
          return accountHive.toAccount().toJson();
        }).toList();
        return Future.value(mapRs);

      case Table.account2workspace:
        final result = await _account2workspaceHiveClient.selectById(
          ids: whereArgs?.map((e) => e as String).toList(),
        );
        final mapRs = result.map((a2wHive) {
          return a2wHive.toAccount2Workspace().toJson();
        }).toList();
        return Future.value(mapRs);

      case Table.company:
        final result = await _companyHiveClient.selectById(
          ids: whereArgs?.map((e) => e as String).toList(),
        );
        final mapRs = result.map((compHive) {
          return compHive.toCompany().toJson();
        }).toList();
        return Future.value(mapRs);

      case Table.workspace:
        List<WorkspaceHive> result = [];
        if(where == 'id = ?') {
          result = await _workspaceHiveClient.selectById(
            ids: whereArgs?.map((e) => e as String).toList(),
          );
        } else if(where == 'company_id = ?') {
          result = await _workspaceHiveClient.selectByCompanyIds(
            companyId: whereArgs?.map((e) => e as String).toList().first,
          );
        }
        final mapRs = result.map((wsHive) {
          return wsHive.toWorkspace().toJson();
        }).toList();
        return Future.value(mapRs);

      case Table.channel:
        List<ChannelHive> result = [];
        if(where == 'id = ?') {
          result = await _channelHiveClient.selectById(
            ids: whereArgs?.map((e) => e as String).toList(),
          );
        } else if(where == 'company_id = ? AND workspace_id = ?') {
          result = await _channelHiveClient.selectByCompanyWorkspaceIds(
            companyId: whereArgs?.map((e) => e as String).toList()[0],
            workspaceId: whereArgs?.map((e) => e as String).toList()[1],
          );
        }
        final mapRs = result.map((wsHive) {
          return wsHive.toChannel().toJson();
        }).toList();
        return Future.value(mapRs);

      case Table.message:
        List<MessageHive> result = [];
        if(where == 'id = ?') {
          result = await _messageHiveClient.selectById(
            ids: whereArgs?.map((e) => e as String).toList(),
          );
        } else if (where != null
            && where.contains('channel_id')
            && where.contains('thread_id')) {
          final args = whereArgs?.map((e) => e as String).toList() ?? [];
          final channelId = args[0];
          String? threadId;
          String? files;
          if (args.length == 3) {
            threadId = args[1];
            files = args[2];
          } else if (args.length == 2) {
            threadId = args[1];
          }
          result = await _messageHiveClient.selectByMultipleId(
            channelId: channelId,
            threadId: threadId,
            files: files,
          );
        }

        final mapRs = result.map((mHive) {
          return mHive.toMessage().toJson();
        }).toList();
        return Future.value(mapRs);

      case Table.globals:
        final result = await _globalsHiveClient.selectById(
          ids: whereArgs?.map((e) => e as String).toList(),
        );
        final mapRs = result.map((gHive) {
          return gHive.toGlobals().toJson();
        }).toList();
        return Future.value(mapRs);

      case Table.badge:
        final result = await _badgeHiveClient.selectById(
          ids: whereArgs?.map((e) => e as String).toList(),
        );
        final mapRs = result.map((badgeHive) {
          return badgeHive.toBadge().toJson();
        }).toList();
        return Future.value(mapRs);

      case Table.sharedLocation:
        final result = await _sharedLocationHiveClient.selectById(
          ids: whereArgs?.map((e) => e as String).toList(),
        );
        final mapRs = result.map((slHive) {
          return slHive.toSharedLocation().toJson();
        }).toList();
        return Future.value(mapRs);
    }
  }

  Future<void> update({
    required Table table,
    required Map<String, dynamic> values,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    switch(table) {
      case Table.authentication:
        _authenticationHiveClient.updateById(
          object: Authentication.fromJson(values).toAuthenticationHive(),
          ids: whereArgs?.map((e) => e as String).toList(),
        );
        break;
      case Table.account:
        _accountHiveClient.updateById(
          object: Account.fromJson(json: values).toAccountHive(),
          ids: whereArgs?.map((e) => e as String).toList(),
        );
        break;
      case Table.account2workspace:
        _account2workspaceHiveClient.updateById(
          object: Account2Workspace.fromJson(json: values).toAccount2WorkspaceHive(),
          ids: whereArgs?.map((e) => e as String).toList(),
        );
        break;
      case Table.company:
        _companyHiveClient.updateById(
          object: Company.fromJson(json: values).toCompanyHive(),
          ids: whereArgs?.map((e) => e as String).toList(),
        );
        break;
      case Table.workspace:
        _workspaceHiveClient.updateById(
          object: Workspace.fromJson(json: values).toWorkspaceHive(),
          ids: whereArgs?.map((e) => e as String).toList(),
        );
        break;
      case Table.channel:
        break;
      case Table.message:
        _messageHiveClient.updateById(
          object: Message.fromJson(values).toMessageHive(),
          ids: whereArgs?.map((e) => e as String).toList(),
        );
        break;
      case Table.globals:
        break;
      case Table.badge:
        _badgeHiveClient.updateById(
          object: Badge.fromJson(json: values).toBadgeHive(),
          ids: whereArgs?.map((e) => e as String).toList(),
        );
        break;
      case Table.sharedLocation:

        break;
    }
  }

  Future<void> delete({
    required Table table,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    switch(table) {
      case Table.authentication:
        _authenticationHiveClient.deleteById(
          ids: whereArgs?.map((e) => e as String).toList(),
        );
        break;
      case Table.account:
        _accountHiveClient.deleteById(
          ids: whereArgs?.map((e) => e as String).toList(),
        );
        break;
      case Table.account2workspace:
        _account2workspaceHiveClient.deleteById(
          ids: whereArgs?.map((e) => e as String).toList(),
        );
        break;
      case Table.company:
        _companyHiveClient.deleteById(
          ids: whereArgs?.map((e) => e as String).toList(),
        );
        break;
      case Table.workspace:
        _workspaceHiveClient.deleteById(
          ids: whereArgs?.map((e) => e as String).toList(),
        );
        break;
      case Table.channel:
        _channelHiveClient.deleteById(
          ids: whereArgs?.map((e) => e as String).toList(),
        );
        break;
      case Table.message:
        _messageHiveClient.deleteById(
          ids: whereArgs?.map((e) => e as String).toList(),
        );
        break;
      case Table.globals:

        break;
      case Table.badge:
        _badgeHiveClient.deleteById(
          ids: whereArgs?.map((e) => e as String).toList(),
        );
        break;
      case Table.sharedLocation:

        break;
    }
  }

  Future<void> truncate({required Table table}) async {
    switch(table) {
      case Table.authentication:
        _authenticationHiveClient.truncate();
        break;
      case Table.account:
        _accountHiveClient.truncate();
        break;
      case Table.account2workspace:
        _account2workspaceHiveClient.truncate();
        break;
      case Table.company:
        _companyHiveClient.truncate();
        break;
      case Table.workspace:
        _workspaceHiveClient.truncate();
        break;
      case Table.channel:
        _channelHiveClient.truncate();
        break;
      case Table.message:
        _messageHiveClient.truncate();
        break;
      case Table.globals:

        break;
      case Table.badge:
        _badgeHiveClient.truncate();
        break;
      case Table.sharedLocation:

        break;
    }
  }

  Future<void> truncateAll() async {
    // await Hive.deleteFromDisk();
    //TODO Remove when API for editing user profile is ready,integrate it into LanguageRepository
    for (final table in Table.values) {
      if (table.name != 'account') {
        await Hive.deleteBoxFromDisk(table.name);
      }
    }
  }
}
