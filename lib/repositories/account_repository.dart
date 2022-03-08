import 'package:twake/models/account/account.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/service_bundle.dart';

class AccountRepository {
  final _api = ApiService.instance;
  final _storage = StorageService.instance;

  AccountRepository();

  // userId can be null for current app user on first login
  Stream<Account> fetch({String? userId}) async* {
    Account account;
    if (userId != null) {
      account = await localFetch(userId: userId);
      yield account;
    }

    if (!Globals.instance.isNetworkConnected) return;

    account = await remoteFetch(userId: userId);

    yield account;
  }

  Future<Account> localFetch({required String userId}) async {
    final localResult = await _storage.first(
      table: Table.account,
      where: 'id = ?',
      whereArgs: [userId],
    );

    return Account.fromJson(json: localResult);
  }

  Future<void> setRecentWorkspace() async {
    try {
      final result =
          await _api.post(endpoint: Endpoint.accountPreferences, data: {
        "recent_workspaces": [
          {
            "workspace_id": Globals.instance.workspaceId,
            "company_id": Globals.instance.companyId
          }
        ]
      });
      // print(result);
    } catch (e) {
      Logger().e('Error occured during account preferences setup:\n$e');
      return;
    } finally {
      _storage.update(
          table: Table.account,
          values: {
            'workspace_id': Globals.instance.workspaceId,
            'company_id': Globals.instance.companyId
          },
          where: "id = ?",
          whereArgs: [Globals.instance.userId]);
    }
  }

  Future<Account> remoteFetch({String? userId}) async {
    final remoteResult = await _api.get(
      endpoint: sprintf(Endpoint.account, [userId ?? 'me']),
      key: 'resource',
    );

    final account = Account.fromJson(json: remoteResult, transform: true);

    final dataL = await _storage.select(
        table: Table.account,
        columns: ["language"],
        where: "id = ?",
        whereArgs: [Globals.instance.userId]);

    _storage.insert(table: Table.account, data: account);

    _storage.update(
        table: Table.account,
        values: dataL[0],
        where: "id = ?",
        whereArgs: [Globals.instance.userId]);

    /*   account.toJson().forEach((key, value) {
      if (key != "language" && (value != "" && value != " ")) {
        fields.add(key);
        values.add(value);
      }
    });
    _storage.rawInsert(table: Table.account, fields: fields, values: values);*/
    return account;
  }

  Future<Account> edit({
    String? firstName,
    String? lastName,
    required String username,
    String? status,
    String? statusIcon,
    String? language,
    String? oldPassword,
    String? newPassword,
  }) async {
    final _ = {
      'firstname': firstName,
      'lastname': lastName,
      'username': username,
      'status': status,
      'status_icon': statusIcon,
      'language': language,
      'password': {
        'old': oldPassword,
        'new': newPassword,
      },
    };

    throw Exception('Moved to Twake console for a while');
  }
}
