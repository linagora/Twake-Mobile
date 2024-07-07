import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/authentication_cubit/sync_data_state.dart';
import 'package:twake/blocs/language_cubit/language_cubit.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/company/company.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/models/workspace/workspace.dart';
import 'package:twake/repositories/language_repository.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/utils/extensions.dart';
import 'package:twake/utils/twake_exception.dart';

class InitService {
  Future<void> preloadGlobals() async {
    final _storageService = Get.find<StorageService>();
    await _storageService.init();

    const host = 'https://web.twake.app';
    final g = await _storageService.first(table: Table.globals);
    Globals globals;
    if (g.isNotEmpty) {
      globals = Globals.fromJson(g);
      globals.channelIdSet = null;
      globals.threadIdSet = null;
    } else {
      final String fcmToken = (await FirebaseMessaging.instance.getToken())!;
      globals = Globals(host: host, fcmToken: fcmToken);
      globals.save();
    }

    if (globals.oidcAuthority == null) await globals.hostSet(host);
  }

  // should only be called once after successful authentication/login
  // yields numbers from 1 to 100 meaning percentage of completion
  Stream<SyncDataState> syncData() async* {
    final _apiService = Get.find<ApiService>();
    final _storageService = Get.find<StorageService>();
    // 0. Fetch and save the user's id into Globals
    await _apiService
        .get(endpoint: sprintf(Endpoint.account, ['me']), key: 'resource')
        .then((userData) async {
      final currentAccount = Account.fromJson(json: userData, transform: true);
      Globals.instance.userIdSet = currentAccount.id;
      if (currentAccount.recentCompanyId != null)
        Globals.instance.companyId = currentAccount.recentCompanyId;
      if (currentAccount.recentWorkspaceId != null)
        Globals.instance.workspaceId = currentAccount.recentWorkspaceId;
      //TODO Remove when API for editing user profile is ready,integrate API into LanguageRepository
      final dataL = await _storageService.select(
          table: Table.account,
          columns: ["language"],
          where: "id = ?",
          whereArgs: [Globals.instance.userId]);

      await _storageService.insert(table: Table.account, data: currentAccount);

      if (dataL.isNotEmpty) {
        _storageService.update(
            table: Table.account,
            values: dataL[0],
            where: "id = ?",
            whereArgs: [Globals.instance.userId]);
      }
    }).catchError((error, stackTrace) async* {
      yield SyncDataFailState(failedSource: SyncFailedSource.AccountApi);
    });
    yield SyncDataSuccessState(process: 5);

    // 1. Fetch all companies by user
    List<dynamic> remoteResult = await _apiService.get(
      endpoint: sprintf(Endpoint.companies, [Globals.instance.userId]),
      key: 'resources',
    );
    if (remoteResult.isEmpty) {
      yield SyncDataFailState(failedSource: SyncFailedSource.CompaniesApi);
      // Due to all beyond requests below are depending on companies,
      // so once this is failed, stop all remaining stuff.
      throw SyncFailedException(failedSource: SyncFailedSource.CompaniesApi);
    } else {
      yield SyncDataSuccessState(process: 15);
    }

    final companies = remoteResult.map(
      (i) => Company.fromJson(json: i, tranform: true),
    );
    _storageService.multiInsert(table: Table.company, data: companies);
    // Set company id in Globals if not set already

    if (Globals.instance.companyId == null) {
      Globals.instance.companyIdSet = companies.first.id;
    }

    // 2. For each company fetch workspaces
    final workspaceFutures = companies.map((c) async {
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

    // 3. For each company fetch direct chats
    final directFutures = companies.map((c) async {
      remoteResult = await _apiService
          .get(
        endpoint: sprintf(Endpoint.channels, [c.id, 'direct']),
        queryParameters: {'mine': 1},
        key: 'resources',
      )
          .catchError((error, stackTrace) async* {
        yield SyncDataFailState(
            failedSource: SyncFailedSource.ChannelsDirectApi);
      });
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

    if (workspaces.isEmpty) {
      yield SyncDataFailState(failedSource: SyncFailedSource.WorkspacesApi);
    } else {
      yield SyncDataSuccessState(process: 35);
    }

    final directs =
        (await Future.wait(directFutures)).reduce((a, b) => a.followedBy(b));

    yield SyncDataSuccessState(process: 70);

    // Set workspace id in Globals if not set already
    if (Globals.instance.workspaceId == null) {
      Globals.instance.workspaceIdSet = workspaces.first.id;
    }

    // 4. For each workspace fetch channel
    final channelFutures = workspaces.map((w) async {
      remoteResult = await _apiService
          .get(
        endpoint: sprintf(Endpoint.channels, [w.companyId, w.id]),
        queryParameters: {'mine': 1},
        key: 'resources',
      )
          .catchError((error, stackTrace) async* {
        yield SyncDataFailState(failedSource: SyncFailedSource.ChannelsApi);
      });
      final channels = remoteResult.map(
        (i) => Channel.fromJson(json: i, jsonify: false, transform: true),
      );

      _storageService.multiInsert(
        table: Table.channel,
        data: channels,
      );

      return channels;
    });
    yield SyncDataSuccessState(process: 85);

    // 5. For each workspace fetch members
    final accountFutures = workspaces.map((w) async {
      remoteResult = await _apiService
          .get(
        endpoint: sprintf(Endpoint.workspaceMembers, [w.companyId, w.id]),
        key: 'resources',
      )
          .catchError((error, stackTrace) async* {
        yield SyncDataFailState(
            failedSource: SyncFailedSource.WorkspaceMembersApi);
      });
      final accounts = remoteResult.map(
        (i) => Account.fromJson(json: i['user'], transform: true),
      );
      // Create links between accounts and workspaces
      final accounts2workspaces = remoteResult.map(
        (i) => Account2Workspace(
          userId: i['user_id'],
          workspaceId: w.id,
        ),
      );
      //TODO Remove when API for editing user profile is ready,integrate it into LanguageRepository
      final dataL = await _storageService.select(
          table: Table.account,
          columns: ["language"],
          where: "id = ?",
          whereArgs: [Globals.instance.userId]);

      await _storageService.multiInsert(table: Table.account, data: accounts);

      _storageService.update(
          table: Table.account,
          values: dataL[0],
          where: "id = ?",
          whereArgs: [Globals.instance.userId]);

      _storageService.multiInsert(
        table: Table.account2workspace,
        data: accounts2workspaces,
      );
    });

    final channels =
        (await Future.wait(channelFutures)).reduce((a, b) => a.followedBy(b));

    yield SyncDataSuccessState(process: 95);

    Future.wait(accountFutures);

    // 6. For each channel/direct fetch messages (last 100 will do, default)
    channels
        .followedBy(directs)
        .map((c) async {
          remoteResult = await _apiService
              .get(
            endpoint: sprintf(
              Endpoint.threadsChannel,
              [c.companyId, c.workspaceId, c.id],
            ),
            queryParameters: {
              'emojis': false,
              'include_users': 1,
              'limit': 100,
              'direction': 'history',
            },
            key: 'resources',
          )
              .catchError((error, stackTrace) async* {
            yield SyncDataFailState(failedSource: SyncFailedSource.ThreadsApi);
          });
          final messages = remoteResult
              .where((rm) => rm['type'] == 'message' && rm['subtype'] == null)
              .map(
                (i) => Message.fromJson(
                  i,
                  jsonify: true,
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
    final language = await LanguageRepository().getLanguage();
    Get.find<LanguageCubit>().changeLanguage(language: language);

    yield SyncDataSuccessState(process: 100);
  }
}
